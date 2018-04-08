package ;

import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.desktop.SystemTrayIcon;
import flash.display.NativeMenu;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.desktop.*;
import flash.desktop.NativeApplication;
import flash.display.*;
import flash.display.NativeMenuItem;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.geom.Rectangle;
import haxe.Timer;
import util.ScreenManager;
import widgets.GestureSprite;

/**
 * ...
 * @author GM
 */
//@:bitmap("assets/img/apply.png")				class BmMove extends flash.display.BitmapData { }

class BitmapSmoothed extends Bitmap
{
	public function new(?bitmapData:BitmapData, ?pixelSnapping:PixelSnapping, smoothing:Bool=true) 
	{
		super(bitmapData, PixelSnapping.AUTO, smoothing);
	}
}

class Images
{
	public function new() 	{}
}

class Language
{
	public var Label:String;

	/**
	 * 
	 */
	public function new(strLang:String):Void 
	{
		Label = strLang;
	}
}

class SystemTray extends GestureSprite
{
	public var dpLanguages:Array<Language>;

	var applicationIconsBitmaps:Array<Dynamic>;
	var tooltipText:String;
	var iconMenu:NativeMenu;
	var sysTrayIcon:SystemTrayIcon;

	public var newWinTop:NativeWindow;
	public var optNW:NativeWindowInitOptions;

	public var iconLanguageMenu:NativeMenu;
	public var iconTimeFormatMenu:NativeMenu;
	public var iconPreferencesMenu:NativeMenu;
	public var indexLanguageSelected:Int;
	public var LanguagesEnabledNumber:Int;
	//public var iconConfigurationMenu:NativeMenu;

	//private var showFileOpen:NativeMenuItem;
	private var aboutCommand:NativeMenuItem;
	private var exitCommand:NativeMenuItem;
	private var showCommand:NativeMenuItem;
	private var showTopCommand:NativeMenuItem;
	private var hideCommand:NativeMenuItem;
	private var soundCommand:NativeMenuItem;
	private var languageCommand:NativeMenuItem;
	private var timeFormatCommand:NativeMenuItem;	
	private var preferencesCommand:NativeMenuItem;
	//private var configCommand:NativeMenuItem;

	private var englishCommand:NativeMenuItem;
	private var frenchCommand:NativeMenuItem;
	private var dutchCommand:NativeMenuItem;

	private var timeFormat1Command:NativeMenuItem;
	private var timeFormat2Command:NativeMenuItem;
	private var timeFormat3Command:NativeMenuItem;
	private var timeFormat4Command:NativeMenuItem;

	public function new() 
	{
		super();
	}

	/**
	 * 
	 */
	public function initSysTray():Void
	{
		//Main.stream.writeUTFBytes("getLanguages ...");
		dpLanguages 		= new Array();
		getLanguages();
		iconMenu 			= new NativeMenu();
	
		//Main.stream.writeUTFBytes("loadIcons ...");

		loadIcons();
		//Main.stream.writeUTFBytes("loadMenu ...");
		loadMenu();

		NativeApplication.nativeApplication.autoExit = false;

		//Main.stream.writeUTFBytes("TrayIconClicked ...");
		sysTrayIcon.addEventListener(MouseEvent.CLICK, TrayIconClicked);
		Main.root1.addEventListener(PanelEvents.EVT_APP_EXIT, onTimeToExit);
		var systray:SystemTrayIcon = cast(NativeApplication.nativeApplication.icon, SystemTrayIcon);
		//Main.stream.writeUTFBytes("NativeWindowInitOptions ...");

		optNW				= new NativeWindowInitOptions();

		optNW.systemChrome 	= NativeWindowSystemChrome.NONE;
		optNW.resizable 	= false;
		optNW.transparent 	= true;
		optNW.minimizable 	= false;
		//optNW.renderMode 	= NativeWindowRenderMode.DIRECT;

		optNW.type 			= NativeWindowType.UTILITY;
		newWinTop 			= new NativeWindow(optNW);

		newWinTop.stage.scaleMode = StageScaleMode.NO_SCALE;
	
		var rect:Rectangle = ScreenManager.getMaximumAvailableResolution();			

		newWinTop.stage.stageWidth	= cast rect.width;
		newWinTop.stage.stageHeight = cast rect.height;

		newWinTop.x = rect.x;
		newWinTop.y = rect.y;

		newWinTop.stage.align = StageAlign.TOP_LEFT;
		Main.stageMain = newWinTop;

		newWinTop.visible = true; // Widget Visible
		refreshLanguageMenu(DefaultParameters.strLanguage);
	}

	/**
	 * 
	 * @param	e
	 */
	function onTimeToExit(e:Event) 
	{
		Timer.delay(Exit, 500 );
	}

	/**
	 * 
	 * @param	e
	 */
	private function TrayIconClicked(e:MouseEvent):Void 
	{
		onShow(null);
	}

	/**
	 *
	 */
	private function loadMenu():Void
	{
		//showFileOpen = iconMenu.addItem(new NativeMenuItem());

		iconMenu.addItem(new NativeMenuItem("",true));
		showCommand = iconMenu.addItem(new NativeMenuItem());
		showTopCommand = iconMenu.addItem(new NativeMenuItem());
		hideCommand = iconMenu.addItem(new NativeMenuItem());

		iconMenu.addItem(new NativeMenuItem("",true));
		preferencesCommand = iconMenu.addItem(new NativeMenuItem());
		//configCommand = iconMenu.addItem(new NativeMenuItem());

		iconMenu.addItem(new NativeMenuItem("",true));
		aboutCommand = iconMenu.addItem(new NativeMenuItem());
		exitCommand = iconMenu.addItem(new NativeMenuItem());

		preferencesCommand.submenu = createPreferencesMenu();
		//configCommand.submenu = createConfigurationMenu();

		//showFileOpen.addEventListener(Event.SELECT, onOpenFile);
		showCommand.addEventListener(Event.SELECT, onShow);
		showTopCommand.addEventListener(Event.SELECT, onShowTop);
		hideCommand.addEventListener(Event.SELECT, onHide);
		aboutCommand.addEventListener(Event.SELECT, onAbout);
		exitCommand.addEventListener(Event.SELECT, onExit);
	}

	/**
	 *
	 */
	private function loadIcons():Void
	{
		var iconLoader:Loader = new Loader();
		
		//Main.stream.writeUTFBytes("supportsSystemTrayIcon ...");

		if (NativeApplication.supportsSystemTrayIcon)
		{
			NativeApplication.nativeApplication.autoExit = false;
			var fileIcon:File = File.applicationDirectory.resolvePath("portalClient.exe");
			applicationIconsBitmaps= fileIcon.icon.bitmaps;
			NativeApplication.nativeApplication.icon.bitmaps = applicationIconsBitmaps;
			sysTrayIcon = cast(NativeApplication.nativeApplication.icon , SystemTrayIcon);
			sysTrayIcon.tooltip = tooltipText;
			sysTrayIcon.menu = iconMenu;
		}

		if (NativeApplication.supportsDockIcon)
		{
			var dock:DockIcon = cast(NativeApplication.nativeApplication.icon, DockIcon);
			dock.menu = iconMenu;
		}
	}

	/**
	 *
	 * @return
	 */
	private function createPreferencesMenu():NativeMenu
	{
		iconPreferencesMenu = new NativeMenu();
		// Language SubMenu
		languageCommand = new NativeMenuItem();
		languageCommand.addEventListener(Event.SELECT, selectLanguageMenu);
		iconPreferencesMenu.addItem(languageCommand);
		languageCommand.submenu = createLanguageMenu();
		// Time SubMenu
		timeFormatCommand = new NativeMenuItem();
		timeFormatCommand.addEventListener(Event.SELECT, onTimeFormat);
		iconPreferencesMenu.addItem(timeFormatCommand);
		timeFormatCommand.submenu = createTimeFormatMenu();
		// Sound SubMenu
		soundCommand = new NativeMenuItem();
		soundCommand.addEventListener(Event.SELECT, onSound);
		iconPreferencesMenu.addItem(soundCommand);

		return iconPreferencesMenu;
	}

	/**
	 *
	 * @param	evt
	 */
	private function onShow(evt:Event):Void
	{
		if(Main.widgetBig != null)
			Main.widgetBig.visible = !Main.widgetBig.visible;
	}

	/**
	 *
	 * @param	evt
	 */
	private function onHide(evt:Event):Void
	{
		Main.widgetBig.visible = false;
	}

	/**
	 *
	 * @param	evt
	 */
	public function onAbout(evt:Event):Void
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_ABOUT)); // 0 for all channels		return true;
	}

	/**
	 *
	 * @param	evt
	 */
	function onShowTop(evt:Event):Void
	{
		showTopCommand.checked = !showTopCommand.checked;
		newWinTop.alwaysInFront = showTopCommand.checked;
		onShow(evt);
		Model.dbDefaults.setIntParam(Parameters.paramShowOnTop, cast showTopCommand.checked);
	}

	/**
	 *
	 * @param	e
	 */
	private function onSound(e:Event):Void
	{
		//soundCommand.checked = !soundCommand.checked;
		//Sounds.soundEnabled = soundCommand.checked;
		//Main.cfgFile.soundEnabled = soundCommand.checked;
		//
		//if (soundCommand.checked)
			//Sounds.playSound(SysSounds.FATAL);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onTimeFormat(e:Event):Void 
	{
	}

	/**
	 //*
	 //* @return
	 //*/
	//private function createConfigurationMenu():NativeMenu
	//{
		//iconConfigurationMenu = new NativeMenu();
		//var menu:NativeMenuItem = new NativeMenuItem(loadString("IDS_DATABASE_PATH"));
		//iconConfigurationMenu.addItem(menu);
		//iconConfigurationMenu.addEventListener(Event.SELECT, selectConfigurationCommand);
		//
		//return iconConfigurationMenu;
	//}

	/**
	 * 
	 */
	public function getLanguages():Void
	{
		for (indexLang in 0 ... 4)
		{
			dpLanguages.push(new Language(DefaultParameters.getLanguage(indexLang)));
		}
	}

	/**
	 *
	 * @return
	 */
	private function createLanguageMenu():NativeMenu
	{
		iconLanguageMenu = new NativeMenu();
		iconLanguageMenu.addEventListener(Event.SELECT, selectLanguageMenu);
		
		trace(dpLanguages.length);
		
		for (i in 0 ... dpLanguages.length - 1)
		{
			if (dpLanguages[i] != null)
			{
				var menu:NativeMenuItem = new NativeMenuItem(dpLanguages[i].Label);
				iconLanguageMenu.addItem(menu);
				menu.addEventListener(Event.SELECT, selectLanguageCommand);
			}
		}
		
		return iconLanguageMenu;
	}

	private function selectLanguageMenu(e:Event):Void
	{
	}

	/**
	 * 
	 */
	private function createTimeFormatMenu():NativeMenu 
	{
		//iconTimeFormatMenu = new NativeMenu();
		//iconTimeFormatMenu.addEventListener(Event.SELECT, selectTimeFormatMenu);
			//
		//for (var i:int = 0; i < 4; i++)
		//{
			//switch (i)
			//{
				//caso 0: strTime = '2012:12:01'
			//}
			//var menu:NativeMenuItem = new NativeMenuItem();
				//iconLanguageMenu.addItem(menu);
				//menu.addEventListener(Event.SELECT, selectLanguageCommand);
			//}
		//}
		//
		//return iconLanguageMenu;
		return null;
	}

	/**
	 *
	 * @param	e
	 */
	private function selectLanguageCommand(e:Event):Void
	{
		setLanguage(e.target.label);
		refreshLanguageMenu(e.target.label);
	}

	/**
	 *
	 */
	function refreshLanguage():Void
	{
		//showFileOpen.label = loadString("IDS_OPENFILE");
		showCommand.label			= DBTranslations.getText("IDS_SHOW");
		showTopCommand.label		= DBTranslations.getText("IDS_SHOW_TOP");
		hideCommand.label			= DBTranslations.getText("IDS_HIDE");
		soundCommand.label			= DBTranslations.getText("IDS_SOUND");
		languageCommand.label		= DBTranslations.getText("IDS_LANGUAGE");
		timeFormatCommand.label 	= DBTranslations.getText("IDS_TIME_FORMAT");
		preferencesCommand.label 	= DBTranslations.getText("IDS_PREFERENCES");
		//configCommand.label = loadString("IDS_CONFIGURATION");
		exitCommand.label 			= DBTranslations.getText("IDS_DLG_EXIT");
		aboutCommand.label 			= DBTranslations.getText("IDS_ABOUT");
	}

	/**
	 *
	 * @param	idLang
	 */
	public function setLanguage(strLang:String):Void
	{
		for (i in 0 ... dpLanguages.length - 1)
		{
			if (dpLanguages[i] != null && dpLanguages[i].Label == strLang)
				indexLanguageSelected = i;
		}
	}

	/**
	 *
	 * @param	strLang
	 */
	private function refreshLanguageMenu(strLang:String):Void
	{
		//Main.cfgFile.Language = strLang;
		setLanguage(strLang);

		for (i in 0 ... LanguagesEnabledNumber -1)
		{
			var strL:String = iconLanguageMenu.getItemAt(i).label;
			iconLanguageMenu.getItemAt(i).checked = strL == strLang;
		}

		soundCommand.checked	= cast DBDefaults.getIntParam(Parameters.paramSoundEnabled);
		showTopCommand.checked	= cast DBDefaults.getIntParam(Parameters.paramShowOnTop);
		newWinTop.alwaysInFront = showTopCommand.checked;
		onShow(null);

		refreshLanguage();
		sysTrayIcon.tooltip = tooltipText;
	}

	/**
	 *
	 * @param	evt
	 */
	private function onExit(evt:Event = null):Void
	{
		Exit();
	}
	
	function Exit():Void 
	{
		sysTrayIcon.removeEventListener(MouseEvent.CLICK, TrayIconClicked);
		sysTrayIcon = null;

		NativeApplication.nativeApplication.exit();
	}
}