/* ************************************************************************ */
/*                                                                          */
/*  haXe Video                                                              */
/*  Copyright (c)2007 Nicolas Cannasse                                      */
/*  SharedObject contributed by Russell Weir                                */
/*                                                                          */
/* This library is free software; you can redistribute it and/or            */
/* modify it under the terms of the GNU Lesser General Public               */
/* License as published by the Free Software Foundation; either             */
/* version 2.1 of the License, or (at your option) any later version.       */
/*                                                                          */
/* This library is distributed in the hope that it will be useful,          */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        */
/* Lesser General Public License or the LICENSE file for more details.      */
/*                                                                          */
/* ************************************************************************ */

package hxvid;
import hxvid.Rtmp;
import hxvid.Client;
import format.amf.Value;
import format.amf.Tools;

enum SOCommand {
	SOConnect;//1
	SODisconnect;//2
	SOSetAttribute( name : String, value :Value );//3
	SOUpdateData( data : Hash<Value> );//4
	SOUpdateAttribute( name : String );//5
	SOSendMessage( msg : Array<Value> );//6 
	SOStatus( msg:String, type:String );//7
	SOClearData;//8
	SODeleteData( name : String );//9
	SODeleteAttribute( name : String );//0a
	SOInitialData;//0b
}

typedef SOData = {
	var name : String;
	var version : Int;
	var persist : Bool;
	var unknown : Int;
	var commands : List<SOCommand>;
}


class SharedObject 
{
	
	static function readString( i : haxe.io.Input ) 
	{
		return i.readString(i.readUInt16());
	}

	public static function read( i : haxe.io.Input, r : format.amf.Reader ) : SOData  
	{
		var name = readString(i);
		var ver = i.readUInt30();
		var persist = i.readUInt30() == 2;
		var unk = i.readUInt30();
		var cmds = new List();
		while( true )
		{
			var c = try i.readByte() catch( e : haxe.io.Eof ) break;			
			var size = i.readUInt30();
			var cmd = switch( c ) {
			case 1:
				SOConnect;
			case 2:
				SODisconnect;
			case 3:
				var name = readString(i);
				SOSetAttribute(name,r.read());
			case 4:
				var values = new haxe.io.BytesInput(i.read(size));
				var r = new format.amf.Reader(values);
				var hash = new Hash();
				while( true ) {
					var size = try values.readUInt16() catch( e : haxe.io.Eof ) break;
					var name = values.readString(size);
					hash.set(name,r.read());
				}
				SOUpdateData(hash);
			case 5:
				SOUpdateAttribute(readString(i));
			case 6:
				var values = new haxe.io.BytesInput(i.read(size));
				var r = new format.amf.Reader(values);
				var arr = new Array();
				while( true ) 
				{
					var msg = try r.read() catch( e : haxe.io.Eof ) break;
					arr.push(msg);
				}
				SOSendMessage(arr);
			case 7:
				var msg = readString(i);
				var type = readString(i);
				SOStatus(msg,type);
			case 8:
				SOClearData;
			case 9:
				SODeleteData(readString(i));
			case 10:
				SODeleteAttribute(readString(i));
			case 11:
				SOInitialData;
			}
			cmds.add(cmd);
		}
		return {
			name : name,
			version : ver,
			persist : persist,
			unknown : unk,
			commands : cmds,
		};
	}

	static function writeString( o : haxe.io.Output, s : String ) {
		o.writeUInt16(s.length);
		o.writeString(s);
	}

	static function writeCommandData( o : haxe.io.Output, w : format.amf.Writer, cmd ) {
		switch( cmd ) {
		case SOConnect,SODisconnect,SOClearData,SOInitialData:
			// nothing
		case SOSetAttribute(name,value):
			writeString(o,name);
			w.write(value);
		case SOUpdateData(data):
			for( k in data.keys() ) {
				writeString(o,k);
				w.write(data.get(k));
			}
		case SOUpdateAttribute(name):
			writeString(o,name);
		case SOSendMessage(msg):
			for (k in 0...msg.length)
			{
			
				w.write(msg[k]);
			}
		case SOStatus(msg, type):
			writeString(o,msg);
			writeString(o,type);
		case SODeleteData(name):
			writeString(o,name);
		case SODeleteAttribute(name):
			writeString(o,name);
		}
	}

	public static function write( o : haxe.io.Output, so : SOData ) {
		o.writeUInt16(so.name.length);
		o.writeString(so.name);
		o.writeUInt30(so.version);
		o.writeUInt30(so.persist?2:0);
		o.writeUInt30(so.unknown);
		for( cmd in so.commands ) {
			switch(cmd) {
			case SOConnect,SOClearData,SOInitialData:
				o.writeByte( Type.enumIndex(cmd) + 1 );
				o.writeUInt30(so.unknown);
			default:
				//SODisconnect,SODeleteData(name):
				//SOSetAttribute(name,value),SOUpdateData(data),
				//SOUpdateAttribute(name),SOSendMessage(msg),
				//SOStatus(msg,type),SODeleteAttribute(name):
				o.writeByte( Type.enumIndex(cmd) + 1 );
				var s = new haxe.io.BytesOutput();
				var w = new format.amf.Writer(s);
				writeCommandData(s,w,cmd);
				var data = s.getBytes();
				o.writeUInt30(data.length);
				o.write(data);
			}
		}
	}

	public static var SO_NO_READ_ACCESS	:String		= "SharedObject.NoReadAccess";
	public static var SO_NO_WRITE_ACCESS :String	= "SharedObject.NoWriteAccess";
	public static var SO_CREATION_FAILED :String	= "SharedObject.ObjectCreationFailed";
	public static var SO_PERSISTENCE_MISMATCH :String="SharedObject.BadPersistence";

	public var name(default,null) : String;
	public var persistent(default,null) : Bool;
	public var created(default,null) : Date;
	public var modified(default,null) : Bool;
	public var lastModified(default,null) : Date;

	var listeners : List<Client>;
	var data : Hash<format.amf.Value>;
	var dataCount : Int;
	var version : Int;
	var location:String;
	var lock : neko.vm.Mutex;
	var fOut : haxe.io.Output;
	var fIn : haxe.io.Input;

	public function new (name, persistent,location)
	{
		lock = new neko.vm.Mutex();
		
		this.name = name;
		this.persistent = persistent;
		this.location = location;
		this.version = 1;
		created = Date.now();
		modified = false;
		lastModified = Date.now();
		listeners = new List();
		initialize();
	}
	function initialize() 
	{
		data = new Hash();
		dataCount = 0;
		if(persistent)
		{
			if(neko.FileSystem.exists(location))
			{
				var bytes = neko.io.File.getBytes(location);
				var i = new haxe.io.BytesInput(bytes);
				var r = new format.amf.Reader(i);
				var content = r.read();
				var hashObject = format.amf.Tools.object(content);
				for (k in hashObject.keys())
				{
					dataCount++;
					data.set(k,hashObject.get(k));
				}
			}
		}
	}
	public function addListener(c : Client, persist:Bool) 
	{
		var cmds = new List<SOCommand>();
		lock.acquire();
		if(this.persistent != persist) 
		{
			cmds.add(SharedObject.errorStatus(SOErrPersist));
			try
			{
				c.addSharedObjectEvent(makePacket(cmds));
			}
			catch(e:Dynamic)
			{
				neko.Lib.println(e);
			}
			return;
		}
		listeners.remove(c);
		listeners.add(c);
		cmds.add(SOInitialData);
		if(!persistent) 
		{
			cmds.add(SOClearData);
		}
		//if(dataCount > 0)
		{ 
			for(k in data.keys()) 
			{
				var copy = new Hash<format.amf.Value>();
				copy.set(k, data.get(k));
				cmds.add(SOUpdateData(copy));
			}
		}
		try
		{
			c.addSharedObjectEvent(makePacket(cmds));
		}
		catch(e:Dynamic)
		{
			neko.Lib.println(e);
		}
		lock.release();
	}
	function makePacket(cmds:List<SOCommand>) 
	{
		if(cmds == null || cmds.length == 0)
		{
			throw "null or empty SOCommand list";
		}
		return PShared({name: name,	version: version, persist: persistent,	unknown: 0,	commands: cmds});
	}
	public function setAttributes(client:Client, a:Array<Dynamic>) 
	{
		var cmds = new List<SOCommand>();
		var cmdsC = new List<SOCommand>();
		lock.acquire();
		for (i in 0...a.length)
		{
			var key:String=a[i].get("key");
			var value=a[i].get("value");
			cmds.add(SOStatus("code1", "level1"));
			data.set(key,value);	
			cmds.add(SOUpdateAttribute(key));//send to owner
			
			var h = new Hash<format.amf.Value>();
			h.set(key,value);
			cmdsC.add(SOUpdateData(h));//send to everyone except the owner
		}
		version++;
		dataCount++;
		lastModified = Date.now();
		try
		{
			client.addSharedObjectEvent(makePacket(cmds));
		}
		catch (e:Dynamic)
		{
			neko.Lib.println(e);
		}
		broadcast(makePacket(cmdsC),client);
		//saveSharedObject();
		lock.release();
	}
	public function removeAttribute(name) {
		var cmds = new List<SOCommand>();
		lock.acquire();
		cmds.add(SODeleteAttribute(name));
		data.remove(name);
		dataCount--;
		broadcast(makePacket(cmds));
		//saveSharedObject();
		lock.release();
	}
	public function deleteAttributeData(name) {
		var cmds = new List<SOCommand>();
		lock.acquire();
		cmds.add(SODeleteData(name));
		if(data.exists(name))
			data.set(name,null);
		//dataCount--;
		broadcast(makePacket(cmds));
		//saveSharedObject();
		lock.release();
	}
	public function broadcast(p:RtmpPacket, ?ignore:Client) 
	{
		//neko.Lib.println("broadcast SharedObjectEvent: " + p);
		for(i in listeners) 
		{
			if(i != ignore)
			{
				try
				{
					i.addSharedObjectEvent(p);
				}
				catch (e:Dynamic)
				{
					neko.Lib.println(e);
				}
			}
		}
	}
	public function removeListener(c : Client) {
		lock.acquire();
		listeners.remove(c);
		if (listeners.length==0)
		{
			if(!persistent)
			{
				reset();
			}
			else
			{
				saveSharedObject();
			}
		}
		lock.release();
	}
	function saveSharedObject()
	{
		fOut = neko.io.File.write(location, true);
		var w = new format.amf.Writer(fOut);
	  w.write(AObject(data));
		fOut.close();
	}
	function reset()
	{
		data = new Hash();
		dataCount = 0;
	}
	public function getVersion():Int
	{
		return version;
	}
	public function hasAttribute(key) {
		return data.exists(key);
	}
	public function getAttribute(key) {
		return data.get(key);
	}
	public function listenerCount() : Int {
		return listeners.length;
	}
	function dataEncoded() {
		return AObject(data);
	}
	public static function errorStatus(msg) {
		return SOStatus(
			switch(msg) {
			case SOErrNoRead: SO_NO_READ_ACCESS;
			case SOErrNoWrite: SO_NO_WRITE_ACCESS;
			case SOErrCreate:  SO_CREATION_FAILED;
			case SOErrPersist: SO_PERSISTENCE_MISMATCH;
			},
			"error"
		);
	}
}
enum SOError {
	SOErrNoRead;
	SOErrNoWrite;
	SOErrCreate;
	SOErrPersist;
}