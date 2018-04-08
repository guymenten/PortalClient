package com;

import com.ComBase.DataGram;
import data.DataObject;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.ChannelState;
import enums.Enums.ErrorCode;
import enums.Enums.ErrorOrigin;
import enums.Enums.ErrorSeverity;
import enums.Enums.ErrorStates;
import enums.Enums.Parameters;
import error.Errors;
import events.PanelEvents;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.Timer;

//import flash.concurrent.Mutex;
//import hxSerial.Serial;
//import com.quetwo.Arduino.ArduinoConnector;

/**
 * ...
 * @author GM
 */
class ComThreadInfo  // Info block used for Communication Thread
{
	public var datagram:DataGram;
	public var pollingTime:Float; // One second is : 1
	public var strComChannel:String;

	public function new(strComChannelIn:String, polTime:Float = 0.3):Void 
	{
		datagram		= new DataGram();
		strComChannel	= strComChannelIn;
		pollingTime		= polTime;
	}
}

class DataGram
{
	public var address:Int;
	public var counter:Int;
	public var IOStatus:Int;
	public var datagramNumber:Int;
	public var requestNumber:Int;
	public var error:ErrorCode;
	public var threshold:Int;
	public var noise:Int;
	public var time:Date;

	public function new():Void 
	{
	}

	/**
	 * 
	 */
	public function trace()
	{
		//trace("address 			: " + address);
		//trace("counter 			: " + counter);
		//trace("datagramNumber 	: " + datagramNumber);
		//trace("threshold	 	: " + threshold);
		//trace("time : " + time);
	}
}

/**
 * 
 */
class Command
{
	public var srcAddress:Int		= 32;		// Source Address
	public var destAddress:Int		= 80;		// Destination Address
	public var shCommand:Int		= 0xd424;	// Command Value

	public function new(destIn:Int, cmdIn:Int) 
	{
		destAddress = destIn;
		shCommand = cmdIn;
	}
}

class ComBase extends EventDispatcher implements ItfCom
{
	public var timerTimeout:Timer;
	public var paramComIOTimeout:Int;
	public var strBufferStart:ByteArray;			// Byte Array To Send the Command
	public var cmdIndex:Int 		= 0;			// Command Index in stackedCommandsArray
	public var strOutBuffer:ByteArray;				// Byte Array To Send the Command
	public var strComName:String;
	private var pollingTime:Int;
	private var stackedCommandsArray:Array<Command>;
	private var sendingError:Bool;
	private var packetCounter:Int;
	public var datagramsArray:Array<DataGram>;
	public var previousDatagramNumber:Int;

	var timeoutBeforeAlarm:Int;

	var channelsInError:Int = 0;
	var previousChannelsInError:Int = -1;

	var channelsInTimeout:Int = 0;
	var channelsInHigh:Int = 0;
	var previousChannelsInTimeout:Int = 0;
	var lowErrorEnabled:Bool;

	var channelsInRAAlarm:Int = 0;
	var previousChannelsInRAAlarm:Int = 0;

	var channelsinRAAlarmToAcknowledged:Int = 0;
	var previousAlarmsRANotAcknowledged:Int = 0;

	var baUDPBroadcast:ByteArray;
	var validData:Bool;
	var minimumChannelsToWork:Int;
	var strComBrol:String;

	/**
	 * Constructor
	 */
	public function new() 
	{
		super();

		strComBrol 				= DBTranslations.getText("IDS_BUT_MONITOR");
		strBufferStart 			= new ByteArray();
		timeoutBeforeAlarm 		= DBDefaults.getIntParam(Parameters.paramTimeoutBeforeAlarm);
		minimumChannelsToWork	= 2;

		stackedCommandsArray 	= new Array<Command>();
		strOutBuffer 			= new ByteArray();
		strOutBuffer.endian 	= Endian.LITTLE_ENDIAN; // LSB First
		datagramsArray 			= new Array();

		timerTimeout 			= new Timer(1000);
	}

	/**
	 * 
	 * @return
	 */
	public function startTimeoutTimer():Bool
	{
		timerTimeout.addEventListener(TimerEvent.TIMER, incrementTimeout);		
		timerTimeout.start();

		return true;
	}

	/**
	 * 
	 * @param	e
	 */
	private function incrementTimeout(e:TimerEvent):Void 
	{
		for (dao in Model.channelsArray)
			incrementChannelTimeout(dao);

		for (dao in Model.IOsArray)
			incrementChannelTimeout(dao);
	}

	/**
	 * 
	 * @param	dt
	 */
	public function pushDatagram(dt:DataGram):Void
	{
		dt.time = Date.now();
		//trace("Address : " + dt.address);
		var dao:DataObject = Model.channelsArray.get(Std.string(dt.address));
		dao.counter			= dt.counter;
		dao.IOStatus		= dt.IOStatus;
		dao.datagramNumber	= dt.datagramNumber;
		dao.timeout			= 0;
		dao.processCurrentValue();

/*		for (dao in Model.channelsArray)
		{
			trace("Address: " + dt.address);
			if (dao.address == dt.address)
			{
				dt.noise			= dao.noise;
				dt.threshold		= dao.threshold;
				dt.requestNumber	= dao.requestNumber;
				dao.counter			= dt.counter;
				dao.IOStatus		= dt.IOStatus;
				dao.datagramNumber	= dt.datagramNumber;

				if (dao.datagramNumber != dao.oldDatagramNumber)
				{
					dao.timeout					= 0;
					dao.oldDatagramNumber 	= dt.datagramNumber;
				}
				else {
						//trace("Timeout Increment: " + dao.timeout);
				}

				dao.processCurrentValue();
			}
		}

		datagramsArray.push(dt);

		if (datagramsArray.length >= DefaultParameters.datagramsArrayLenght)
		{
			datagramsArray.shift(); // remove the first element
		}*/
	}

	/**
	 * 
	 * @return
	 */
	public function isComOpened() : Bool
	{
		trace(throw("isComOpened not implemented"));
		return false;
	}

	public function isIOAddress(value:Int):Bool
	{
		return value == Model.IOAddress;
	}

	public function getErrorOrigin() : ErrorOrigin
	{
		trace(throw("getErrorOrigin not implemented"));
		return null;
	}

	public function dataAvailable() : Bool
	{
		trace(throw("dataAvailable not implemented"));
		return false;
	}

	public function sendComName(com:String):Void
	{
		
	}

	public function onGetDataBeforeNextPolling(e:TimerEvent):Void
	{
		trace(throw("onGetDataBeforeNextPolling not implemented"));
	}

	public function initCom() : Bool
	{
		trace(throw("initCom not implemented"));
		return false;
	}

	public function isComEnabled() : Bool
	{
		trace(throw("isComEnabled not implemented"));
		return false;
	}

	public function writeDataString(data:String) : Int
	{
		trace(throw("writeDataString not implemented"));
		return 0;
	}

	/**
	 * 
	 * @param	cmd
	 */
	private function stackCommand(addrIn: Int, cmdIn:Int)
	{
		//trace("stackCommand " + addrIn);
		stackedCommandsArray.push(new Command(addrIn, cmdIn));
	}

	public function sendIOCardRequest()
	{
	}

	/**
	 * 
	 */
	public function CheckChannelsAlarmsAndErrors()
	{
		var channels:Int 					= 0;
		channelsInTimeout 					= 0;
		channelsInError 					= 0;
		channelsInRAAlarm 					= 0;
		channelsinRAAlarmToAcknowledged 	= 0;

		for (dao in Model.channelsArray)
		{
			channels ++;
			dao.requestNumber ++;

			if (dao.enabled)
			{
				if (dao.timeout > timeoutBeforeAlarm) 
					channelsInTimeout ++;

				if (dao.channelState == ChannelState.ERROR)
					dao.inErrorAllowed ? channelsInError ++ : channelsInError = channels;

				if (dao.channelState == ChannelState.LOW)
					channelsInError ++;

				if (dao.inRAAlarm)
					channelsInRAAlarm ++;

				if (dao.inRAAlarm)
					channelsinRAAlarmToAcknowledged ++;
			}
		}

		setTimeoutError(channels);
		setValueError(channels);
		setRAAlarms(channelsInRAAlarm);
		setErrors(channels);
	}

	/**
	 * 
	 */
	public function setRAAlarms(channels:Int): Void
	{
		Main.model.channelsinRA = channels;
		//if (Main.model.isInitialized())
		//{
			//if (channelsInRAAlarm != previousChannelsInRAAlarm)
			//{
				//previousChannelsInRAAlarm = channelsInRAAlarm;
//
				//Main.model.changeInRAAlarmsDetected(channelsInRAAlarm, channelsinRAAlarmToAcknowledged);
			//}
		//}
	}

	/**
	 * 
	 */
	public function setErrors(channels:Int): Void
	{
		if ((previousChannelsInError > 0) != (channelsInError > 0))
		{
			trace("previousChannelsInError : " + channelsInError);
			previousChannelsInError = channelsInError;
		}
	}

	/**
	 *
	 */
	public function setValueError(channels:Int): Void
	{
		if (previousChannelsInError != channelsInError)
		{
			Main.model.allChannelsOUT 	= (channelsInTimeout == channels) || (channelsInError == channels);
			previousChannelsInError 					= channelsInError;
			var severity 								= (channels - channelsInError) > minimumChannelsToWork ? ErrorSeverity.WARNING : ErrorSeverity.SEVERE;
			var inError:Bool 							= channelsInError > 0;
			var inTimeout:Bool 							= channelsInTimeout > 0;

			Main.root1.dispatchEvent(new Event(inError ? PanelEvents.EVT_COM_OFF : PanelEvents.EVT_COM_ON));

			if(!inTimeout)
				Errors.dispatchError(inError ? PanelEvents.EVT_ERROR_SET : PanelEvents.EVT_ERROR_ACK, getErrorOrigin(),
						ErrorCode.ERROR_INVALID_DATA, inError ? ErrorStates.TRUE :  ErrorStates.FALSE, severity, strComBrol);
			//}
		}
	}

	/**
	 *
	 * @param	channels
	 */
	public function setTimeoutError(channels:Int): Void
	{
		if (previousChannelsInTimeout != channelsInTimeout)
		{
			Main.model.allChannelsOUT	= (channelsInTimeout == channels) || (channelsInError == channels);
			previousChannelsInTimeout					= channelsInTimeout;
			var severity 								= (channels - channelsInError > minimumChannelsToWork) ? ErrorSeverity.SEVERE : ErrorSeverity.WARNING;
			var inTimeout:Bool 							= channelsInTimeout > 0;

			Main.root1.dispatchEvent(new Event(inTimeout ? PanelEvents.EVT_COM_OFF : PanelEvents.EVT_COM_ON));
			validData = !inTimeout;

			if (channelsInTimeout == 0) setChannelsStates(ChannelState.OK);

			Errors.dispatchError(inTimeout ? PanelEvents.EVT_ERROR_SET : PanelEvents.EVT_ERROR_ACK, getErrorOrigin(),
				ErrorCode.ERROR_TIMEOUT, inTimeout ? ErrorStates.TRUE :  ErrorStates.FALSE, ErrorSeverity.SEVERE, getParameter1());
		}
	}

	/**
	 * 
	 * @param	state
	 */
	function setChannelsStates(state:ChannelState) 
	{
		for (dao in Model.channelsArray)
		{
			dao.setChannelState(state);
		}
	}

	/**
	 * 
	 */
	function onTimeoutLatencyElapsed() 
	{
		validData = true;
	}

	function getParameter1():String {
		return strComName;
	}

	/**
	 * 
	 * @param	sent
	 */
	public function setComError(sent:Int): Void
	{	
		if (sent == 0) // No bytes sent: Error
		{
			if (!sendingError)
			{
				sendingError = true;
				trace("SetComError(SEVERE)");
				Errors.dispatchError(PanelEvents.EVT_ERROR_SET, getErrorOrigin(), ErrorCode.ERROR_DATA_NOT_SEND, ErrorStates.TRUE, ErrorSeverity.SEVERE);
			}
		}

		else {
			if (sendingError)
			{
				sendingError = false;
				Errors.dispatchError(PanelEvents.EVT_ERROR_ACK, getErrorOrigin(), ErrorCode.ERROR_DATA_NOT_SEND, ErrorStates.FALSE,  ErrorSeverity.SEVERE);				
			}
		}
	}

	/**
	 * 
	 * @param	dataObject
	 */
	public function incrementChannelTimeout(dataObject:DataObject) 
	{
		if (dataObject.enabled)
		{
			//trace("dataObject.timeout : " + dataObject.timeout);
			if (dataObject.timeout ++ > timeoutBeforeAlarm)
			{
				if (dataObject.channelState != ChannelState.TIMEOUT)
				{
					dataObject.timeoutErrors ++;
					dataObject.setChannelState(ChannelState.TIMEOUT);
					Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_DATA_REFRESH, "DATA")); // 0 for all channels		return true;
					Main.root1.dispatchEvent(new StateMachineEvent()); // 0 for all channels		return true;
				}
				CheckChannelsAlarmsAndErrors();
			}
		}
	}
}