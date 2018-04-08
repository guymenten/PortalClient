/*
* Version: MPL 1.1
*
* The contents of this file are subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use this file except in compliance with
* the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is ArduinoConnector.as
*
* The Initial Developer of the Original Code is Nicholas Kwiatkowski.
* Portions created by the Initial Developer are Copyright (C) 2011
* the Initial Developer. All Rights Reserved.
*
* The Assistant Developer is Ellis Elkins on behalf of DirectAthletics.
* Portions created by the Assistant Developer are Copyright (C) 2013
* DirectAthletics. All Rights Reserved.
*
* Updated 2012-03-15 - File Handlers updated so we can use > 16 ComPorts.  
*     Because > 16 COM Ports is not valid with all Win OSs, the getComPorts() will not
*     be updated to reflect this support.
* Updated 2012-01-04  -  Added the ability to enable DTR Control when port is opened.
*     Also added the reinitiate function to allow reloading of the native code.
*
*/

package com.quetwo.ser;

import com.quetwo.ser.ArduinoConnectorEvent;
import flash.events.ProgressEvent;
import flash.external.ExtensionContext;
import flash.filesystem.File;
import flash.system.SecurityDomain;
import flash.system.System;
import flash.display.LoaderInfo;
import flash.system.ApplicationDomain;
import flash.system.Security;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.StatusEvent;
import flash.utils.ByteArray;

//[Event(name="socketData", type="com.quetwo.arduino.ArduinoConnectorEvent")]

class ArduinoConnector extends EventDispatcher
{
	
	private var   _ExtensionContext:ExtensionContext;
	private var   _comPort:Float;
	private var   _baud:Float;
	/** Whether to enable DTR Control for the serial connection. */		
	private var   _useDtrControl:Bool;
	private var   _portOpen:Bool = false;
	private var   _bytesAvailable:Float = 0;
	
	/**
	 *
	 * The ArduinoConnector constructor. Initiates native code.
	 * 
	 */
	public function new()
	{
		super();
		initiate();
	}

	/**
	 * This will initilize the native code.
	 * 
	 */	
	function initiate():Void
	{
		trace("[ArduinoConnector] Initalizing ANE...");
		try
		{
			//Security.allowDomain('*');
			var brol:Dynamic = ApplicationDomain.currentDomain;
			var test:String = SecurityDomain.currentDomain.domainID;
			var file:File = ExtensionContext.getExtensionDirectory("com.quetwo.Arduino.ArduinoConnector");
			_ExtensionContext = ExtensionContext.createExtensionContext("com.quetwo.Arduino.ArduinoConnector", "");
			_ExtensionContext.addEventListener(StatusEvent.STATUS, gotEvent);				
		}
		catch (e:Dynamic)
		{
			trace(e.message);
			trace("[ArduinoConnector] Unable to load the .DLL!  Make sure libSerialANE.DLL and PthreadGC2.dll are available.");
			trace("[ArduinoConnector] ANE Not loaded properly.  Future calls will fail.");
		}
	}

	/**
	 * 
	 * This is where you set the communications port and baud rate.  If there is an issue opening up the communications port the portOpen property
	 * will be false, and the function will return false.  You should check this before attempting to communicate with the Arduino.
	 * 
	 * @param comPort          This is the communications port that the Arduino is connected to.  Call getComPorts() to get a valid list for this OS
	 * @param baud             This is the baud rate that the Arduino is connected at. 57600 is the default for the Firmata sketch.
	 * @param useDtrControl    Whether to enable DTR Control for the serial connection.
	 * 
	 */
	public function connect(comPort:String, baud:Int=57600, useDtrControl:Bool = false):Bool
	{
		var createComPortResult:Bool;
		_comPort = convertCOMString(comPort);
		_baud = baud;
		_useDtrControl = useDtrControl;
		
		createComPortResult = _ExtensionContext.call("setupPort", cast(_comPort), cast(_baud),  _useDtrControl ? 1 : 0);
		//trace("[ArduinoConnector] Opening COM port handle number", _comPort.toString(), "success = ", createComPortResult);
		_portOpen = createComPortResult;
		return _portOpen;
	}
			
	/**
	 * 
	 * This will return if this ANE is supported on this platform. 
	 *  
	 * @return TRUE if the ANE is supported on this platform.  FALSE if the ANE is not supported.
	 * 
	 */
	public function isSupported():Bool
	{
		return _ExtensionContext.call("isSupported"); 
	}
	
	/**
	 *
	 * This will return if the communication port has been initalized and is ready for use.
	 *  
	 * @return TRUE if the COM port is open and ready for use.  FALSE if there was a problem initalizing it.
	 * 
	 */
	public function portOpen():Bool
	{
		return _portOpen;
	}
	
	/**
	 *
	 * This funciton will return an array that represents what is in the buffer.  Additionally, calling this function will clear
	 * the serial buffer.
	 *  
	 * @return An Array that represents the bits in the buffer.  Each character in the buffer is its own array element
	 * 
	 */
	public function readBytesAsArray():Dynamic
	{
		if (!_portOpen)
		{
			trace("[ArduinoConnector] COM Port is not open failure");
			return new Array();
		}
		_bytesAvailable = 0;
		
		return _ExtensionContext.call("getBytesAsArray");
	}
	
	/**
	 * 
	 * This function will return a string representation of what is in the serial buffer.  Additionally, calling this function will
	 * clear the serial buffer.
	 *  
	 * @return A String that represents the bits in the buffer.  Non-printable characters may not be represented. 
	 * 
	 */
	public function readBytesAsString():String
	{
		if (!_portOpen)
		{
			trace("[ArduinoConnector] COM Port is not open failure");
			return '';
		}
		_bytesAvailable = 0;
		return _ExtensionContext.call("getBytesAsString");
	}
	
	/**
	 * 
	 * This function will return a ByteArray representation of what is in the serial buffer.  Additionally, calling this function will
	 * clear the serial buffer.  
	 *  
	 * @return A ByteArray that represents the bits in the buffer. 
	 * 
	 */
	public function readBytesAsByteArray():ByteArray
	{
		if (!_portOpen)
		{
			trace("[ArduinoConnector] COM Port is not open failure");
			return new ByteArray();
		}
		_bytesAvailable = 0;
		
		var ba:ByteArray = new ByteArray();
		var baLength:Int = 0;
		ba.length = 4097; // expand the byteArray to the max potential size
		baLength = _ExtensionContext.call("getBytesAsByteArray", ba);
		ba.position = 0;
		ba.length = baLength; // tuncate the byteArray to what was in the buffer.
		return ba;
	}

	/**
	 *
	 * Reads a single byte from the buffer.  This is a FIFO buffer, and the first element will be returned and removed from the buffer.
	 * The events will not fire unless the buffer was emptied with this function.
	 * 
	 * @return A single 8-bit byte from the buffer.
	 * 
	 */
	public function readByte():UInt
	{
		if (!_portOpen)
		{
			trace("[ArduinoConnector] COM Port is not open failure");
			return 0;
		}
		_bytesAvailable--;
		return _ExtensionContext.call("getByte");
	}
	
	
	/**
	 *
	 * Writes a single byte to the serial port.
	 *  
	 * @param byte The byte that you wish to send.
	 * @return TRUE if the sned was successful.  FALSE if there was an error sending the data. 
	 * 
	 */
	public function writeByte(byte:UInt):Bool
	{
		if (!_portOpen)
		{
			trace("[ArduinoConnector] COM Port is not open failure");
			return false;
		}
		return _ExtensionContext.call("sendByte", byte);
	}
		
	
	/**
	 *
	 * This function will send the provided String to the serial port.  
	 *  
	 * @param stringToSend  The String that you wish to send to the Serial Port.
	 * @return  TRUE if the send was successful.  FALSE if there was an error sending the data.
	 * 
	 */
	public function writeString(stringToSend:String):Bool
	{
		if (!_portOpen)
		{
			trace("[ArduinoConnector] COM Port is not open failure");
			return false;
		}
		return _ExtensionContext.call("sendString", stringToSend);
	}
	
	/**
	 *
	 * This function will send the contents of a ByteArray to the serial port.
	 *  
	 * @param bytesToSend  The ByteArray that you plan on sending to the serial port.  The position will be rewinded to 0.
	 * @return  TRUE if the send was successful.  FALSE if there was an error sending the data.
	 * 
	 */
	public function writeBytes(bytesToSend:ByteArray):Bool
	{
		if (!_portOpen)
		{
			trace("[ArduinoConnector] COM Port is not open failure");
			return false;
		}
		bytesToSend.position = 0;
		return _ExtensionContext.call("sendByteArray", bytesToSend);
	}
	
	/**
	 *
	 * This function pretends to flush the serial port buffer.  Data is sent out as it is sent to the various write* functions.  Don't use this,
	 * you are only wasting CPU cycles and that makes Clu angry.  You don't want him angry.  He gets even.
	 * 
	 * This function is stubbed out purely to maintain compatibility with the flash.net.Socket class. 
	 * 
	 */
	public function flush():Void
	{
		// This is just stubbed out.  We always send out as soon as we are passed the data.
	}
	
	/***
	 * 
	 * This function closes the COM port, clears the buffer, and allows you to call the connect function again.
	 * 
	 */
	public function close():Void
	{
		_ExtensionContext.call("closePort");
		_portOpen = false;
	}
	
	/**
	 * Unloads and reloads the native code.
	 * 
	 */	
	public function reinitiate():Void
	{
		dispose();
		initiate();
	}
	
	/**
	 *
	 * Call this function to close the COM port and clean up the ANE.  This MUST be called before the AIR application closes, 
	 * or the Operating System may throw an error.  If the COM port is not cleaned up properly, it may be locked from use of
	 * other applications.  Please, just run this before you exit your AIR app, or kittens may die. 
	 * 
	 */
	public function dispose():Void
	{
		if (! cast _ExtensionContext)
		{
			trace("[ArduinoConnector] Error.  ANE Already in a disposed or failed state...");
			return;
		}
		trace("[ArduinoConnector] Unloading ANE...");
		_portOpen = false;
		_ExtensionContext.removeEventListener(StatusEvent.STATUS, gotEvent);
		_ExtensionContext.dispose();
	}
	
	/**
	 *
	 * Returns the number of bytes that are available in the buffer
	 *  
	 * @return Number of bytes available in the buffer. 
	 * 
	 */
	public function bytesAvailable():Float
	{
		return _bytesAvailable;
	}
	
	/**
	 * @private
	 * 
	 * This is the event that is fired by the DLL when there is new data in the buffer.
	 *  
	 * @param event Event Payload.
	 * 
	 */
	private function gotEvent(event:StatusEvent):Void
	{
		_bytesAvailable = _ExtensionContext.call("getAvailableBytes");
		var e:ArduinoConnectorEvent = new ArduinoConnectorEvent("socketData");
		dispatchEvent(e);
	}
	
	// **********************************************************************************
	//
	// BELOW IS WINDOWS SPECIFIC CODE.  YOU WILL NEED TO BUILD A LIB FOR OTHER PLATFORMS
	//
	// **********************************************************************************
	
	// What are void COM Port Numbers in Windows?  1->16.
	
	/**
	 *
	 * This function will return an array of valid COM ports for this operating system.  It will not necessarly provide valid
	 * COM ports for this machine, but what is valid for the OS in general.
	 * 
	 * @param includeAllSerial Include all serial ports. (For Mac)
	 * @param includeAll Include all ports. (For Mac)
	 * 
	 * @return An array of Strings containing the COM port names.
	 * 
	 */
	public function getComPorts(includeAllSerial:Bool = false, includeAll:Bool = false):Array<String>
	{
		var validComPorts:Array<String> = new Array<String>();
		validComPorts.push("COM1");
		validComPorts.push("COM2");
		validComPorts.push("COM3");
		validComPorts.push("COM4");
		validComPorts.push("COM5");
		validComPorts.push("COM6");
		validComPorts.push("COM7");
		validComPorts.push("COM8");
		validComPorts.push("COM9");
		validComPorts.push("COM10");
		validComPorts.push("COM11");
		validComPorts.push("COM12");
		validComPorts.push("COM13");
		validComPorts.push("COM14");
		validComPorts.push("COM15");
		validComPorts.push("COM16");
		return validComPorts;
	}
	
	/**
	 * Find the COM port as a string that people know, and turn it into the file handler number
	 * COM1 =1,  COM3 = 3, etc. Only for Windows.
	 */
	private function convertCOMString(comString:String):Float
	{
		var myPort:Float = cast(comString.substring(2, 3));
		return myPort;
	}
}