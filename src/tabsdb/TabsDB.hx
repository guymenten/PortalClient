package tabsdb ;

import db.DBTranslations;
import tabsdb.TabLogBook;
import tabsdb.TabStatistics;
import util.Images;
import widgets.TabConditional;

/**
 * ...
 * @author GM
 */

class TabsDB extends TabConditional
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
		appendTab(new TabLogBook(),		"IDS_BUT_LOGBOOK", 	Images.loadLogBook());
		appendTab(new TabStatistics(),	"IDS_STATISTICS", 	Images.loadStatistics());
		appendTab(new TabContacts(),	"IDS_CONTACTS", 	Images.loadContacts());
	}

	/**
	 * 
	 * @return
	 */
	public override function getTitleText():String
	{
		return DBTranslations.getText("IDS_STORAGE");
	}
}