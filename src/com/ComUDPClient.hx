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

import haxe.io.Bytes;
import haxe.io.BytesInput;
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

/**
 * ...
 * @author GM
 */
class ComUDPClient extends ComBase implements ItfCom
{
	var udpBroacast	:DatagramSocket;
	var udpReceive	:DatagramSocket;
	var binded		:Bool;
	var strUDP		:String;
	var UDPCounter	:Int;
	var dt			:DataGram;

  	public function new() 
	{
		super();

		var dt:DataGram		= new DataGram();
		trace("New ComUDP");
		paramComIOTimeout = 500;
		createUDPToReceive();
		startTimeoutTimer();
  	}

	/**
	 * 
	 */
	function createUDPToBroadcast() 
	{
		strUDP = DBDefaults.getStringParam(Parameters.paramServerAddress);

		if (strUDP != null)
		{
			baUDPBroadcast = new ByteArray();
			udpBroacast = new DatagramSocket();
			udpBroacast.connect("192.168.1.6", 3838);
		}
	}

	/**
	 * 
	 */
	function createUDPToReceive() 
	{
		strUDP = DBDefaults.getStringParam(Parameters.paramServerAddress);

		if (strUDP != null)
		{
			udpReceive			= new DatagramSocket();
			udpReceive.addEventListener(DatagramSocketDataEvent.DATA, dataReceived);
			udpReceive.bind(3839);

			trace("DatagramSocket Supported : " + DatagramSocket.isSupported);
			trace("Bound : " + udpReceive.bound);
			udpReceive.receive();
 		}
	}

	/**
	 * 
	 * @param	e
	 */
	function dataReceived(e:DatagramSocketDataEvent):Void 
	{
		UDPCounter++;
		//trace("Data received : " + UDPCounter);

		dt.address 			=  cast e.data.readInt();
		dt.counter 			=  cast e.data.readInt();
		dt.datagramNumber	=  cast e.data.readInt();
		dt.IOStatus			=  cast e.data.readInt();
		dt.trace();
		pushDatagram(dt);
		Main.model.IOStatus = dt.IOStatus;

		dt					= new DataGram();
		dt.address 			=  cast e.data.readInt();
		dt.counter			=  cast e.data.readInt();
		dt.datagramNumber	=  cast e.data.readInt();
		dt.IOStatus			=  cast e.data.readInt();
		dt.trace();
		pushDatagram(dt);

		dt					= new DataGram();
		dt.address 			=  cast e.data.readInt();
		dt.counter			=  cast e.data.readInt();
		dt.datagramNumber	=  cast e.data.readInt();
		dt.IOStatus			=  cast e.data.readInt();
		dt.trace();
		pushDatagram(dt);

		CheckChannelsAlarmsAndErrors();
		Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_DATA_REFRESH, "DATA")); // 0 for all channels		return true;
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
	 */
	public function isSimulatorBinded():Bool
	{
		return true;
	}
}