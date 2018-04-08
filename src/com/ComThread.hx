package com;
//import flash.concurrent.Mutex;
import flash.events.EventDispatcher;
import com.ComBase.ComThreadInfo;
import db.DBDefaults;
import enums.Enums;
import events.PanelEvents;
import flash.events.TimerEvent;
import com.ComUDPClient;
import com.ComBase.DataGram;
import flash.utils.Timer;

/**
 * ...
 * @author GM
 */
class ComThread extends EventDispatcher
{
	public var strComName	:String;
	public var timerPolling	:Timer;

	var comThreadInfo		:ComThreadInfo;
	var comServer			:ComBase;

	public function new() 
	{
		super();

		//comClient = new ComUDPClient();
		comServer 		= new ComUDPServer();
		timerPolling 	= new Timer(1000);
		timerPolling.addEventListener(TimerEvent.TIMER, onPolling);
		timerPolling.start();
	}
	
	private function onPolling(e:TimerEvent):Void 
	{
		comServer.sendComName("");
	}

	/**
	 * 
	 */
	public function getLastDatagram(address:Int):DataGram
	{
		var index:Int 	= comServer.datagramsArray.length - 1;
		var iter:Int 	= 0;
		var dt:DataGram = null;

		while (index > 0)
		{
			dt = comServer.datagramsArray[index];

			if (iter ++ > 8)
				break;

			if (dt.address == address)
			{
				break;
			}
			dt = null;

			index --;
		}

		return dt;
	}
}