package hxIS.examples;

import comp.JButtonFramed;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.AsyncErrorEvent;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.Event;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.Video;
import flash.text.TextField;
import flash.Lib;
import tabssettings.SetBase;

class NsExample extends SetBase
{
	//webcam
	private var cam:Camera;
		
	//microphone
	private var mic:Microphone;
		
	//videos
	private var webcamPlayer:Video;		
	private var streamPlayer:Video;
		
	//NetConnection
	private var nc:NetConnection;
	
	//NetStreams
	private var nsPublish:NetStream;
	private var nsSubscribe:NetStream;
	
	//Buttons
	private var startPublishButton:JButtonFramed;
	private var stopPublishButton:JButtonFramed;
	private var publishSendButton:JButtonFramed;
	
	private var startSubscribeButton:JButtonFramed;
	private var stopSubscribeButton:JButtonFramed;
	private var pauseSubscribeButton:JButtonFramed;
	
	//trace/textfields
	private var tfPub:TextField;
	private var tfSub:TextField;
	var xPos = 10;
	var deltaX = 110;
	
	public function new()
	{
		super();
		//trace/textfields
		tfPub = new TextField();
		tfPub.x=50;
		tfPub.y=180;
		tfPub.width=300;
		tfPub.height=300;
		tfPub.multiline=true;
		tfPub.wordWrap=false;
		tfPub.border=true;
		tfPub.appendText('Connecting to hxIS...\n');
		addChild(tfPub);
		
		//trace/textfields
		tfSub = new TextField();
		tfSub.x=400;
		tfSub.y=180;
		tfSub.width=300;
		tfSub.height=300;
		tfSub.multiline=true;
		tfSub.wordWrap=false;
		tfSub.border=true;
		tfSub.appendText('Connecting to hxIS...\n');
		addChild(tfSub);
		
		//---Camera---
		cam = Camera.getCamera();
		
		//---MicroPhone---
		mic = Microphone.getMicrophone();
		
		//---Buttons---
		//------Publisher---
		startPublishButton = new StartPublishButton("ID_BUT_TEST_START", xPos += deltaX, 20, 100, 20, "Publish");
		startPublishButton.addEventListener(MouseEvent.CLICK, startPublish);
		addChild(startPublishButton);
		
		stopPublishButton = new StopPublishButton("ID_BUT_TEST_PUBLISH_STOP", xPos += deltaX, 20, 100, 20, "Stop");
		stopPublishButton.addEventListener(MouseEvent.CLICK, stopPublish);
		addChild(stopPublishButton);
		
		publishSendButton = new PublishSendButton("ID_BUT_TEST_SEND", xPos += deltaX, 20, 100, 20, "Send");
		publishSendButton.addEventListener(MouseEvent.CLICK, publishSend);
		addChild(publishSendButton);
			
		//------Subscriber---
		startSubscribeButton = new StartSubscribeButton("ID_BUT_TEST_SUBSCRIBE", xPos += deltaX, 20, 100, 20, "Subscribe");
		startSubscribeButton.addEventListener(MouseEvent.CLICK, startSubscribe);
		addChild(startSubscribeButton);
			
		stopSubscribeButton = new StopSubscribeButton("ID_BUT_TEST_SUBSCRIBE_STOP", xPos += deltaX, 20, 100, 20, "Stop");
		stopSubscribeButton.addEventListener(MouseEvent.CLICK, stopSubscribe);
		addChild(stopSubscribeButton);
			
		pauseSubscribeButton = new PauseSubscribeButton("ID_BUT_TEST_PAUSE", xPos += deltaX, 20, 100, 20, "Pause");
		pauseSubscribeButton.addEventListener(MouseEvent.CLICK, pauseSubscribe);
		addChild(pauseSubscribeButton);
		
		//---Videos---
		webcamPlayer = new Video();
		webcamPlayer.width = 160;
		webcamPlayer.height = 120;
		webcamPlayer.x = 40;
		webcamPlayer.y = 60;
		addChild(webcamPlayer);
		webcamPlayer.attachCamera(cam);
			
		streamPlayer = new Video();
		streamPlayer.width = 160;
		streamPlayer.height = 120;
		streamPlayer.x=350;
		streamPlayer.y=60;
		addChild(streamPlayer);
		
		//---NetConnection---
		nc = new NetConnection();
		nc.client=this;
		nc.objectEncoding = 0;
		nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
		nc.connect('rtmp://localhost:1935/testApp', {name:"someUsername"});//ip, port, appfoldername, arguments
	}
	//---NetConnection---
	private function onNetStatus(evt:NetStatusEvent):Void
	{
		switch(evt.info.code)
		{
			case 'NetConnection.Connect.Success':
				tfPub.appendText('NetConnection.Connect.Success\n');
				tfSub.appendText('NetConnection.Connect.Success\n');
				
				//---Publishing NetStream---
				nsPublish=new NetStream(nc);
				nsPublish.client=this;
				nsPublish.addEventListener(NetStatusEvent.NET_STATUS, onNsPubNetStatus);
				nsPublish.attachCamera(cam);
				nsPublish.attachAudio(mic);
				
				//---Subscribing NetStream---
				nsSubscribe=new NetStream(nc);
				nsSubscribe.client=this;
				nsSubscribe.addEventListener(NetStatusEvent.NET_STATUS, onNsSubNetStatus);
				streamPlayer.attachNetStream(nsSubscribe);
				
				
		
			case 'NetConnection.Connect.Closed':
				tfPub.appendText('NetConnection.Connect.Closed\n');
				tfSub.appendText('NetConnection.Connect.Closed\n');
				
			case 'NetConnection.Connect.Rejected':
				tfPub.appendText('NetConnection.Connect.Rejected\n');
				tfSub.appendText('NetConnection.Connect.Rejected\n');
				
			case 'NetConnection.Connect.Failed':
				tfPub.appendText('NetConnection.Connect.Failed\n');
				tfSub.appendText('NetConnection.Connect.Failed\n');
				
			default:
				tfPub.appendText(evt.info.code + '\n');
				tfSub.appendText(evt.info.code + '\n');
		}
	}
	
	//---Publishing stream handlers
	private function onNsPubNetStatus(evt:NetStatusEvent):Void
	{
		tfPub.appendText(evt.info.code + '\n');
	}
	
	//---Subscribing stream handlers
	private function onNsSubNetStatus(evt:NetStatusEvent):Void
	{
		tfSub.appendText(evt.info.code + '\n');
	}
	
	//---Button handlers Publisher---
	private function startPublish(evt:MouseEvent):Void
	{
		nsPublish.publish("my_movie", "record");
	}
	private function stopPublish(evt:MouseEvent):Void
	{
		nsPublish.publish(null,null);
	}
	private function publishSend(evt:MouseEvent):Void
	{
		nsPublish.send("sayName", {name:"someName"});
	}
	
	//---Button handlers Subscriber---
	private function startSubscribe(evt:MouseEvent):Void
	{
		nsSubscribe.play("my_movie");
	}
	private function stopSubscribe(evt:MouseEvent):Void
	{
		nsSubscribe.play(false);
	}
	private function pauseSubscribe(evt:MouseEvent):Void
	{
		nsSubscribe.togglePause();
	}
	
	public function sayName(obj:Dynamic):Void
	{
		tfSub.appendText('Publisher sends to all subscribers: '+ obj.name + '\n');
	}
	
	function asyncErrorHandler(event:AsyncErrorEvent):Void 
	{ 
	    //trace(event.text); 
	}
	
	// main
	static function main()
	{
			Lib.current.addChild(new NsExample());
	}
}

//button classes:
class StartPublishButton extends JButtonFramed{}
class StopPublishButton extends JButtonFramed{}
class PublishSendButton extends JButtonFramed{}
class StartSubscribeButton extends JButtonFramed{}
class StopSubscribeButton extends JButtonFramed{}
class PauseSubscribeButton extends JButtonFramed{}

