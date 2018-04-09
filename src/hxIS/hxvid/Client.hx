/* ************************************************************************ */
/*                                                                          */
/*  haXe Video                                                              */
/*  Copyright (c)2007 Nicolas Cannasse                                      */
/*                                                                          */
/* This library is free software; you can redistribute it and/or            */
/* modify it under the terms of the GNU Lesser General Public               */
/* License as published by the Free Software Foundation; either             */
/* version 2.1 of the License, or (at your option) any later version.	      */
/*                                                                          */
/* This library is distributed in the hope that it will be useful,          */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        */
/* Lesser General Public License or the LICENSE file for more details.      */
/*                                                                          */
/* ************************************************************************ */
package hxvid;

import format.amf.Value;
import format.flv.Data;
import hxvid.Rtmp;
import hxvid.Commands;
import hxvid.SharedObject;
import services.Service;

typedef CommandInfos = {
	var id : Int;
	var h : RtmpHeader;
	var p : RtmpPacket;
}

typedef RtmpMessage = {
	header : RtmpHeader,
	packet : RtmpPacket
}

typedef RtmpStream = {
	var id : Int;
	var channel : Int;
	var audio : Bool;
	var video : Bool;
	var cache : List<{ data : RtmpPacket, time : Int }>;
	var play : {
		var file : String;
		var flv : format.flv.Reader;
		var startTime : Float;
		var curTime : Int;
		var blocked : Null<Float>;
		var paused : Null<Float>;
	};
	var record : {
		var file : String;
		var startTime : Float;
		var flv : format.flv.Writer;
		var pubOpt : String;
		var listeners : List<RtmpStream>;
		var bytes : Int;
		var lastPing : Int;
	};
	var shared : {
		var lock : neko.vm.Mutex;
		var stream : RtmpStream;
		var client : Client;
		var paused : Null<Float>;
	};
	var objects : {
		var lock : neko.vm.Mutex;
	};
}

enum ClientState {
	WaitHandshake;
	WaitHandshakeResponse( hs : haxe.io.Bytes );
	Ready;
	WaitBody( h : RtmpHeader, blen : Int );
}

class Client {

	static var file_security = ~/^[A-Za-z0-9_-][A-Za-z0-9_\/-]*(\.flv)?$/;
	static var globalLock = new neko.vm.Mutex();
	static var sharedStreams = new Hash<RtmpStream>();

	public var socket : neko.net.Socket;
	var server : Server;
	var rtmp : Rtmp;
	var state : ClientState;
	var streams : Array<RtmpStream>;
	var commands : Commands<CommandInfos>;
	var id : Int;
	var ip : Dynamic;
	var awaitingStreams:Hash<RtmpStream>;
	public static var clients:Array<Client>=new Array();
	var appsdir:String;
	var appName:String;
	var streamsdir : String;//example: /applications/myAppName/streams/myMovie.flv
	var sodir : String;//example: /applications/myAppName/sharedobjects/mySo.hxso
	//see also import services.Service

	public function new( serv, s , i )
	{
		server = serv;
		socket = s;
		id=i;
		ip = s.peer().host;
		appsdir=Server.APPS_BASE_DIR;
		sodir = Server.SO_BASE_DIR;
		awaitingStreams = new Hash();
		streamsdir = Server.STREAMS_BASE_DIR;
		state = WaitHandshake;
		streams = new Array();
		socket.output.bigEndian = true;
		rtmp = new Rtmp(null,socket.output);
		commands = new Commands();
		initializeCommands();
		initSoStream();
		addToClients();
		neko.Lib.println("new client with id: " + id +', ip: '+ ip);
	}

	function initializeCommands() {
		commands.add2("connect",cmdConnect,T.Object,T.Opt(T.Object));
		commands.add1("createStream",cmdCreateStream,T.Null);
		commands.add2("play",cmdPlay,T.Null,T.Unk);
		commands.add2("deleteStream",cmdDeleteStream,T.Null,T.Int);
		commands.add3("publish",cmdPublish,T.Null,T.Unk,T.Opt(T.String));
		commands.add3("pause",cmdPause,T.Null,T.Opt(T.Bool),T.Int);
		commands.add3("pauseRaw",cmdPause,T.Null,T.Opt(T.Bool),T.Int);
		commands.add2("receiveAudio",cmdReceiveAudio,T.Null,T.Bool);
		commands.add2("receiveVideo",cmdReceiveVideo,T.Null,T.Bool);
		commands.add1("closeStream",cmdCloseStream,T.Null);
		commands.add2("seek",cmdSeek,T.Null,T.Int);
		
		commands.add1("function0",cmdFunction0,T.Null);
		commands.add1("function1",cmdFunction1,T.Null);
		commands.add2("function2",cmdFunction2,T.Null,T.Unk);
		commands.add3("function3",cmdFunction3,T.Null,T.Int, T.Int);
		commands.add1("function4",cmdFunction4,T.Null);
		commands.add1("function5",Service.function0,T.Null);
	}	

	function addData( h : RtmpHeader, data : haxe.io.Bytes, kind, p ) {
		var s = streams[h.src_dst];
		if( s == null )
			throw "Unknown stream "+h.src_dst;
		var r = s.record;
		if( r == null )	
			return;//throw "Publish not done on stream "+h.src_dst; //commented (is/should be handled elsewhere)
		var time = Std.int((neko.Sys.time() - r.startTime) * 1000);
		var chunk = kind(data,time);
		if(r.flv != null)//added: (only write to file when published with pubOpt 'record')
		{
			r.flv.writeChunk(chunk);
		}
		r.bytes += data.length;
		if( r.bytes - r.lastPing > 100000 ) {
			rtmp.send(2,PBytesReaded(r.bytes));
			r.lastPing = r.bytes;
		}
		for( s in r.listeners ) {
			s.shared.lock.acquire();
			if( s.shared.paused == null ) {
				if( s.cache == null ) {
					s.cache = new List();
					server.wakeUp(s.shared.client.socket,0);
				}
				s.cache.add({ data : p, time : time });
			}
			s.shared.lock.release();
		}
	}

	function error( i : CommandInfos, msg : String ) {
		rtmp.send(i.h.channel,PCall("onStatus",0,[
			ANull,
			format.amf.Tools.encode({
				level : "error",
				code : "NetStream.Error",
				details : msg,
			})
		]),null,i.h.src_dst);
		throw "ERROR "+msg;
	}

	function securize( i, file : String ) {
		if( !file_security.match(file) )
			error(i,"Invalid file name "+file);
		if( file.indexOf(".") == -1 )
			file += ".flv";
		return streamsdir + file;
	}

	function getStream( i : CommandInfos, ?play : Bool ) {
		var s = streams[i.h.src_dst];
		if( s == null || (play && s.play == null) )
			error(i,"Invalid stream id "+i.h.src_dst);
		return s;
	}

	function openFLV( file ) : format.flv.Reader {
		var flv = null;
		try {
			flv = new format.flv.Reader(neko.io.File.read(file,true));
			flv.readHeader();
		} catch( e : Dynamic ) {
			if( flv != null ) {
				flv.close();
				neko.Lib.rethrow("Corrupted FLV File '"+file+"' ("+Std.string(e)+")");
			}
			throw "FLV file not found '"+file+"'";
		}
		return flv;
	}

	function cmdConnect( i : CommandInfos, obj : Hash<Value> , conargs : Hash<Value> ) 
	{
		neko.Lib.println("client connected with argument: " + conargs);
		var app;
		if( (app = format.amf.Tools.string(obj.get("app"))) == null )
			error(i,"Invalid 'connect' parameters");
		if( app != "" && !file_security.match(app) )
			error(i,"Invalid application path");

		if(streamsdir.charAt(streamsdir.length-1) != "/" )
			streamsdir = streamsdir + "/";
		appName=app+"/";
		streamsdir=appsdir+appName+streamsdir;
			
		rtmp.send(i.h.channel,PCall("_result",i.id,[
			ANull,
			format.amf.Tools.encode({
				level : "status",
				code : "NetConnection.Connect.Success",
				description : "Connection succeeded."
			})
		]));
		
	}

	function cmdCreateStream( i : CommandInfos, _ : Void ) {
		var s = allocStream();
		rtmp.send(i.h.channel,PCall("_result",i.id,[
			ANull,
			ANumber(s.id)
		]));
	}

	function sendStatus( s : RtmpStream, status : String, infos : Dynamic ) {
		infos.code = status;
		infos.level = "status";
		rtmp.send(s.channel,PCall("onStatus",0,[ANull,format.amf.Tools.encode(infos)]),null,s.id);
	}
function cmdPlay( i : CommandInfos, _ : Void, file:Dynamic) 
	{
		var streamName=file;
		var s = streams[i.h.src_dst];
		if( s == null )
		{
			error(i,"Unknown 'play' channel");
		}
		if(file==false)
		{
			if( s.play != null )
			{
				awaitingStreams.remove(s.play.file);
				s.play.flv=null;
				seek(s,0);
				sendStatus(s,"NetStream.Play.Stop",{ 
				details : "playback stopped" 
				});
				s.play=null;
			}
			else if(s.shared!=null)
			{
				for(i in Server.sharedStreams)
				{
					for (j in i.record.listeners)
					{
						if(j==s)
						{
							i.record.listeners.remove(s);
						}
					}
				}
				sendStatus(s,"NetStream.Play.Stop",{ 
					details : "playback stopped" 
				});
				s.shared=null;
			}
			return;
		}
		if( s.play != null )
		{
			s.play.flv.close();
			sendStatus(s,"NetStream.Play.Stop",{ 
				details : "playback stopped" 
			});
			s.play=null;
		}
		if( s.shared != null )
		{
			var sh=Server.sharedStreams.get(Server.APPS_BASE_DIR+appName+Server.STREAMS_BASE_DIR+file+".flv");
			if(sh!=null)
			{
				sh.record.listeners.remove(s);
				sendStatus(s,"NetStream.Play.Stop",{ 
					details : "playback stopped" 
				});
			}
			s.shared=null;
		}
		s.channel = i.h.channel;

		if(Server.sharedStreams.exists(Server.APPS_BASE_DIR+appName+Server.STREAMS_BASE_DIR+file+".flv"))
		{
			file=Server.APPS_BASE_DIR+appName+Server.STREAMS_BASE_DIR+file+".flv";
			globalLock.acquire();
			var sh = Server.sharedStreams.get(file);
			s.shared = {
				lock : new neko.vm.Mutex(),
				client : this, 
				stream : sh, 
				paused : null, 
			};
			sh.record.listeners.add(s);
			globalLock.release();
			seek(s,0);
			sendStatus(s,"NetStream.Play.Reset",{
				description : "Resetting "+file+".", 
				details : file, 
				clientId : s.id
			});
			sendStatus(s,"NetStream.Play.Start",{
				description : "Start playing "+file+".", 
				clientId : s.id 
			});
		} 
		else if(neko.FileSystem.exists(securize(i,file)))
		{
			file = securize(i,file);
			s.play = {
				file : file, 
				flv : null, 
				startTime : null, 
				curTime : 0, 
				blocked : null, 
				paused : null
			};
			seek(s,0);
			sendStatus(s,"NetStream.Play.Reset",{
				description : "Resetting "+file+".", 
				details : file, 
				clientId : s.id
			});
			sendStatus(s,"NetStream.Play.Start",{
				description : "Start playing "+file+".", 
				clientId : s.id 
			});
		}
		else
		{
			//subscribe to a stream that does not yet exist and start playing and wait for potential data to come
			file=Server.APPS_BASE_DIR+appName+Server.STREAMS_BASE_DIR+file+".flv";
			globalLock.acquire();
			s.shared = {
				lock : new neko.vm.Mutex(),
				client : this, 
				stream : null, 
				paused : null, 
			};
			awaitingStreams.set(file,s);
			globalLock.release();
			seek(s,0);
			sendStatus(s,"NetStream.Play.Reset",{
				description : "Resetting "+file+".", 
				details : file, 
				clientId : s.id
			});
			sendStatus(s,"NetStream.Play.Start",{
				description : "Start playing "+file+".", 
				clientId : s.id 
			});
			//sendStatus(s,"NetStream.Play.StreamNotFound",{description : "Stream "+streamName+" not found.", clientId : s.id });
		}
	}
	
	function cmdDeleteStream( i : CommandInfos, _ : Void, stream : Int ) {
		var s = streams[stream];
		if( s == null )
			error(i,"Invalid 'deleteStream' streamid");
		closeStream(s, true);
	}

	function cmdPublish( i : CommandInfos, _ : Void, file : Dynamic, ?pubOpt : String )
	{
		var s = streams[i.h.src_dst];
		if( s == null)
		{
			error(i,"Invalid 'publish' streamid'");
		}
		if(s.record != null || Server.sharedStreams.exists(Std.string(file)) )
		{
			if(file!=false)
			{
				sendStatus(s,"NetStream.Publish.BadName",{details:s.record.file});
			}
			closeStream( s, false );
			return;
		}
		if(file==false)
		{
			globalLock.acquire();
			if(s.record==null)
			{
				globalLock.release();
				return;
			}
			if(s.record.file!=null)
			{
				var streamName=s.record.file;
				var stream=Server.sharedStreams.get(streamName);
				for (i in stream.record.listeners)
				{
					i.shared.client.rtmp.send(s.channel,PCall("onStatus",0,[ANull,format.amf.Tools.encode({level:"status", code:"NetStream.UnPublish.Notify"})]),null,i.id);
					i.shared=null;
				}
				sendStatus(s,"NetStream.UnPublish.Success",{details:s.record.file});
				sendStatus(s,"NetStream.Record.Stop",{details:s.record.file});
				Server.sharedStreams.remove(streamName);
				
				if(s.record.pubOpt=="record")
				{
					s.record.flv.close();
					//s.record.flv=null;
					//seek(s,0);
				}
			}
			globalLock.release();
			return;
		}
		file = securize(i,file);
		s.channel = i.h.channel;
		if(pubOpt == "record")
		{
			var flv = new format.flv.Writer(neko.io.File.write(file,true));
			flv.writeHeader({ hasAudio : true, hasVideo : true, hasMeta : false });
			s.record = {file:file, startTime:neko.Sys.time(), flv:flv, pubOpt:"record", listeners:new List(), bytes:0,lastPing:0,};
			sendStatus(s,"NetStream.Publish.Start",{ details : file });
			sendStatus(s,"NetStream.Record.Start",{ details : file });
		}
		if(pubOpt == "live" || pubOpt==null)
		{
			s.record = {file:file, startTime:neko.Sys.time(), flv:null, pubOpt:"live", listeners:new List(), bytes:0,lastPing:0,};
			sendStatus(s,"NetStream.Publish.Start",{ details : file });
		}
		globalLock.acquire();
		Server.sharedStreams.set(file,s);
		handleWaitingStreams(file,s);
		globalLock.release();
	}

	function cmdPause( i : CommandInfos, _ : Void, ?pause : Bool, time : Int ) {
		var s = getStream(i);
		var p : { paused : Null<Float> } = s.play;
		if( p == null )
			p = s.shared;
		if( p == null )
			return;
		if( pause == null )
			pause = (p.paused == null); // toggle
		if( pause ) {
			if( p.paused == null )
				p.paused = neko.Sys.time();
			rtmp.send(2,PCommand(s.id,CPlay));
		} else {
			if( p.paused != null ) {
				p.paused = null;
				seek(s,time);
			}
		}
		rtmp.send(i.h.channel,PCall("_result",i.id,[
			ANull,
			format.amf.Tools.encode({
				level : "status",
				code : if( pause ) "NetStream.Pause.Notify" else "NetStream.Unpause.Notify",
			})
		]));
	}

	function cmdReceiveAudio( i : CommandInfos, _ : Void, flag : Bool ) {
		var s = getStream(i);
		s.audio = flag;
	}

	function cmdReceiveVideo( i : CommandInfos, _ : Void, flag : Bool ) {
		var s = getStream(i);
		s.video = flag;
	}

	function cmdCloseStream( i : CommandInfos, _ : Void ) {
		var s = getStream(i);
		closeStream(s,false);
	}

	function cmdSeek( i : CommandInfos, _ : Void, time : Int ) {
		var s = getStream(i,true);
		seek(s,time);
		rtmp.send(s.channel,PCall("_result",0,[
			ANull,
			format.amf.Tools.encode({
				level : "status",
				code : "NetStream.Seek.Notify",
			})
		]),null,s.id);
		sendStatus(s,"NetStream.Play.Start",{
			time : time
		});
	}

	public function processPacket( h : RtmpHeader, p : RtmpPacket ) {
		switch( p ){
			case PCall(cmd,iid,args):
				if( !commands.has(cmd) )
					throw "Unknown command "+cmd+"("+args.join(",")+")";
				var infos = {
					id : iid,
					h : h,
					p : p,
				};
				if( !commands.execute(cmd,infos,args) )
					throw "Mismatch arguments for '"+cmd+"' : "+Std.string(args);
			case PAudio(data):
				addData(h,data,FLVAudio,p);
			case PVideo(data):
				addData(h,data,FLVVideo,p);
			case PMeta(data):
				addData(h,data,FLVMeta,p);
			case PCommand(sid,cmd):
				//neko.Lib.println("COMMAND "+Std.string(cmd)+":"+sid);
			case PBytesReaded(b):
				//neko.Lib.println("BYTESREADED "+b);
			case PShared(so):
				//neko.Lib.println("SHARED OBJECT "+Std.string(so));
				processSoPacket(h,p,so);
			case PUnknown(k,data):
				neko.Lib.println("UNKNOWN "+k+" ["+data.length+"bytes]");
		}
	}

	function allocStream() {
		var ids = new Array();
		for( s in streams )
		{
			if( s != null )
			{
				ids[s.id] = true;
			}
		}
		var id = 1;
		while( id < ids.length ) 
		{
			if( ids[id] == null )
			{
				break;
			}
			id++;
		}
		var s = {
			id : id,
			channel : null,
			play : null,
			record : null,
			audio : true,
			video : true,
			shared : null,
			cache : null,
			objects : null
		};
		streams[s.id] = s;
		return s;
	}

	function closeStream( s : RtmpStream, ?delete:Bool )
	{
		if( s.play != null && s.play.flv != null )
		{
			s.play.flv.close();
			sendStatus(s,"NetStream.Play.Stop",{ details : "playback stopped" });
		}
		if( s.record != null ) 
		{
			globalLock.acquire();
			var stream=Server.sharedStreams.get(s.record.file);
			for (i in stream.record.listeners)
			{
				i.shared.client.rtmp.send(s.channel,PCall("onStatus",0,[ANull,format.amf.Tools.encode({level:"status", code:"NetStream.UnPublish.Notify"})]),null,i.id);
			}
			sendStatus(s,"NetStream.UnPublish.Success",{details:s.record.file});
			if(s.record.pubOpt=="record")
			{
				s.record.flv.close();
				sendStatus(s,"NetStream.Record.Stop",{details:s.record.file});
			}
			Server.sharedStreams.remove(s.record.file);
			globalLock.release();
		}
		if( s.shared != null ) 
		{
			globalLock.acquire();
			// on more check in case our shared stream just closed
			if( s.shared != null )
				s.shared.stream.record.listeners.remove(s);
				sendStatus(s,"NetStream.Play.Stop",{ details : "playback stopped" });
			globalLock.release();
		}		
		if(delete)
		{
			streams[s.id] = null;
		}
		else
		{
			s.play=null;
			s.record=null;
			s.shared=null;
		}
	}

	function seek( s : RtmpStream, seekTime : Int ) {
		// clear
		rtmp.send(2,PCommand(s.id,CPlay));
		rtmp.send(2,PCommand(s.id,CReset));
		rtmp.send(2,PCommand(s.id,CClear));

		// no need to send more data for shared streams
		if( s.shared != null )
			return;

		// reset infos
		var p = s.play;
		var now = neko.Sys.time();
		p.startTime = now - Server.FLV_BUFFER_TIME - seekTime / 1000;
		if( p.paused != null )
			p.paused = now;
		p.blocked = null;
		if( p.flv != null )
			p.flv.close();
		p.flv = openFLV(p.file);
		s.cache = new List();

		// prepare to send first audio + video chunk (with null timestamp)
    var audio = s.audio;
    var video = s.video;
		var audioCache = null;
		var metaCache = null;
		while( true ) {
			var c = s.play.flv.readChunk();
			if( c == null )
				break;
			switch( c ) {
			case FLVAudio(data,time):
				if( time < seekTime )
					continue;
				audioCache = { data : PAudio(data), time : time };
				if( !audio )
					break;
				audio = false;
			case FLVVideo(data,time):
				var keyframe = format.flv.Tools.isVideoKeyFrame(data);
				if( keyframe )
					s.cache = new List();
				if( s.video )
					s.cache.add({ data : PVideo(data), time : time });
				if( time < seekTime )
					continue;
				if( !video )
					break;
				video = false;
			case FLVMeta(data,time):
				if( time < seekTime )
					continue;
				if( metaCache != null )
					s.cache.add(metaCache);
				metaCache = { data : PMeta(data), time : time };
				if( seekTime != 0 ) {
					s.cache.add(metaCache);
					metaCache = null;
				}
			}
			if( !audio && !video )
				break;
		}
		if( s.audio && audioCache != null )
			s.cache.push(audioCache);
		if( seekTime == 0 && metaCache != null )
			s.cache.push(metaCache);
	}

	function playShared( s : RtmpStream ) {
		s.shared.lock.acquire();
		try {
			if( s.cache != null )
				while( true ) {
					var f = s.cache.pop();
					if( f == null ) {
						s.cache = null;
						break;
					}
					rtmp.send(s.channel,f.data,f.time,s.id);
					if( server.isBlocking(socket) )
						break;
				}
		} catch( e : Dynamic ) {
			s.shared.lock.release();
			neko.Lib.rethrow(e);
		}
		s.shared.lock.release();
	}

	function playFLV( t : Float, s : RtmpStream ) {
		var p = s.play;
		if( p.paused != null )
			return;
		if( p.blocked != null ) {
			var delta = t - p.blocked;
			p.startTime += delta;
			p.blocked = null;
		}
		if( s.cache != null ) {
			while( true ) {
				var f = s.cache.pop();
				if( f == null ) {
					s.cache = null;
					break;
				}
				rtmp.send(s.channel,f.data,f.time,s.id);
				p.curTime = f.time;
				if( server.isBlocking(socket) ) {
					p.blocked = t;
					return;
				}
			}
		}
		var reltime = Std.int((t - p.startTime) * 1000);
		while( reltime > p.curTime ) {
			var c = p.flv.readChunk();
			if( c == null ) {
				p.flv.close();
				s.play = null;
/*				// this will abort the video before the end
 				sendStatus(s,"NetStream.Play.Stop",{ details : p.file });
				rtmp.send(2,PCommand(s.id,CClear));
				rtmp.send(2,PCommand(s.id,CReset));
*/				return;
			}
			switch( c ) {
			case FLVAudio(data,time):
				if( s.audio )
					rtmp.send(s.channel,PAudio(data),time,s.id);
				p.curTime = time;
			case FLVVideo(data,time):
				if( s.video )
					rtmp.send(s.channel,PVideo(data),time,s.id);
				p.curTime = time;
			case FLVMeta(data,time):
				rtmp.send(s.channel,PMeta(data),time,s.id);
				p.curTime = time;
			}
			if( server.isBlocking(socket) ) {
				p.blocked = t;
				return;
			}
		}
		server.wakeUp( socket, Server.FLV_BUFFER_TIME / 2 );
	}

	public function updateTime( t : Float ) 
	{
		for( s in streams )
		{
			if( s != null ) 
			{
				if( s.play != null )
				{
					playFLV(t,s);
				}
				else if(s.shared != null )
				{
					playShared(s);
				}
				//else 
				if( s.objects != null) 
				{
					playObjects(s);
				}
			}
		}
	}

	public function cleanup() 
	{
		for (i in 0...clients.length)
		{
			if(clients[i]==this)
			{
				clients.splice(i,1);
			}
		}
		for (i in 0...clients.length)
		{
			clients[i].rtmp.send(3,PCall("clientLeft",0,[ANull,format.amf.Tools.encode({id:getId()})]));
		}
		if(clients.length==0)
		{
			server.setClientId(-1);
		}
		for( s in streams )
		{
			if( s != null )
			{
				closeStream(s,true);
			}
		}
		streams = new Array();
		initSoStream();
	}
	
	public function readProgressive( buf, pos, len ) {
		switch( state ) {
		case WaitHandshake:
			if( len < Rtmp.HANDSHAKE_SIZE + 1 )
				return null;
			rtmp.i = new haxe.io.BytesInput(buf,pos,len);
			rtmp.i.bigEndian = true;
			rtmp.readWelcome();
			var hs = rtmp.readHandshake();
			rtmp.writeWelcome();
			rtmp.writeHandshake(hs);
			state = WaitHandshakeResponse(hs);
			return { msg : null, bytes : Rtmp.HANDSHAKE_SIZE + 1 };
		case WaitHandshakeResponse(hs):
			if( len < Rtmp.HANDSHAKE_SIZE )
				return null;
			rtmp.i = new haxe.io.BytesInput(buf,pos,len);
			rtmp.i.bigEndian = true;
			var hs2 = rtmp.readHandshake();
			if( hs.compare(hs2) != 0 )
				throw "Invalid Handshake";
			rtmp.writeHandshake(hs);
			state = Ready;
			return { msg : null, bytes : Rtmp.HANDSHAKE_SIZE };
		case Ready:
			var hsize = rtmp.getHeaderSize(buf.get(pos));
			if( len < hsize )
				return null;
			rtmp.i = new haxe.io.BytesInput(buf,pos,len);
			rtmp.i.bigEndian = true;
			var h = rtmp.readHeader();
			state = WaitBody(h,rtmp.bodyLength(h,true));
			return { msg : null, bytes : hsize };
		case WaitBody(h,blen):
			if( len < blen )
				return null;
			rtmp.i = new haxe.io.BytesInput(buf,pos,len);
			rtmp.i.bigEndian = true;
			var p = rtmp.readPacket(h);
			var msg = if( p != null ) { header : h, packet : p } else null;
			state = Ready;
			return { msg : msg, bytes : blen };
		}
		return null;
	}
	//============================ADDITIONAL COMMANDS=================================
	//added functions that can be called from Flash + functions in Flash that can be invoked by the Server as a response
	//these can also be moved to a seperate folder/package/class (see line nr 181 for example)
	function cmdFunction0(i : CommandInfos, _ :Void):Void
	{
		neko.Lib.println("nc.call('function0') calls cmdFunction0 on server");
	}
	function cmdFunction1(i : CommandInfos, _ :Void):Void
	{
		neko.Lib.println("nc.call('function1',null) calls cmdFunction1 on server");
	}
	function cmdFunction2(i : CommandInfos, _ :Void, msg:Dynamic):Void
	{
		neko.Lib.println("nc.call('function2') calls cmdFunction2 on server with argument: " + msg);
	}
	function cmdFunction3(i : CommandInfos, _ :Void, int1:Int, int2:Int):Void
	{
		var sum:Int=int1+int2;
		rtmp.send(i.h.channel,PCall("_result",i.id,[ANull,format.amf.Tools.encode({total:sum})]));
	}
	function cmdFunction4(i : CommandInfos, _ :Void):Void
	{
		rtmp.send(i.h.channel,PCall("receiveId",0,[ANull,format.amf.Tools.encode({id:getId()})]));
	}
	function addToClients():Void
	{
		clients.push(this);
	}	
	function handleWaitingStreams(file,stream):Void
	{
		for(i in 0...clients.length)
		{
			if(clients[i].awaitingStreams.exists(file))
			{
				var sh=clients[i].awaitingStreams.get(file);
				sh.shared.stream=stream;
				stream.record.listeners.add(sh);
			}
		}
	}
	function processSoPacket( h : RtmpHeader, p : RtmpPacket, so : SOData ):Void
	{
		/*
		neko.Lib.println("processSoPacket() header:");
		neko.Lib.println(h);
		neko.Lib.println("processSoPacket() packet:");
		neko.Lib.println(p);
		neko.Lib.println("processSoPacket() SOData:");
		neko.Lib.println(so);
		neko.Lib.println("----------------------------------------------------------------");
		*/
		var SOSetAttList:Array<Hash<Dynamic>> = new Array();

		for(cmd in so.commands) 
		{	
			switch(cmd) 
			{
			
				case SOConnect:
					if(so.name == null)
					{
						continue;
					}
					var nameparts = so.name.split("?");
					if(nameparts[0].length == 0)
					{
						continue;
					}
					server.subscribeSharedObject(this,appsdir+appName+sodir,nameparts[0],so.persist);
					
				case SODisconnect:
					var obj = Server.sharedObjects.get(so.name);
					obj.removeListener(this);
			
				case SOSetAttribute(key,value):
					var obj = Server.sharedObjects.get(so.name);
					if( obj == null ) 
					{
						return;
					}
					
					var SOSetAttCmd : Hash<Dynamic> = new Hash();
					SOSetAttCmd.set("client" , this);
					SOSetAttCmd.set("key" , key);
					SOSetAttCmd.set("value" , value);
					SOSetAttCmd.set("version" , obj.getVersion());
					SOSetAttList.push(SOSetAttCmd);
					
				case SOSendMessage(msg):
					var obj = Server.sharedObjects.get(so.name);
					obj.broadcast(p);
				
				default:
					neko.Lib.println("Unhandled incoming shared object packet: " + cmd);
			}
		}
		if( SOSetAttList.length > 0 )
		{
			var obj = Server.sharedObjects.get(so.name);
			obj.setAttributes(this,SOSetAttList);
		}
	}
	

	public function addSharedObjectEvent( p:RtmpPacket ) {
		//neko.Lib.println("SharedObjectEvent() RtmpPacket :" +p);
		var s = streams[0];
		s.objects.lock.acquire();
		if(s == null)
			throw("Unknown objects channel");
		if( s.cache == null ) {
			s.cache = new List();
			server.wakeUp(socket,0);
		}
		s.cache.add({ data : p, time : null });
		s.objects.lock.release();
	}

	function initSoStream() {
		// shared object 'stream'
		var s = {
			id : 0,
			channel : 3,
			play : null,
			record : null,
			audio : false,
			video : false,
			shared : null,
			cache : null,
			objects :{lock : new neko.vm.Mutex()}
		};
		streams[0] = s;
	}	
	
	function playObjects( s : RtmpStream ) {
		s.objects.lock.acquire();
		try {
			if( s.cache != null )
				while( true ) {
					var f = s.cache.pop();
					if( f == null ) {
						s.cache = null;
						break;
					}
					rtmp.send(s.channel,f.data);
					if( server.isBlocking(socket) )
						break;
				}
		}
		catch( e : Dynamic ) {
			s.objects.lock.release();
			neko.Lib.rethrow(e);
		}
		s.objects.lock.release();
	}

	public function getId():Int
	{
		return id;
	}

	public function getIp():String
	{
		return ip;
	}

	function invokeOnAllClients(f:String, o:Dynamic)
	{
		for (i in 0...clients.length)
		{
			clients[i].rtmp.send(3,PCall(f,0,[ANull,format.amf.Tools.encode(o)]));
		}
	}
}
