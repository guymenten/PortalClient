package tabssettings ;

import db.DBTranslations;
import flash.events.Event;
import icon.TabIcon;
import util.Images;
import tabssettings.SetPrinters;
import widgets.TabConditional;

/**
 * ...
 * @author GM
 */

class Settings extends TabConditional
{
	/**
	 * 
	 * @param	name
	 */
	public function new(name:String) 
	{
		super(name);
	}

	/**
	 * 
	 */
	private override function createUserTabs():Void
	{
		appendTab(new SetDefaults(), 	"IDS_BUT_DEFAULTS", 	Images.loadSettings());
		appendTab(new SetPrinters(), 	"IDS_BUT_PRINTERS", 	Images.loadPrinter());
		appendTab(new SetSounds(), 		"IDS_SOUND", 			Images.loadLoudSpeaker());		
	}	

	/**
	 * 
	 */
	private override function createSuperUserTabs():Void
	{
		appendTab(new SetUsers(),		"IDS_BUT_USERS",		Images.loadUsers());

		if (DefaultParameters.scaleEnabled)
			appendTab(new SetScale(), 		"IDS_BUT_SCALE",		Images.loadScale());
	}

	/**
	 * 
	 */
	private override function createAdminTabs():Void
	{
		appendTab(new SetDetectionLevels(), "IDS_TAB_THRESHOLD",	Images.loadLevels());
		appendTab(new SetSupport(), 		"IDS_TAB_SUPPORT",		Images.loadSettings());
		appendTab(new SetDebug(), 			"IDS_TAB_DEBUG",		Images.loadDebug());
		appendTab(new SetPortal(), 			"IDS_BUT_MONITOR",		Images.loadMonitor());
		appendTab(new SetTest(), 			"IDS_BUT_TEST",			Images.loadTest());
	}

	/**
	 * 
	 * @return
	 */
	public override function getTitleText():String
	{
		return DBTranslations.getText("IDS_BUT_SETTINGS");
	}
}