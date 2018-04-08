package com;
#if cpp
import com.ComBase.DataGram;
import cpp.Lib;
import haxe.db.Mysql;
//import cpp.vm.Lock;
import flash.events.EventDispatcher;
import error.Errors;

#elseif neko
import neko.vm.Lock;
#end

import flash.utils.Timer;
import haxe.io.Bytes;
//import openfl.utils.ByteArray;
//import haxe.io.BytesData;
import flash.utils.ByteArray;
import sound.Sounds;
import util.HexDump;
import events.PanelEvents;
import flash.events.Event;
import enums.Enums;
import flash.events.TimerEvent;
import flash.net.DatagramSocket;
import com.ComBase.DataGram;
import flash.events.DatagramSocketDataEvent;
import db.DBDefaults;
import util.NativeProcesses;

/**
 * ...
 * @author GM
 */
class ComUDPServer extends ComBase implements ItfCom
{
	var udpBroacast:DatagramSocket;
	var udpReceive:DatagramSocket;
	var byteArray:ByteArray;
	var binded:Bool;
	var strUDP:String;
	var dt:DataGram;
	var proxyRunning:Bool = false;
	var timerWatchDog:Timer;
	var dataReceivedCounter:Int;
	var stringsReceived:Array<String>;
	public var proxyConnectionAttempts:Int;

  	public function new() 
	{
		super();

		trace("New ComUDP");
		dt		= new DataGram();
		paramComIOTimeout = 100;
		createUDPToReceive(3839);
		createUDPToBroadcast(3840);
		startTimeoutTimer();
		strComName = "COM";
		proxyConnectionAttempts = 2;

		timerWatchDog 			= new Timer(1000);
		timerWatchDog.addEventListener(TimerEvent.TIMER, proxyWatchdog);
		timerWatchDog.start();
 		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PROXY_CONNECTED)); // 0 for all channels		return true;
	}

	/**
	 * 
	 */
	function createUDPToBroadcast(port:Int) 
	{
		strUDP = DBDefaults.getStringParam(Parameters.paramServerAddress);

		if (strUDP != null)
		{
			baUDPBroadcast 	= new ByteArray();
			udpBroacast 	= new DatagramSocket();
			udpBroacast.connect("127.0.0.1", port);
			Model.udpServer = this;
		}
		
		sendText('EVT_START,1');
	}

	/**
	 * 
	 */
	function createUDPToReceive(port:Int) 
	{
		strUDP = DBDefaults.getStringParam(Parameters.paramServerAddress);

		if (strUDP != null)
		{
			baUDPBroadcast		= new ByteArray();
			udpReceive			= new DatagramSocket();
			udpReceive.addEventListener(DatagramSocketDataEvent.DATA, dataReceived);
			udpReceive.bind(port);

			trace("DatagramSocket Supported : " + DatagramSocket.isSupported);
			trace("Bound : " + udpReceive.bound);
			udpReceive.receive();
 		}
	}

	/**
	 * 
	 */
	public function sendText(com:String) 
	{
		if (udpBroacast != null)
		{
			baUDPBroadcast.clear();
			baUDPBroadcast.writeUTFBytes(com);
			var test:Int = baUDPBroadcast.length;

			udpBroacast.send(baUDPBroadcast, 0, test);
		}
	}

	public function sendProxyCommand(b1:Int, b2:Int, b3:Int):Void
	{
		if (udpBroacast != null)
		{
			baUDPBroadcast.clear();
			//baUDPBroadcast.writeByte(ArduinoBase.START_SYSEX);
			baUDPBroadcast.writeByte(b1);
			baUDPBroadcast.writeByte(b2);
			baUDPBroadcast.writeByte(b3);
			//baUDPBroadcast.writeByte(ArduinoBase.END_SYSEX);
			var test:Int = baUDPBroadcast.length;

			udpBroacast.send(baUDPBroadcast, 0, test);
		}		
	}

	/**
	 * 
	 * @param	ba
	 */
	public function sendArduinoSysex(ba:ByteArray):Void
	{
		if (udpBroacast != null)
		{
			baUDPBroadcast.position = 0;
			baUDPBroadcast.writeByte(ArduinoBase.START_SYSEX);
			baUDPBroadcast.writeBytes(ba);
			baUDPBroadcast.writeByte(ArduinoBase.END_SYSEX);
			baUDPBroadcast.position = 0;
			var len:Int = baUDPBroadcast.length;

			udpBroacast.send(baUDPBroadcast, 0, len);
		}		
	}

	/**
	 * 
	 */
	function proxyWatchdog(e:TimerEvent):Void
	{
		return;
		sendProxyCommand(ArduinoBase.ARD_WATCHDOG_MESSAGE, DefaultParameters.arduinoComNumber, 0);
		sendProxyCommand(ArduinoBase.COM_WATCHDOG_MESSAGE, DefaultParameters.IOComNumber, 0);

		if (!proxyRunning)
		{
			if (proxyConnectionAttempts > 0)
			{
				proxyConnectionAttempts --;
			}
			else
			{
				if(!proxyRunning)
					NativeProcesses.execRPMProxy();
			}
		}
	}

	/**
	 * 
	 * @param	e
	 */
	function dataReceived(e:DatagramSocketDataEvent):Void 
	{
		proxyConnectionAttempts = 0;
		var len:Int = e.data.readInt();
		var str:String = e.data.readUTFBytes(len);

		switch(str)
		{
			case 'EVT_START'			: sendText('EVT_START'); return;
			case 'EVT_ARDUINO_CONNECTED': ArduinoConnected(stringsReceived[1]); return;
		}


		if (e.data.length < 4) // Command Data;
		//if (e.data.length < 28) // Command Data;
		{
			decodeCommandData(e.data);
		}
		else {
			if (e.data.length >= 4)
			{
				/*if (DefaultParameters.simulationMode && (dataReceivedCounter ++ < 4)) {
					return;
				}*/
				dataReceivedCounter = 0;
				dt.address 			=  cast e.data.readInt();
				dt.datagramNumber	=  cast e.data.readInt();
				dt.counter			=  cast e.data.readInt();
				dt.IOStatus			=  cast e.data.readInt();
				//trace(dt.datagramNumber);
				pushDatagram(dt);
				Main.model.IOStatus = dt.IOStatus;
				Main.model.refreshCnt++;
			}

			CheckChannelsAlarmsAndErrors();

			//Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_DATA_REFRESH, "DATA")); // 0 for all channels		return true;
		}
	}

	function ArduinoConnected(str:String) 
	{
		if (str.length > 0)
		{
			Model.arduino.initCom();
			sendText('OK');
		}
	}

	/**
	 * 
	 * @param	readInt
	 * @param	readInt1
	 */
	function decodeCommandData(ba:ByteArray) 
	{
		var str:String = ba.readUTFBytes(ba.length);
		trace (str);
		//switch (str) {
			//case '
		//}
		//if (bd.readByte() == 1)
		//{
			//proxyRunning = true;
		//}
	}

	/**
	 * 
	 * @return
	 */
	public override function getErrorOrigin(): ErrorOrigin
	{
		 return ErrorOrigin.ORIGIN_IP;
	}

	public override function isComOpened() : Bool
	{
		 return binded;
	}

	/**
	 * 
	 * @param	data
	 * @return
	 */
	public override function writeDataString(data:String) : Int
	{
		trace("UDPCom: Write " + data);
		return 1;
	}

	/**
	 * 
	 * @return
	 */
	public override function dataAvailable() : Bool
	{
		//var b:Bytes = Bytes.alloc(12);
		return true;
		//return socket.receive(b) > 11;
	}

	/**
	 * 
	 */
	public function isSimulatorBinded():Bool
	{
		return true;
	}
}