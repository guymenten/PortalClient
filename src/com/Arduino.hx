package com;

import events.PanelEvents;
import flash.events.Event;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.events.TimerEvent;

/**
 * ...
 * @author GM
 */
class Arduino extends ArduinoBase
{
	var alarmActive:Bool;
	var currentRedLampState:Bool;
	var currentSirenPlaying:Bool;
	var testToggle:Bool;
	var testindex:Int;
	var timerHorn:Timer;

	/**
	 * 
	 */
	public function new() 
	{
		super();

		Main.root1.addEventListener(PanelEvents.EVT_PROXY_CONNECTED, initProxy);
		//init();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onTestToggle(e:Dynamic):Void 
	{
		switch(e.parameter)
		{
			case 1, 3: alarmModified();
			case 2, 4: alarmModified(false);
		}
	}

	/**
	 * 
	 */
	function initProxy(e:Event):Void
	{
		//serialLine = new SerialBase(DBDefaults.defaultData.comArduino, 57600);
		//serialLine = new SerialBase(DBDefaults.getStringParam(Parameters.paramComArduino), DBDefaults.getIntParam(Parameters.paramComArduinoSpeed));

		if (initCom())
		{
			Main.root1.addEventListener(PanelEvents.EVT_GREEN_LIGHT, OnGreenLamp);
			Main.root1.addEventListener(PanelEvents.EVT_RED_LIGHT, OnRedLamp);
			Main.root1.addEventListener(PanelEvents.EVT_PANEL_STATE, OnState);
			Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_ACK, OnAlarmAck);
			Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_SOUND_ACK, OnAlarmAck);
			Main.root1.addEventListener(PanelEvents.EVT_APP_EXIT, OnExit);
			Main.model.elapsedBKGMeasurement !.add(OnAlarmAck);

			Main.root1.addEventListener(PanelEvents.EVT_TEST_MODE_TOGGLE, onTestToggle);

			timerHorn = new Timer(500, 1); // Init Time
			timerHorn.addEventListener(TimerEvent.TIMER, onShortSirenStop);
			Main.root1.addEventListener(PanelEvents.EVT_SHORT_SIREN, onShortSiren);
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function onShortSirenStop(e:Event):Void 
	{
		alarmModified(false);		
	}

	/**
	 * 
	 * @param	e
	 */
	public function onShortSiren(e:Event):Void 
	{
		timerHorn.start();
		alarmModified();
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnExit(e:Event):Void 
	{
		trace("Arduino : OnExit");
		playSiren();
		setRedLamp();
		haxe.Timer.delay(onClose, 500); // iOS 6
	}

	/**
	 * 
	 */
	function onClose() 
	{
		if(cast serialLine)
			serialLine.close();
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnState(e:StateMachineEvent):Void 
	{
		//trace("AAAAAA Arduino : OnState");

		if (alarmActive != Main.model.isAlarmManualAckEnabled())
			alarmModified(alarmActive);
	}

	function alarmModified(alarmActive:Bool = true) 
	{
		alarmActive = !alarmActive;

		playSiren(alarmActive);
		setRedLamp(alarmActive);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnAlarmAck(e:Dynamic):Void 
	{
		playSiren(false);
		setRedLamp(false);
	}

	/**
	 * 
	 * @param	play
	 */
	public function playSiren(play:Bool = true) 
	{
		currentSirenPlaying = play;
		outputSiren(play);
		trace("playSiren");
	}

	private function OnRedLamp(e:Event):Void 
	{
		setRedLamp();
		trace("OnRedLamp");
	}
	
	private function OnGreenLamp(e:Event):Void 
	{
		setRedLamp(false);
		trace("OnGreenLamp");
	}

	/**
	 * 
	 * @return
	 */
	public function initCom():Bool
	{
		//serialLineOK =  serialLine.initCom();
		//trace("initCom Serial Arduino : " + serialLineOK);

		if (true)
		{
			setPinMode(4, PIN_MODE_OUTPUT);
			setPinMode(5, PIN_MODE_OUTPUT);
			setPinMode(6, PIN_MODE_OUTPUT);
			setPinMode(7, PIN_MODE_OUTPUT);

			playSiren(false); // Siren Off
			setRedLamp();
			setWatchDog();
			setTest(false);
		}

		return true;
	}

	/**
	 * 
	 * @param	redLamp
	 */
	public function setRedLamp(redLamp:Bool = true) 
	{
		currentRedLampState = redLamp;
		outputRedLamp(redLamp);
	}

	/**
	 * 
	 * @param	Test
	 */
	public function setTest(test:Bool = true) 
	{
		trace("Test : " + test);
		writeDigitalPin(7, test ? 0 : 1);
	}

	/**
	 * 
	 * @param	delay
	 * @param	duty
	 */
	public function setTestPWM(pin:Int, delay:Int, duty:Int) 
	{
		var ba:ByteArray = new ByteArray();
		ba.writeByte(ArduinoBase.SERVO_CONFIG);
		ba.writeByte(pin);
		ba.writeByte(10);
		ba.writeByte(10);
		ba.writeByte(10);
		ba.writeByte(10);
		Model.udpServer.sendArduinoSysex(ba);
	}

	/**
	 * 
	 * @param	redLamp
	 */
	function outputRedLamp(redLamp:Bool) 
	{
		//Model.dbDefaults.setStringParam(Parameters.paramArduinoMessage, redLamp ? "EVT_RED_LIGHT" : "EVT_GREEN_LIGHT");
		writeDigitalPin(6, redLamp ? 0 : 1);
	}

	function outputSiren(play:Bool = true) 
	{
		//Model.dbDefaults.setStringParam(Parameters.paramArduinoMessage, play ? "EVT_SIREN_ON" : "EVT_SIREN_OFF");
		writeDigitalPin(5, play ? 0 : 1);
	}

	/**
	 * 
	 */
	function setWatchDog() 
	{
		//Model.dbDefaults.setStringParam(Parameters.paramArduinoMessage, "EVT_WATCHDOG");
		writeDigitalPin(4, 1); // Watchdog
	}	
}