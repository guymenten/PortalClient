package ;

import db.DBDefaults;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.events.Event;
import Type;
import org.aswing.event.AWEvent;

class DefaultBinding
{
	public var name:String;
	public var parameter:Dynamic;
	public var bindFunction:Dynamic-> Void;

	
	public function new(name:String, parameter:Dynamic)
	{
		this.name = name;
		this.parameter = parameter;
	}
	
	/**
	 * 
	 */
	public function executeBindingFunction() 
	{
		if (cast bindFunction) bindFunction(parameter);
	}
}

/**
 * ...
 * @author GM
 */
class DefaultParameters
{
	public static var language:Int;
	public static var arduinoComNumber:Int;
	public static var IOComNumber:Int;
	public static var tweenTime:Float = 20;
	public static var BKGReactualizationTime:Int;
	public static var initializationTime:Int;
	public static var bkgInitializationTime:Int;
	public static var bkgMeasureTime:Int;
	public static var datagramsArrayLenght:Int = 600;
	public static var rateMeterBufferSize:Int = 4;
	public static var strLanguage:String;
	public static var dateFormat:String;
	public static var dateMonthFormat:String;
	public static var timeFormat:String;
	public static var paramMaximumControlTime:Int; // In Seconds
	public static var paramAlarmTimeout:Int;
	public static var paramErrorTimeout:Int;
	public static var simulationMode:Bool;
	public static inline var paramEncryptionKey:String			= "nopasswordnopassnopasswordnopass";			
	public static var paramTestDuty:Int;
	public static var paramTestDelay:Int;
	public static var cameraEnabled:Bool;
	public static var scaleEnabled:Bool;
	public static var paramMinimumReportTime:Int;
	public static var paramTrailerTime:Int;
	public static var paramEULA:Bool;

	public function new() 
	{
		Main.root1.addEventListener(PanelEvents.EVT_PARAM_UPDATED, refresh);
		refresh(null);
	}

	/**
	 * 
	 * @param	param
	 * @param	val
	 */
	public static function setIntParameter(binding:DefaultBinding)
	{
		Model.dbDefaults.setIntParam(binding.name, binding.parameter);
		binding.executeBindingFunction();
	}

	/**
	 * 
	 * @param	e
	 */
	private static function refresh(e:Event):Void 
	{
		initializationTime			= DBDefaults.getIntParam(Parameters.paramInitializationTime);
		BKGReactualizationTime		= DBDefaults.getIntParam(Parameters.paramBKGReactualizationTime);
		datagramsArrayLenght		= DBDefaults.getIntParam(Parameters.paramAcquistionBufferLenght);
		language					= DBDefaults.getIntParam(Parameters.paramLanguage);
		dateFormat					= DBDefaults.getStringParam(Parameters.paramDateFormat);
		dateMonthFormat				= DBDefaults.getStringParam(Parameters.paramDateMonthFormat);
		timeFormat					= DBDefaults.getStringParam(Parameters.paramTimeFormat);
		bkgInitializationTime		= DBDefaults.getIntParam(Parameters.paramBKGMeasurementTime);
		paramMaximumControlTime		= DBDefaults.getIntParam(Parameters.paramMaximumControlTime);
		rateMeterBufferSize			= DBDefaults.getIntParam(Parameters.paramRateMeterBufferSize);
		bkgMeasureTime				= DBDefaults.getIntParam(Parameters.paramBKGMeasureTime);
		simulationMode				= DBDefaults.getBoolParam(Parameters.paramSimulatorMode);
		arduinoComNumber			= DBDefaults.getIntParam(Parameters.paramComArduino);
		IOComNumber					= DBDefaults.getIntParam(Parameters.paramComIO);
		paramTestDuty				= DBDefaults.getIntParam(Parameters.paramTestDuty);
		paramTestDelay				= DBDefaults.getIntParam(Parameters.paramTestDelay);
		paramMinimumReportTime		= DBDefaults.getIntParam(Parameters.paramMinimumReportTime);
		paramTrailerTime			= DBDefaults.getIntParam(Parameters.paramTrailerTime);
		cameraEnabled				= cast DBDefaults.getIntParam(Parameters.paramCameraIndex);
		scaleEnabled				= cast DBDefaults.getIntParam(Parameters.paramScaleEnabled);
		paramEULA					= cast DBDefaults.getIntParam(Parameters.paramEULA);
	}

	public function setDefaultValue(value:Int)
	{
		
	}

	/**
	 * 
	 * @param	languageID
	 * @return
	 */
	public static function getLanguage(languageID:Int):String 
	{
		switch languageID
		{
			case 0: return "Français";
			case 1: return "English";
			case 2: return "Nederlands";
			case 3: return "Deutsch";
		}

		return null;
	}

	/**
	 * 
	 * @param	value
	 */
	static public function setPortNumber(param:String, value:Int) 
	{
		Model.dbDefaults.setIntParam		(param, value);	
		Model.dbDefaults.setStringParam	(param, "COM" + value);
		refresh(null);
	}
}