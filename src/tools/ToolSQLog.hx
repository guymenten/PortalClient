package tools;

import flash.data.SQLResult;
import tools.WTools.ToolButton;
import util.Images;

/**
 * ...
 * @author GM
 */
class ToolSQLLog extends ToolSQLDated
{
	var bFilterReport		:Bool;
	var bFilterError		:Bool;
	var bFilterRA			:Bool;
	var butReport:ToolButton;
	var butRA:ToolButton;
	var butError:ToolButton;

	public function new(name:String, func:SQLResult->Void) 
	{
		super(name,func);

		//butReport 	= push(Images.loadReport(), 		Images.loadReport(),  				" ", "IDS_TT_MENU_RAOFF",	onButReport); // 6
		//butRA		= push(Images.loadLEDRAOn(),		Images.loadLEDRAOnSel(), 			" ", "IDS_TT_MENU_RAON", 	onButRA);
		//butError 	= push(Images.loadLEDRepNonOK(), 	Images.loadLEDRepNonOKSel(),  		" ", "IDS_TT_MENU_NONOK",	onButError);

		setDBTable(Model.dbLog);

	}

	/**
	 * 
	 */
	public override function init():Void {
		super.init();

		onButReport(null); onButError(null); onButRA(null);
		onButFilterOnOff(null);
	}

	/**
	 * 
	 * @param	e
	 */
	function onButReport(e:Dynamic) :Void
	{
		bFilterReport = !bFilterReport;
		butError.setEnabled(bFilterError);
		if(cast e) applyFilters();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButRA(e:Dynamic) :Void
	{
		bFilterRA = !bFilterRA;
		//setIconSprite(7, bFilterRA); 
		if(cast e) applyFilters();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButError(e:Dynamic) :Void
	{
		bFilterError = !bFilterError;
		butError.setEnabled(bFilterError);
		if(cast e) applyFilters();
	}

	/**
	 * 
	 */
	public override function applyFilters():Void
	{
		if (dbTable.bFilterOn)
		{
			Model.dbLog.selectFilterReport	(bFilterReport);
			Model.dbLog.selectFilterRA		(bFilterRA);
			Model.dbLog.selectFilterError		(bFilterError);
			super.applyFilters();
		}
	}
}