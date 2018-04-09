package;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.NetConnection;
import flash.events.NetStatusEvent;
import flash.events.AsyncErrorEvent;
import flash.net.SharedObject;
import flash.events.SyncEvent;
import flash.events.Event;
import flash.Lib;

class SoExample extends Sprite
{
	var nc:NetConnection;
	var remoteSo:SharedObject;
	var ball:Sprite;
	
	public function new()
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		ball = new Sprite();
		ball.buttonMode = true;
		ball.graphics.lineStyle(1, 0);
    ball.graphics.beginFill(0xff0000);
		ball.graphics.drawCircle(50, 50, 50);
		ball.graphics.endFill();
		ball.addEventListener(MouseEvent.MOUSE_DOWN, ballPressHandler);
		ball.addEventListener(MouseEvent.MOUSE_UP, ballReleaseHandler);
		addChild(ball);
		
		nc = new NetConnection();
		nc.objectEncoding = 0;
		nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
		nc.client = this;
		trace('Connecting to hxIS...');
		nc.connect('rtmp://localhost:1935/testApp', {name:"someUserName"});//ip, port, appfolder name, args
	}
	private function onAddedToStage(event:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stageClickHandler);
	}

	//---ball---
	private function ballPressHandler(event:MouseEvent):Void
	{
		event.stopPropagation();
		ball.startDrag();
		stage.addEventListener(MouseEvent.MOUSE_MOVE, ballMoveHandler);
	}
	private function ballReleaseHandler(event:MouseEvent):Void
	{
		ball.stopDrag();
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, ballMoveHandler);
	}
	private function ballMoveHandler(event:MouseEvent):Void
	{
		remoteSo.setProperty("ballX", ball.x);
		remoteSo.setProperty("ballY", ball.y);
	}
	
	//---NetConnection---
	private function onNetStatus(event:NetStatusEvent):Void
	{
		switch(event.info.code)
		{
			case 'NetConnection.Connect.Success':
				createSharedObject();
				trace('NetConnection.Connect.Success');
		
			case 'NetConnection.Connect.Closed':
				trace('NetConnection.Connect.Closed');
				
			case 'NetConnection.Connect.Rejected':
				trace('NetConnection.Connect.Rejected');
				
			case 'NetConnection.Connect.Failed':
				trace('NetConnection.Connect.Failed');
				
			default:
				trace(event.info.code);
		}
	}
	function asyncErrorHandler(event:AsyncErrorEvent):Void 
	{ 
	    //trace(event.text); 
	}
	
	//---SharedObject---
	private function createSharedObject()
	{
		remoteSo = SharedObject.getRemote("rso", nc.uri, true);
		remoteSo.addEventListener(SyncEvent.SYNC,syncronize);
		remoteSo.client = this;
		remoteSo.connect(nc);
	}
	private function syncronize(event:SyncEvent)
	{
		trace('onSync');
		ball.x = remoteSo.data.ballX;
		ball.y = remoteSo.data.ballY;
	}
	public function placeBall(x:Int, y:Int)
	{
		trace('remoteSo.send("placeBall", stage.mouseX, stage.mouseY)');
		ball.x = x - ball.width/2;
		ball.y = y - ball.height/2;
	}
	private function stageClickHandler(event:MouseEvent)
	{
		remoteSo.send('placeBall', stage.mouseX, stage.mouseY);
	}
	
	// main
	static function main()
	{
		Lib.current.addChild(new SoExample());
	}
}
