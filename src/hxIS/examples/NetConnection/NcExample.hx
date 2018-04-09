package;
import flash.display.Sprite;
import flash.events.NetStatusEvent;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.net.NetConnection;
import flash.net.Responder;
import flash.Lib;

class NcExample extends Sprite
{
	private var nc:NetConnection;
	private var resp:Responder;
	
	public function new()
	{
		super();
		trace('Connecting to hxIS...');
		nc = new NetConnection();
		nc.client = this;
		resp = new Responder(onServerReturn);
		nc.objectEncoding = 0;
		nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
		nc.connect('rtmp://localhost:1935/testApp', {name:"someUsername"});//ip, port, appfoldername, arguments
	}
	
	private function onNetStatus(evt:NetStatusEvent)
	{
		switch(evt.info.code)
		{
			case 'NetConnection.Connect.Success':
				trace('NetConnection.Connect.Success');
				doAllCalls();
		
			case 'NetConnection.Connect.Closed':
				trace('NetConnection.Connect.Closed');
				
			case 'NetConnection.Connect.Rejected':
				trace('NetConnection.Connect.Rejected');
				
			case 'NetConnection.Connect.Failed':
				trace('NetConnection.Connect.Failed');
				
			default:
				trace(evt.info.code);
		}
	}
	//Calling methods in the serverside script:
	function doAllCalls():Void
	{
		//1) no arguments, no return value:
		nc.call("function1",null);//function1 is a method in the serverside script. See command console for trace
		
		//2) arguments, no return value:
		nc.call("function2", null, { name:"john" });//function2 is a method in the serverside script. See command console for trace
			
		//3) arguments, return value:
		nc.call("function3",resp,10,20);
		
		//4) no arguments, no return value: Server will react by calling a method in this client script (receiveID)
		nc.call("function4",null);//function4 is a method in the serverside script. 
		
		//5) no arguments, no return value: 
		nc.call("function5",null);//Service.function0 is a method in the serverside script in the Service class. 
		
	}
	//3)server invokes method on client
	private function onServerReturn(obj:Dynamic):Void
	{
		trace("Asked server: sum of 10 and 20? ... Server returned:  " +obj.total);
	}
	function asyncErrorHandler(event:AsyncErrorEvent):Void 
	{ 
	    trace(event.text); 
	}
	
	//6) when someone disconnects, the server invokes the client side method 'clientLeft' on all connected clients
	public function clientLeft(obj:Dynamic):Void
	{
		trace("Server says that client with id: " + obj.id + " has left");
	}
	
	//4) server invokes method on client
	public function receiveId(obj:Dynamic):Void
	{
		trace("Your id: " + obj.id );
	}
	
	// main
	static function main():Void
	{
			Lib.current.addChild(new NcExample());
	}
}
