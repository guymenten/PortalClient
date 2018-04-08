package ;

//import comp.LogConsole;
import db.DBDefaults;
import enums.Enums.Parameters;
import flash.desktop.NativeApplication;
import flash.display.MovieClip;
import flash.display.NativeWindow;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.Lib;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.system.Capabilities;
import jive.plaf.flat.FlatLookAndFeel;
import laf.RPMLaf2;
import laf.RPMLaf;
import org.aswing.AsWingManager;
import org.aswing.UIManager;
import sound.Sounds;
import tweenx909.advanced.UpdateModeX;
import tweenx909.TweenX;
import widgets.WBig;
import widgets.WDialog;
import widgets.WSmall;
import DefaultParameters;


/**
 * ...
 * @author GM
 */

class Main 
{
	//public static var logConsole:LogConsole;
	public static var systemTray:SystemTray;
	public static var stageMain:NativeWindow;
	public static var widgetBig:WBig;
	public static var widgetSmall:WSmall;
	public static var model:Model;
	public static var controller:Controller;
	public static var root1:MovieClip;
	public var newWinTop:NativeWindow;
	static var bWidgetSmall:Bool = true;
	public static var dialogWidget:WDialog;

	static function main() 
	{
		var app = NativeApplication.nativeApplication;

		//openLogFile();

		//logConsole = new LogConsole();
		//logConsole.x = 1024;

		// new to AIR? please read *carefully* the readme.txt files!

		app.addEventListener(InvokeEvent.INVOKE, function(e : InvokeEvent) 
		{
			root1 = Lib.current;
			root1.stage.stageWidth		= cast Capabilities.screenResolutionX;
			root1.stage.stageHeight		= cast Capabilities.screenResolutionY;
			onApplicationDeactivate(null);
			//app.addEventListener(Event.ACTIVATE, onApplicationActivate); 
			app.addEventListener(Event.DEACTIVATE, onApplicationDeactivate);
			//root1.addEventListener(PanelEvents.EVT_REMOTING_INITIALIZED, init);
			Main.model 		= new Model();
			Main.controller = new Controller();
			root1.stage.frameRate				= DBDefaults.getIntParam(Parameters.paramFrameRate);
			//stream.writeUTFBytes("systemTray ...");

			systemTray							= new SystemTray();
			systemTray.initSysTray();			AsWingManager.initAsStandard(stageMain.stage);
			widgetBig 		= new WBig();

			Main.init();
		});
	}

	//static public var stream:FileStream;
	//static var file:File;
	///**
	 //*
	 //*/
	//static function openLogFile():Void
	//{
		//stream = new FileStream();
		//file = new File(FileUtils.getApplicationDirURL("log.txt"));
		//stream.open(file, FileMode.WRITE);
		////stream.writeUTFBytes("Starting ...");
	//}

	/**
	 * 
	 */
	static function init(?e:Event)
	{
		//stream.writeUTFBytes("preInit ...");
		//root1.stage.frameRate				= DBDefaults.getIntParam(Parameters.paramFrameRate);
		////stream.writeUTFBytes("systemTray ...");
//
		//systemTray							= new SystemTray();
		//systemTray.initSysTray();
		//stream.writeUTFBytes("AsWingManager ...");
		//AsWingManager.initAsStandard(stageMain.stage);
		//stream.writeUTFBytes("setLookAndFeel ...");
		//UIManager.setLookAndFeel(new FlatLookAndFeel());
		UIManager.setLookAndFeel(new RPMLaf2());
		//stream.writeUTFBytes("widgetBig ...");

		rescaleWindows();

		if (! cast DBDefaults.getIntParam(Parameters.paramServerMode))
			createMain();

		dialogWidget 						= new  WDialog(widgetBig.mainWindow, widgetBig);
		dialogWidget.setVisible(false);
		Sounds.sndGeiger.play();

		TweenX.updateMode 					= UpdateModeX.TIME(30);

		Main.stageMain.stage.addChild(widgetBig);
		if(cast widgetSmall) Main.stageMain.stage.addChild(widgetSmall);

		stageMain.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, displayStateChangeEventHandler);
		stageMain.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, displayStateChangeEventHandler);
		
	}

	/**
	 * 
	 * @param	e
	 */
	static public function rescaleWindows(?scaleIn:Int):Void 
	{
		var scale:Float;

		if (cast scaleIn){
			scale = scaleIn;
			Model.dbDefaults.setIntParam(Parameters.paramWindowScaleX, cast scale*100);
		}
		else {
			scale = DBDefaults.getIntParam(Parameters.paramWindowScaleX) / 100;	
		}

		Model.ScaleX 		= scale;
		Model.ScaleY 		= Model.ScaleX;
		widgetBig.scaleX	= Model.ScaleX;
		widgetBig.scaleY	= Model.ScaleY;
	}

	/**
	 * 
	 * @param	e
	 */
	static private function onApplicationDeactivate(e:Event):Void 
	{
		trace("onApplicationDeactivate");
		//root1.stage.frameRate		= 0;
			//TweenX.updateMode = UpdateModeX.TIME(60);
	}

	static private function onApplicationActivate(e:Event):Void 
	{
		trace("onApplicationActivate");
		//root1.stage.frameRate		= DBDefaults.getIntParam(Parameters.paramFrameRate);
			//TweenX.updateMode = UpdateModeX.TIME(60);
	}

	/**
	 * 
	 * @param	e
	 */
	static function displayStateChangeEventHandler(e:NativeWindowDisplayStateEvent):Void
	{
		trace("displayStateChangeEventHandler" + e);
		systemTray.newWinTop.visible = true;
		systemTray.newWinTop.orderToFront();
		systemTray.newWinTop.activate();
	}

	/**
	 * 
	 */
	public static function createMain():Void 
	{
		trace("createMain()");

		Main.model.assetsLoaded !.add(onAssetsloaded);
	
	}
	
	/**
	 * 
	 */
	public static function onAssetsloaded(loaded:Bool):Void 
	{
		Main.model.init();
		Main.controller.init();

		if (bWidgetSmall)
		{
			widgetSmall = new WSmall();
		}
	}
}