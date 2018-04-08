package com;

import data.DataObject;
import db.DBDefaults;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

#if cpp
//import hxSerial.Serial;
#end

import flash.events.EventDispatcher;
import flash.events.Event;
import events.PanelEvents;
import error.Errors;

/**
 * ...
 * @author GM
 */

class SerialBase extends EventDispatcher
{
	//public  var comPort:hxSerial.Serial;
	private var comPortName:String;
	private var comSpeed:Int;

	private var devicesList:Array<String>;

	public function new(comPortNameIn:String, comSpeedIn:Int) 
	{
		super();

		//trace("PPPPPPPPPPPPPPP comPortNameIn: " + comPortNameIn);
		//trace("PPPPPPPPPPPPPPP comSpeedIn: " + comSpeedIn);
		comPortName = comPortNameIn;
		trace(" New comPortNameIn : " + comPortName);
		comSpeed = comSpeedIn;

		Main.root1.addEventListener(PanelEvents.EVT_ERROR_SET, OnErrorSet);
	}

	private function OnErrorSet(e:ErrorEvent):Void 
	{
		//trace("Serial Initialization");

		if (Errors.comInError)
		{
			//trace("comInError");
			close();
			initCom();
		}
	}

	public function close(): Void
	{

	}

	public function initCom(): Bool
	{
		//trace("Init Com Device ...");

		try {
			//devicesList = Serial.getDeviceList();
		}

		catch ( unknown : Dynamic ) {
			//trace(("Unknown exception : "+ Std.string(unknown));
		}

		////trace(("Device list : " );

		var found = true;

		//for ( txt in devicesList )
		//{
			//found =  (txt.indexOf(comPortName) >= 0);
		//}

		//if (found)
		//{
			//close();
			//trace("comPortNameIn : " + comPortName);
			//comPort = new Serial(comPortName, comSpeed, true); // Init
//
			//return comPort.isSetup;
		//}

		return false;
	}
}