package com;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

/**
 * ...
 * @author GM
 */
class ArduinoBase extends EventDispatcher
{
	public var serialLine:SerialBase;
	var serialLineOK:Bool;
	// enumerations
	public static var OUTPUT : Int = 1;
	public static var INPUT	: Int = 0;
	public static var HIGH : Int = 1;
	public static var LOW : Int = 0;
	public static var ON : Int = 1;
	public static var OFF : Int = 0;
	public static var PWM : Int = 3;

	public static var START_SYSEX:Int	= 0xF0 ;// start a MIDI Sysex message
	public static var END_SYSEX:Int		= 0xF7 ;// start a MIDI Sysex message
	public static var SERVO_CONFIG:Int	= 0x70 ;

	// pin modes
	var PIN_MODE_INPUT:Int =    0x00; // defined in wiring.h
	var PIN_MODE_OUTPUT:Int = 	0x01; // defined in wiring.h
	var PIN_MODE_ANALOG:Int =  	0x02; // analog pin in analogInput mode
	public static var PIN_MODE_PWM:Int =     	0x03; // digital pin in PWM output mode
	var PIN_MODE_SERVO:Int =	0x04 ;// digital pin in Servo output mode
	// data processing variables
	private var _waitForData 				: Int = 0;
	private var _executeMultiByteCommand 	: Int = 0;	
	private var _multiByteChannel			: Int = 0; 		// indicates which pin the data came from

	// data holders
	//private var _storedInputData		: Array = new Array();
	//private var _analogData				: Array = new Array();
	//private var _previousAnalogData		: Array = new Array();
	//private var _digitalData			: Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	//private var _previousDigitalData	: Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	private var _firmwareVersion		: Int = 0;
	private var _digitalPins			: Int = 0;
	private var _sysExData				: ByteArray;
	//
	// private enums
	private static var ARD_TOTAL_DIGITAL_PINS			: Int = 54; 

	// computer <-> arduino messages
	public static var ARD_WATCHDOG_MESSAGE	: Int = 1; 
	public static var COM_WATCHDOG_MESSAGE	: Int = 2; 
	static var ARD_DIGITAL_MESSAGE			: Int = 144; 
	static var ARD_REPORT_DIGITAL_PORTS		: Int = 208; 
	static var ARD_REPORT_ANALOG_PIN		: Int = 192; 
	static var ARD_REPORT_VERSION			: Int = 249; 
	static var ARD_SET_DIGITAL_PIN_MODE		: Int = 244; 	
	static var ARD_ANALOG_MESSAGE			: Int = 224; 
	static var ARD_SYSTEM_RESET				: Int = 255; 
	static var ARD_SYSEX_MESSAGE_START		: Int = 240; //expose to let subclasses send sysex
	static var ARD_SYSEX_MESSAGE_END		: Int = 247;

	static var ARD_SYSEX_STRING				: Int = 113; //0x71;
	static var ARD_SYSEX_QUERY_FIRMWARE		: Int = 121; //0x79;

	public function new() 
	{
		super();

		_sysExData = new ByteArray();
	}

	/**
	 * 
	 * @param	byte
	 * @return
	 */
	function writeByte(byte:Int):Bool
	{
		if (!serialLineOK)
			return false;

		//return serialLine.comPort.writeByte(byte);
		return false;
	}

	/**
	 * 
	 * @param	pin
	 * @param	mode
	 */
	public function setPinMode (pin:Int, mode:Int):Void
	{
		Model.udpServer.sendProxyCommand(ArduinoBase.ARD_SET_DIGITAL_PIN_MODE, pin, mode);
	}

	//FIRMATA2.0 change: have to send a PORT-specific message
	public function writeDigitalPin (pin:Int, mode:Int):Void
	{
		// set the bit
		if(mode==1)
			_digitalPins |= (mode << pin);
							
		// clear the bit        
		if(mode==0)
			_digitalPins &= ~(1 << pin);
	
		if(pin<=7){
			//writeByte(ArduinoBase.ARD_DIGITAL_MESSAGE+0);//PORT0
			//writeByte(_digitalPins % 128); // Tx pins 0-6
			//writeByte((_digitalPins >> 7) & 1); // Tx pin 7
			Model.udpServer.sendProxyCommand(ArduinoBase.ARD_DIGITAL_MESSAGE+0, _digitalPins % 128, (_digitalPins >> 7) & 1);
		} 
		if (pin>=8 && pin <=15){
			//writeByte(ArduinoBase.ARD_DIGITAL_MESSAGE+1);//PORT1
			//writeByte(_digitalPins >>8); //Tx pins 8..15
			//writeByte(0);
			Model.udpServer.sendProxyCommand(ArduinoBase.ARD_DIGITAL_MESSAGE+1, _digitalPins >>8, 0);
		} 
		if (pin>=16 && pin <=23){
			//writeByte(ArduinoBase.ARD_DIGITAL_MESSAGE+1);//PORT1
			//writeByte(ArduinoBase.ARD_DIGITAL_MESSAGE+2);//PORT2
			//writeByte(_digitalPins >>16); //Tx pins 16..23
			//writeByte(0);
			//Model.udpServer.sendArduinoCommand(ArduinoBase.ARD_DIGITAL_MESSAGE+1, _digitalPins % 128, 0);
		}
		if (pin>=24 && pin <=31){
			//writeByte(ArduinoBase.ARD_DIGITAL_MESSAGE+3);//PORT3
			//writeByte(_digitalPins >>24); //Tx pins 24..31
			//writeByte(0);
			Model.udpServer.sendProxyCommand(ArduinoBase.ARD_DIGITAL_MESSAGE+3, _digitalPins >>24, 0);
		}
		if (pin>=32 && pin <=39){
			//writeByte(ArduinoBase.ARD_DIGITAL_MESSAGE+4);//PORT4
			//writeByte(_digitalPins >>32); //Tx pins 32..39
			//writeByte(0);
			Model.udpServer.sendProxyCommand(ArduinoBase.ARD_DIGITAL_MESSAGE+4, _digitalPins >>32, 0);
		}
		if (pin>=40 && pin <=47){
			//writeByte(ArduinoBase.ARD_DIGITAL_MESSAGE+5);//PORT5
			//writeByte(_digitalPins >>40); //Tx pins 40..47
			//writeByte(0);
			Model.udpServer.sendProxyCommand(ArduinoBase.ARD_DIGITAL_MESSAGE+5, _digitalPins >>40, 0);
		}
		if (pin>=48 && pin <=53){
			//writeByte(ArduinoBase.ARD_DIGITAL_MESSAGE+6);//PORT6
			//writeByte(_digitalPins >>48); //Tx pins 48..53
			//writeByte(0);
			Model.udpServer.sendProxyCommand(ArduinoBase.ARD_DIGITAL_MESSAGE+6, _digitalPins >>48, 0);
		}						
	}
}