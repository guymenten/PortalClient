package;

import camera.Cameras;
import com.Arduino;
import com.ComThread;
import com.ComUDPServer;
import data.ALPRJsonData;
import data.DataObject;
import data.Report;
import db.DBCameras;
import db.DBChannel.DBChannels;
import db.DBConfigChannels.DBChannelsDefaults;
import db.DBConfigWidgets;
import db.DBContacts;
import db.DBDefaults;
import db.DBHistory;
import db.DBLog;
import db.DBReportFormat;
import db.DBReports;
import db.DBTranslations;
import db.DBUsers;
import enums.Enums.ChannelState;
import enums.Enums.ErrorCode;
import enums.Enums.PanelState;
import enums.Enums.Parameters;
import error.Errors;
import events.PanelEvents;
import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import hx.binding.IBindable;
import org.aswing.ASColor;
import print.BuildPrintableReport;
import sound.Sounds;
import sprites.SpriteNuclear;
import util.DebounceSignal;
import util.Filters;
import util.Images;
import widgets.WSound;
import laf.Colors;

//import jsoni18n.I18n;

typedef StatusStateParam = { state:PanelState, label:String, color:ASColor, textColor:ASColor, logoFunction:Void->Dynamic, signalFunction:Void->Dynamic };
typedef ChannelStateParam = { state:ChannelState, label:String, color:ASColor, textColor:ASColor, logo:Bitmap, signal:Bitmap };


/**
 * ...
 * @author GM
 */
class Model extends EventDispatcher implements IBindable
{
	@:bindable public var channelsinRA:Int;
	@:bindable public var refreshCnt:Int;
	@:bindable public var timerCnt:Int;
	@:bindable public var panelState:PanelState;

	@:bindable public var inRAAlarmToAck:Bool;
	@:bindable public var textTitle:String;
	@:bindable public var resetBKGMeasurement:Bool;
	@:bindable public var timeBKGMeasurement:Int;
	@:bindable public var IOStatus:Int 		= 3;
	@:bindable public var portalBusy:Bool;

	@:bindable public var strCounterTextLabel:String;
	@:bindable public var colCounterTextLabel:ASColor;
	@:bindable public var strStatusTextLabel:String;
	@:bindable public var strStatusCountTextLabel:String;
	@:bindable public var colStatusTextLabel:ASColor;
	@:bindable public var backColStatusTextLabel:ASColor;
	@:bindable public var alarmAckCnt:Int;
	@:bindable public var enabledWarning:Bool;
	@:bindable public var enabledAlarmRA:Bool;
	@:bindable public var elapsedBKGMeasurement:Bool;
	@:bindable public var receivingData:Bool;
	@:bindable public var testMode:Bool;
	@:bindable public var portalInUse:Bool;
	@:bindable public var assetsLoaded:Bool;


	public var receivingTimeout:Int;
	public static var cameras:Cameras;
	public static var comThread:ComThread;
	public static var channelsArray:Map<String, DataObject>;
	static public var arduinoMode;

	static public var simulVal1Count:Int;
	static public var simulVal2Count:Int;

	//public static var callbacks:Callbacks;
	public static var arduino:Arduino;

	var errors:Errors;
	var images:Images;

	public var portalInitializing:Bool;
	public var firstBKGInit:Bool = true;
	public var statusStateArray:Array<StatusStateParam>;
	public var countersStateArray:Array<ChannelStateParam>;
	public var manualAlarmSoundAckwowledged:Bool;
	public var inRAAlarm:Bool;

	public var allChannelInitialized:Bool;
	public var portalBKGMeasurement:Bool;
	public var allChannelsOUT:Bool = true;
	var _portalOut:Bool; // Set
	var _portalInTest:Bool; // Set
	public var _portalControlling:Bool;
	var _portalFailure:Bool;
	var autoThresholdComputing:DebounceSignal;
	var previousAlarmsNotAcknowledged:Int;
	var paramAutomaticAlarmAck:Bool;
	public static var sounds:Sounds;
	public static var dbDefaults:DBDefaults;
	public static var dbLog:DBLog;
	public static var translations:DBTranslations;
	public static var dbChannels:DBChannels;
	public static var dbContacts:DBContacts;
	public static var tableUsers:DBUsers;
	public static var dbReports:DBReports;
	public static var soundsWidget:WSound;
	public static var dbCameras:DBCameras;

	public static var lastReport:Report;

	static var defaultParameters:DefaultParameters;
	static private var preinitDone:Bool;
	var inAlarm:Bool;
	static public var buildPrintableReport:BuildPrintableReport;
	static public var dbReportFormat:DBReportFormat;

	public static var dbConfigWidgets:DBConfigWidgets;
	public static var dbChannelsDefaults:DBChannelsDefaults;

	//public static var dbReportsChannel:DBReportsChannel;

	public var timeFree:Date;
	public var timeBusy:Date;

	public var alarmsRADetected:Int;
	public var channelsinRAAlarmToAcknowledged:Int;
	public static var currentUser:User;
	public static var dbHistory:DBHistory;
	static public var bTestMode:Bool;
	static public var demoMode:Bool;
	static public var measuringMode;
	static public var checksumErrors:Int;
	static public var communicationStarted:Bool;
	static public var IOAddress 		= 88;
	static public var IOTestStatus:Bool;
	static public var ScaleX:Float 		= 2.4;
	static public var ScaleY:Float 		= 2.4;
	static public var WIDTH:Float 		= 800;
	static public var HEIGHT:Float 		= 480;

	static public var IOsArray:Map<String, DataObject>;
	static public var priviledgeAdmin:Bool;
	static public var privilegeSuperUser:Bool;
	static public var udpServer:ComUDPServer;
	static public var portalCameraEnabled:Bool;
	static public var portalCameraIndex:Int;
	static public var portalCameraName:Int;
	static public var captureBiteArray:ByteArray;
	static public var scaleEnabled:Bool;
	static public var plateDetected:String;
	static public var alprJsonData:ALPRJsonData;

	/**
	 * 
	 */
	public function new() 
	{
		super();

		Main.model = this;

		dbDefaults			= new DBDefaults();
		translations		= new DBTranslations();

		trace("Session");
		channelsArray 		= new Map<String, DataObject> (); // Channels Array
		IOsArray 			= new Map<String, DataObject> (); // Channels Array
		//Sys.exit(1);
		statusStateArray 	= new Array <StatusStateParam>();
		countersStateArray 	= new Array <ChannelStateParam>();
		createPortalStatusBitmaps();
		createCountersStatusBitmaps();		

		/**
		 * Databases opening: begin
		 */
		images				= new Images();
		errors 				= new Errors();
		dbHistory 			= new DBHistory();
		dbReports 			= new DBReports();
		dbChannels 			= new DBChannels();
		dbReportFormat		= new DBReportFormat();
		dbCameras			= new DBCameras();
		dbChannelsDefaults 	= new DBChannelsDefaults();
		
		defaultParameters	= new DefaultParameters();
		dbConfigWidgets 	= new DBConfigWidgets();
		Model.sounds 		= new Sounds();

		soundsWidget 		= new WSound();
		Model.tableUsers	= new DBUsers();
		Model.dbContacts 	= new DBContacts();
		var filters:Filters = new Filters();
		dbLog 				= new DBLog();
		//Main.logConsole.log("Session preInit Done");

		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		NativeApplication.nativeApplication.idleThreshold = 60;
		Model.tableUsers.checkNamePasswordOK(getCurrentUserName(), true);

		alprJsonData		= new ALPRJsonData();

		cameras = new Cameras();

		arduinoMode 		= DBDefaults.getBoolParam(Parameters.paramArduinoMode);
		portalCameraEnabled = DBDefaults.getBoolParam(Parameters.paramCameraIndex);

		/**
		 * Databases opening: end
		 */

		lastReport 				= new Report();
		//autoThresholdComputing	= new DebounceSignal((DefaultParameters.BKGReactualizationTime) * 1000, portalBusy, null,resetBKGMeasurement);

		assetsLoaded !.add(onAssetsLoaded);
		panelState !.add(refreshPanelState);
		strCounterTextLabel !.add(refreshStatusTextLabel);
		IOStatus !.add (refreshBusySignal);
		alarmAckCnt !.add (onAlarmAck);

		channelsinRA !.add(onChannelsInRA);
	}
	
	/**
	 * 
	 * @param	loaded
	 */
	function onAssetsLoaded(loaded:Bool) 
	{
		
	}

	/**
	 * 
	 */
	function onChannelsInRA(alarms:Int) 
	{
		trace("onChannelsInRA() :  " + alarms);

		inRAAlarm = alarms > 0;

		if (inRAAlarm)
		{
			if (!inRAAlarmToAck)
			{
				Main.root1.dispatchEvent(new Event(PanelEvents.EVT_RA_ALARM_ON)); // Init Done
				inRAAlarmToAck = true;
			}

			var strInfo:String = "";

			for (channel in Model.channelsArray)
			{
				strInfo += channel.label + ': ' + channel.maximum + ', ';
			}
			strInfo = strInfo.substr(0, strInfo.length - 2);
		
			Errors.sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_RA_DETECTED, strInfo));
		}

		//stateModified();
	}

	/**
	 * 
	 * @param	cnt
	 */
	function onAlarmAck(cnt:Int) 
	{
		resetBKGMeasurement = true;
		channelsinRA = 0;
		inRAAlarmToAck = false;
	}

	/**
	 * 
	 * @param	status
	 */
	function refreshBusySignal(status:Int) 
	{
		portalBusy = IOStatus != 3;
		refreshCnt ++; // receiving Data
		receivingData = true;
		receivingTimeout = 0;
	}

	/**
	 * 
	 */
	public function refreshStatusTextLabel(str:String) 
	{
		strStatusTextLabel = statusStateArray[panelState.getIndex()].label + strCounterTextLabel;
	}

	/**
	 * 
	 */
	public function refreshPanelState(state:PanelState) 
	{
		colStatusTextLabel = statusStateArray[state.getIndex()].textColor;
		backColStatusTextLabel = statusStateArray[state.getIndex()].color;
		strStatusTextLabel = statusStateArray[state.getIndex()].label;
		//trace("refreshPanelState: " + strStatusTextLabel);
	}

	//@:bindable public var strCounterTextLabel:String;
	//@:bindable public var colCounterTextLabel:ASColor;
	//@:bindable public var strStatusTextLabel:String;
	//@:bindable public var colStatusTextLabel:ASColor;
	//@:bindable public var backColStatusTextLabel:ASColor;

	/**
	 * 
	 * @return
	 */
	public function isBusy():Bool
	{
		return portalBusy;
	}

	/**
	 * 
	 * @param	label
	 * @param	color
	 * @param	bitmap
	 */
	function addState(stateIn:PanelState, label:String, colorIn:ASColor, colTextIn:ASColor, logoFunctionIn:Void->Dynamic, signalFunctionIn:Void->Dynamic)
	{
		//trace("Adding : " + label);
		var state:StatusStateParam = { state:stateIn, label : DBTranslations.getText(label), color : colorIn, textColor: colTextIn, logoFunction : logoFunctionIn, signalFunction:signalFunctionIn };
		statusStateArray.push(state);
	}

	/**
	 * 
	 * @param	label
	 * @param	color
	 * @param	bitmap
	 */
	function addCounterState(stateIn:ChannelState, label:String, colorIn:ASColor, colTextIn:ASColor, ?bitmap:Bitmap, ?signalBM:Bitmap)
	{
		//trace("Adding : " + label);
		var state:ChannelStateParam = { state:stateIn, label : DBTranslations.getText(label), color : colorIn, textColor: colTextIn, logo : bitmap, signal:signalBM };
		countersStateArray.push(state);
	}

	/**
	 * create the Portal status Bitmaps
	 */
	function createPortalStatusBitmaps():Void
	{
		trace("*******************  createStatusBitmaps");

		var spriteNuclear:SpriteNuclear 	= new SpriteNuclear();
		var spriteNuclearTop:SpriteNuclear	= new SpriteNuclear(true);

		addState(PanelState.IDLE, 				"IDLE", 						StateColor.backColorIdle, 			ASColor.BLACK,			Images.loadStop, 			Images.loadSignalRed);
		addState(PanelState.START, 				"IDS_STATUS_START", 			StateColor.backColorInStart, 		ASColor.MIDNIGHT_BLUE, Images.loadStop, 			Images.loadSignalRed);
		addState(PanelState.INIT,				"IDS_STATUS_INIT", 				StateColor.backColorInInit, 		ASColor.MIDNIGHT_BLUE, Images.loadStop, 			Images.loadSignalRed);
		addState(PanelState.INIT_BUSY,			"IDS_STATUS_INIT_BUSY", 		StateColor.backColorInInitBusy, 	ASColor.MIDNIGHT_BLUE, Images.loadtruckWhite, 		Images.loadSignalRed);
		addState(PanelState.INUSE,				"IDS_STATUS_WAITING_CONTROL", 	StateColor.backColorInInUse, 		ASColor.CLOUDS, Images.loadGo, 				Images.loadSignalGreen);
		addState(PanelState.INUSE_BUSY,			"IDS_STATUS_CONTROLLING", 		StateColor.backColorInControlling, 	ASColor.MIDNIGHT_BLUE, Images.loadtruckGreen, 		Images.loadSignalRed);
		addState(PanelState.TEST,				"IDS_STATUS_TEST", 				StateColor.backColorInTest, 		ASColor.CLOUDS, Images.loadGo, 					Images.loadSignalRed);
		addState(PanelState.RA,					"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS, Images.loadNuclear, 				Images.loadSignalRed);
		addState(PanelState.RA_ACK,				"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS, Images.loadNuclear,				Images.loadSignalRed);
		addState(PanelState.RA_BUSY,				"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS, Images.loadtruckRed, 				Images.loadSignalRed);
		addState(PanelState.RA_BUSY_ACK,			"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS, Images.loadtruckRed,  				Images.loadSignalRed);
		addState(PanelState.BKG_MEASURE,			"IDS_STATUS_BKG", 				StateColor.backColorInBKG, 			ASColor.CLOUDS, Images.loadStop, 					Images.loadSignalRed);
		addState(PanelState.BKG_MEASURE_RA,		"IDS_STATUS_RADIOACTIVITY",		StateColor.backColorInRAAlarm, 		ASColor.CLOUDS, Images.loadNuclear,				Images.loadSignalRed);
		addState(PanelState.BKG_MEASURE_BUSY,	"IDS_STATUS_BKG_BUSY", 			StateColor.backColorInBKG, 			ASColor.CLOUDS, Images.loadtruckBlue, 				Images.loadSignalRed);
		addState(PanelState.BKG_MEASURE_BUSY_RA,	"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS, Images.loadtruckRed,			 	Images.loadSignalRed);
		addState(PanelState.OUT,					"IDS_STATUS_OUT", 				StateColor.backColorInOUT, 			ASColor.CLOUDS, Images.loadStop, 					Images.loadSignalRed);
		addState(PanelState.UNKNOWN,				"IDS_STATUS_UNKNOWN", 			StateColor.backColorInUnknown, 		ASColor.MIDNIGHT_BLUE, Images.loadGo, 				Images.loadSignalRed);
		addState(PanelState.SPEED,				"IDS_STATUS_SPEED", 			StateColor.backColorInSpeed, 		ASColor.CLOUDS, Images.loadInitBusy, 				Images.loadSignalRed);
	}
	
	/**
	 * create the Portal status Bitmaps
	 */
	function createCountersStatusBitmaps():Void
	{
		//trace("*******************  createStatusBitmaps");

		addCounterState(ChannelState.OK, 				"IDS_STATUS_START", 			StateColor.backColorInInUse, 		ASColor.MIDNIGHT_BLUE);
		addCounterState(ChannelState.HIGH,				"IDS_STATUS_INIT", 				StateColor.backColorInOUT, 			ASColor.MIDNIGHT_BLUE);
		addCounterState(ChannelState.LOW,				"IDS_STATUS_INIT_BUSY", 		StateColor.backColorInOUT, 			ASColor.MIDNIGHT_BLUE);
		addCounterState(ChannelState.BKG,				"IDS_STATUS_WAITING_CONTROL", 	StateColor.backColorInBKG, 			ASColor.CLOUDS);
		addCounterState(ChannelState.ERROR,				"IDS_STATUS_CONTROLLING", 		StateColor.backColorInOUT,			ASColor.CLOUDS);
		addCounterState(ChannelState.INRA,				"IDS_STATUS_TEST", 				StateColor.backColorInOUT, 			ASColor.CLOUDS);
		addCounterState(ChannelState.INIT,				"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInInit, 		ASColor.MIDNIGHT_BLUE);
		addCounterState(ChannelState.TIMEOUT,			"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInOUT, 			ASColor.CLOUDS);
		addCounterState(ChannelState.DISABLED,			"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInOUT, 			ASColor.CLOUDS);
	}

	/**
	 * 
	 */
	public function init()
	{
		trace("Session : init()");

		if (arduinoMode)
			arduino = new Arduino();

		comThread = new ComThread();
	}

	/**
	 * 
	 * @param	index
	 */
	public static function getChannel(index:Int = 80):DataObject
	{
		return channelsArray.get(Std.string(index));
	}

	static public function getCurrentUserName() :String
	{
		return (cast currentUser) ? currentUser.name : DBDefaults.getStringParam(Parameters.paramLastUser);
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function OnResetBKGMeasure(e:Event):Void 
	{
		for (channel in Model.channelsArray)
		{
			channel.OnResetBKGMeasure();
		}		
	}
	/**
	 * 
	 */
	public function isInitialized() : Bool { return true; }
	public function getStateBackgroundColor() : ASColor
	{
		return statusStateArray[Model.bTestMode ? PanelState.RA_BUSY.getIndex() : cast panelState].color;	
	}

	/**
	 * 
	 */
	public function getCounterStateBackgroundColor(channelState:ChannelState, inAlarm:Bool) : ASColor
	{
		if (!isInitialized())
			return(StateColor.backColorInInit);

		if (inAlarm || Model.bTestMode)
			return countersStateArray[ChannelState.INRA.getIndex()].color;

		return countersStateArray[channelState.getIndex()].color;	
	}

	/**
	 * 
	 */
	public function getStateLabel() : String
	{
		if (!isInitialized())
			return statusStateArray[PanelState.INIT.getIndex()].label;
		
			return statusStateArray[Model.bTestMode ? PanelState.RA_BUSY.getIndex() : cast panelState].label;	
	}

	/**
	 * 
	 */
	public function getStateTextColor() : ASColor
	{
		return statusStateArray[Model.bTestMode ? PanelState.RA_BUSY.getIndex() : cast panelState].textColor;	
	}

	/**
	 * 
	 */
	public function getCounterTextColor(channelState:ChannelState) : ASColor
	{
		
		if (portalInitializing || !isInitialized())
			return statusStateArray[PanelState.INIT.getIndex()].textColor;

		if (inAlarm || Model.bTestMode)
			return statusStateArray[PanelState.RA.getIndex()].textColor;

		return countersStateArray[channelState.getIndex()].textColor;	
	}

	/**
	 * 
	 * @return
	 */
	public function getCounterTextLabel(dao:DataObject) : String
	{
		if (portalInitializing || !isInitialized())
			return"?";

		switch(dao.channelState)
		{
			case ChannelState.OK, ChannelState.INRA, ChannelState.BKG: return Std.string(dao.counterF);
			case ChannelState.HIGH: return DBTranslations.getText("IDS_COUNTER_HIGH");
			case ChannelState.LOW: return DBTranslations.getText("IDS_COUNTER_LOW");
			default: return '?';
		}
	}

	/**
	 * 
	 */
	public function getBusySeconds() : Int
	{
		var diff:Float = (Date.now().getTime() - timeBusy.getTime()) / 1000;
		
		return cast diff;
	}

	/**
	 * 
	 */
	public function getStateLogo() : Bitmap
	{
		return statusStateArray[Model.bTestMode ? PanelState.RA_BUSY.getIndex() : panelState.getIndex()].logoFunction();
	}

	/**
	 * 
	 */
	public function getShortStatusTextLabel() :String
	{
		if (portalBKGMeasurement)
			return (isBusy() ? cast getBusySeconds() : cast timeBKGMeasurement);

		else
			return "";
	}
	
	/**
	 * 
	 * @return
	 */
	public function isAlarmManualAckEnabled():Bool
	{
		return inRAAlarmToAck;
	}

	/**
	 * 
	 * @return
	 */
	public function initTimeDecrementAllowed() : Bool
	{
		if (allChannelsOUT || isInRAAlarm() || inRAAlarmToAck)
		{
			return false;
		}

		return !Errors.portalInError;
	}
	/**
	 * 
	 * @param	alarms
	 */
	public function isInRAAlarm() : Bool
	{
		return inRAAlarmToAck || inRAAlarm;
	}
}