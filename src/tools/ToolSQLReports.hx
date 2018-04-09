package tools;

import db.DBTranslations;
import flash.data.SQLResult;
import flash.events.TextEvent;
import tools.WTools.ToolButton;
import util.Images;

/**
 * ...
 * @author GM
 */
class ToolSQLReports extends ToolSQLDated
{
	var bFilterRepOK		:Bool;
	var bFilterRepRAOn		:Bool;
	var bmFilterRepNonOK	:Bool;
	var buRAOff:ToolButton;
	var buRAOn:ToolButton;
	var buNotOK:ToolButton;

	public function new(name:String, func:SQLResult->Void) 
	{
		super(name, func);

		buRAOff = new ToolButton("", "", "IDS_TT_MENU_RAOFF", Images.loadLEDRAOffSel(), onButRepOK);
		toolBar.append(buRAOff);
		buRAOff.y += gapIndex; gapIndex += gap;

		buRAOn = new ToolButton("", "", "IDS_TT_MENU_RAON", Images.loadLEDRAOn(), onButRepRAOn);
		toolBar.append(buRAOn);
		buRAOn.y += gapIndex; gapIndex += gap;

		buNotOK = new ToolButton("", "", "IDS_TT_MENU_NONOK", Images.loadLEDRepNonOK(), onButRepNonOK);
		toolBar.append(buNotOK);
		buNotOK.y += gapIndex; gapIndex += gap;

		setDBTable(Model.dbReports);

		strItemsNumber = ' ' + DBTranslations.getText("IDS_BUT_REPORTS");

	}

	/**
	 * 
	 * @return
	 */
	public override function getTextSQL():String 
	{
		return null;
	}

	/**
	 * 
	 */
	public override function init():Void {
		super.init();

		onButRepOK(null); onButRepRAOn(null); onButRepNonOK(null);
		//onButFilterOnOff(null);
	}

	/**
	 * 
	 * @param	e
	 */
	private override function onSearchOnText(e:TextEvent):Void 
	{
		dbTable.selectTimeInterval();
		dbTable.setIntervalFromCountNotStacked((cast e.text) - 16, 16);
	}

	/**
	 * 
	 * @param	e
	 */
	function onButRepNonOK(e:Dynamic) :Void
	{
		bmFilterRepNonOK = !bmFilterRepNonOK;
		//setIconSprite(8, bmFilterRepNonOK);
		if(cast e) applyFilters();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButRepRAOn(e:Dynamic) :Void
	{
		bFilterRepRAOn = !bFilterRepRAOn;
		//setIconSprite(7, bFilterRepRAOn); 
		if(cast e) applyFilters();
	}

	function onButRepOK(e:Dynamic) :Void
	{
		bFilterRepOK = !bFilterRepOK;
		//setIconSprite(6, bFilterRepOK); 
		if(cast e) applyFilters();
	}

	/**
	 * 
	 */
	public override function applyFilters():Void
	{
		if (dbTable.bFilterOn)
		{
			Model.dbReports.selectOKReports	(bFilterRepOK);
			Model.dbReports.selectRAReports	(bFilterRepRAOn);
			Model.dbReports.selectNonOKReports(bmFilterRepNonOK);
			super.applyFilters();
		}
	}
}