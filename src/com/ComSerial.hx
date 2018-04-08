package com;

import com.ComBase.ComThreadInfo;
import com.ComBase.DataGram;
import db.DBLog.Log;
import db.DBLog.LogData;
import error.Errors;
import events.PanelEvents;
import flash.events.Event;
import flash.utils.ByteArray;
import db.DBTranslations;

#if neko
#elseif cpp
//import cpp.Sys;
#end

/**
 * Communication class for serial Line (via	USB port)
 */
class ComSerial extends ComBase
{
	public var serialLine:SerialBase;
	var dataByteArray:ByteArray;
	public var iParameters:Array<Int>;

	public function new(strCom:String)
	{
		super();

		strComName = strCom;

		//trace("New ComSerial");
		dataByteArray = new ByteArray();
		iParameters = new Array<Int>();

		//stackCommand(Model.IOAddress, 0x20);
		for (channel in Model.channelsArray)
			stackCommand(channel.address, 0x26);	 // Counter polling

		stackCommand(Model.IOAddress, 0x20);

		createSerialLine();

		Main.root.addEventListener(PanelEvents.EVT_APP_EXIT, OnExit);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnExit(e:Event):Void 
	{
		serialLine.close();
	}

	/**
	 * Fill the commanb Block to Send
	 */
	private function fillStartCommandIO() 
	{
		// Start initialization command prior to get position Switches values
		strBufferStart.writeByte(0x02);
		strBufferStart.writeByte(0x58);
		strBufferStart.writeByte(0xFF);
		strBufferStart.writeByte(0xCC);
		strBufferStart.writeByte(0x20);
		strBufferStart.writeByte(0xC3);
		strBufferStart.writeByte(0x82);
	}

	/**
	 * 
	 */
	public override function sendIOCardRequest()
	{
		//trace("sendIOCardRequest()");
		serialLine.comPort.writeBytes(strBufferStart.toString());
	}

	/**
	 * 
	 * @return
	 */
	override function initCom():Bool
	{
		var init:Bool =  serialLine.initCom();
		//trace("InitCom Result : " + init);

		return init;
	}

	public override function isComOpened() : Bool
	{
		if (!serialLine.comPort.isSetup)
		{
			var er:Error =  new Error(ErrorCode.ERROR_DEVICE_NOT_FOUND, getErrorOrigin(), ErrorStates.STATUS_TRUE, ErrorSeverity.SEVERE, "IDS_LOG_COM_NOT_OPENED");
			Log.logMessage(new LogData(Date.now().toString(), er));
			initCom();
		}

		return serialLine.comPort.isSetup;
	}

	function createSerialLine():Void
	{
		serialLine = new SerialBase(strComName, 19200);
		fillStartCommandIO();

		if(initCom())
			sendIOCardRequest(); // init I/O Card if com OK
	}

	public override function getErrorOrigin(): ErrorOrigin
	{
		 return ErrorOrigin.ORIGIN_SERIAL;
	}

	/**
	 * 
	 */
	public function sendFirstStackedCommand():Void
	{
		cmdIndex = 0;
		sendNextStackedCommand();
	}

	/**
	 * 
	 * @return
	 */
	public function sendNextStackedCommand():Bool
	{
		if (cmdIndex < stackedCommandsArray.length)
			return sendCommand(stackedCommandsArray[cmdIndex ++]);

		return false;
	}

	/**
	 * 
	 * @param	data
	 * @return
	 */
	public override function writeDataString(data:String) : Int
	{
		if (isComOpened())
		{
			//trace(HexDump.dumpString(data));
			return serialLine.comPort.writeBytes(data);
		}
		else
			return 0;
	}

	/**
	 * 
	 * @return
	 */
	public override function dataAvailable() : Bool
	{
		return serialLine.comPort.available() > 0;
	}

	/**
	 * 
	 * @param	iStartPos
	 * @return
	 */
	function decodeParametersData(pos:Int):Int
	{
		var iValue:Int = 0;
		var iParamNumber:Int;

		var paramType:Int		= (dataByteArray[pos + 3] & 0x38) >> 3;
		var iParamNumber:Int	= dataByteArray[pos + 4] - 32;

		//trace("decodeParametersData, position : " + pos);
		//trace ("iParamNumber : " + iParamNumber);
		//trace ("paramType : " + paramType);
		pos += 6;

		switch (paramType) 
		{
			case 1 : iValue = (dataByteArray[pos + 1] - 128) * 16 +  (dataByteArray[pos] - 128) ; // Byte
			case 2 : iValue = (dataByteArray[pos + 3] - 128) * 4096 + (dataByteArray[pos + 2] - 128) * 256 + (dataByteArray[pos + 1] - 128) * 16 + (dataByteArray[pos] - 128) ;	// Word
			//case 3 : iPos = 0; // Long
			//case 4 : iPos = 0; // Float
			//case 5 : iPos = 0; // String
			default:
		}
		
		//trace ("iValue : " + iValue);

		iParameters[iParamNumber] = iValue;

		return 12;
	}

	/**
	 * 
	 * @return
	 */
	function decodeDataGram(pos:Int):DataGram 
	{
		dataByteArray.position = 0;
		//trace(HexDump.dumpString(dataByteArray.readUTFBytes(dataByteArray.bytesAvailable)));
		dataByteArray.position = pos;

		var dataGram:DataGram = new DataGram();
		dataGram.address = dataByteArray[pos + 2];
		var bIOData:Bool = isIOAddress(dataGram.address);
		//trace("Address : " + dataGram.address);

		if (bIOData)
		{
			Model.IOStatus = (dataByteArray[pos +6] & 7) >> 1;
			//Model.stateMachine.setPortalBusy(IOStatus != 3);
			pos += 15;
		}
		else
		{
			pos += decodeParametersData(pos);
			dataGram.counter = iParameters[6];
		}

		dataGram.IOStatus = Model.IOStatus;

		return dataGram;
	}

	/**
	 * 
	 */
	override function onGetDataBeforeNextPolling(threadInfo:ComThreadInfo):Bool
	{
		var bytesReceived:Int = serialLine.comPort.available();
		//trace("Bytes received : " + bytesReceived);

		if (bytesReceived > 0)
		{
			dataByteArray.clear();
			dataByteArray.writeUTFBytes(serialLine.comPort.readBytes(bytesReceived));
			serialLine.comPort.flush(true, true);
			decodeReceivedDatagrams(threadInfo);
		}

		CheckChannelsAlarmsAndErrors();

		sendFirstStackedCommand();

		while (sendNextStackedCommand())
		{
		}

		return bytesReceived > 0;
	}

	/**
	 * 
	 * @param	readBytes
	 */
	function decodeReceivedDatagrams(threadInfo:ComThreadInfo):Void
	{
		var STX:Int = 2;  //Start of Text Character
		var index:Int = 0;
		var packetPointers:Array<Int> = new Array<Int>();

		dataByteArray.position = 0;
		//trace(HexDump.dumpString(dataByteArray.readUTFBytes(dataByteArray.bytesAvailable)));

		dataByteArray.position = 0;

		for (index in 0...dataByteArray.length - 1)
		{
			if (dataByteArray[index] == STX)
			{
				packetPointers.push(index);
			}
		}

		packetPointers.push(dataByteArray.length); // Last byte pointer

		var startIndex:Int = packetPointers[0];
		index = 1;

		for (packetPointer in packetPointers)
		{
			dataByteArray.position = startIndex;
			startIndex = packetPointer;

			if (checkCheckSum(startIndex, packetPointers[index]))
			{
				// Get datagram
				if (validData)
					pushDatagram(decodeDataGram(startIndex));
				index ++;
			}
			else
				return;
		}
	}

	/**
	 * 
	 */
	function checkCheckSum(startIndex:Int, endIndex:Int) :Bool
	{
		if ((endIndex - startIndex) < 10)
		{
			return false;
		}

		var sum:Int = 0;

		dataByteArray.position = startIndex;

		for (index in startIndex + 1 ... endIndex - 2)
			sum += dataByteArray[index];

		var chkSum:Int = sum | 0x8080;
		var chkSumIn:Int = (dataByteArray[endIndex -2] + dataByteArray[endIndex -1] * 256) | 0x8080;

		if (chkSum != chkSumIn)
		{
			if (Model.communicationStarted)
			{
				Model.checksumErrors ++;
				Errors.sendErrorMessage(new ErrorInfo(DBTranslations.getText("IDS_CRC_ERRORS")));
			}
			else {
				Model.communicationStarted = true;
			}

			return false; 
		}
		return true;	
	}
}
