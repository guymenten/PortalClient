package tools;
import comp.JButton2;
import db.DBBase;
import db.DBTranslations;
import events.PanelEvents;
import flash.data.SQLResult;
import flash.events.Event;
import flash.events.TextEvent;
import icon.IconFromBm;
import org.aswing.ButtonModel;
import org.aswing.JButton;
import org.aswing.JToolBar;
import tables.Table;
import tools.WTools.ToolButton;
import util.Images;
import widgets.WBase;
import widgets.WSearchDlg;

/**
 * ...
 * @author GM
 */
class ToolSQL extends WBase
{
	public var dbTable		:DBBase;

	var onGetResultFunc		:SQLResult->Void;
	var onPrevFunc			:Void->Void;
	var onNextFunc			:Void->Void;
	var iconCurrent			:IconFromBm;
	var oldFunc				:Dynamic->Void;
	var strItemsNumber		:String;

	var butNext				:ToolButton;
	var butPrev				:ToolButton;
	var butFilter			:ToolButton;
	var butSearch			:ToolButton;

	var wSearchDlg			:WSearchDlg;
	var table				:Table;
	var butModelNext		:ButtonModel;
	var toolBar				:JToolBar;

	public function new(name:String, ?w:Int=40, ?h:Int=40, func:SQLResult->Void) 
	{
		super(name);

		onGetResultFunc		= func;

		toolBar = new JToolBar(JToolBar.VERTICAL, gap);
		addChild(toolBar);

		butFilter = new ToolButton("", "", "IDS_TT_MENU_FILTER", Images.loadSQLFilterOn(false), onButFilterOnOff);
		toolBar.append(butFilter);
	
		butPrev = new ToolButton("", "", "IDS_TT_MENU_PREV", Images.loadButPrevious(), onButPrevious);
		toolBar.append(butPrev);
		butPrev.y = gapIndex; gapIndex += gap;
		
		butNext = new ToolButton("", "", "IDS_TT_MENU_NEXT", Images.loadButNext(), onButNext);
		toolBar.append(butNext);
		butNext.y += gapIndex; gapIndex += gap;
		
		butSearch = new ToolButton("", "", "IDS_TT_MENU_SEARCH", Images.loadView(false), onButSearch);
		toolBar.append(butSearch);
		butSearch.y += gapIndex; gapIndex += gap;

		Main.root1.addEventListener(PanelEvents.EVT_PANE_CHANGE, hideDialogs);
		Main.root1.addEventListener(PanelEvents.EVT_SQL_SEARCH, onSearchOnText);
	}

	/**
	 * 
	 * @param	reportsTable
	 */
	public function setTable(tableIn:Table) 
	{
		table = tableIn;
		setNextRecordFunc(table.onNextRecord);
		setPrevRecordFunc(table.onPrevRecord);
	}
	
	/**
	 * 
	 */
	function startTransaction() 
	{
		//enableButtons(false);
		toolBar.enabled = false;
	}
	/**
	 * 
	 * @param	e
	 */
	public function hideDialogs(e:Event):Void 
	{
	}

	/**
	 * 
	 * @return
	 */
	public function getTextSQL():String 
	{
		return null;
	}
	/**
	 * 
	 * @param	e
	 */
	private function onSearchOnText(e:TextEvent):Void 
	{
	}

	public function setPrevRecordFunc(func:Void->Void) { onPrevFunc = func; }
	public function setNextRecordFunc(func:Void->Void) { onNextFunc = func; }

	/**
	 * 
	 * @param	e
	 */
	function onButPrevious(e:Dynamic) :Void {
		if(cast onButPrevious) onPrevFunc();
	}

	/**
	 * 
	 */
	public function init():Void {
		dbTable.selectTimeInterval();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButNext(e:Dynamic) :Void
	{
		if(cast onButNext) onNextFunc();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButSearch(e:Dynamic) :Void
	{
		if(cast onButSearch) onSearchFunc();
	}

	/**
	 * 
	 * @return
	 */
	public function getIconSQL():IconFromBm 
	{
		return iconCurrent;
	}

	/**
	 * 
	 * @param	e
	 */
	function onButFilterOnOff(e:Dynamic):Void 
	{
		dbTable.bFilterOn = !dbTable.bFilterOn;
		//setIconSprite(0, dbTable.bFilterOn); 
		applyFilters();
	}

	/**
	 * 
	 * @param	e
	 */
	function onSearchFunc():Void 
	{
		if (wSearchDlg == null)
			wSearchDlg = new WSearchDlg(this, Main.widgetBig);
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_SQL_SEARCH_DLG));		
	}

	/**
	 * 
	 * @param	table
	 */
	public function setDBTable(table:DBBase):Void
	{
		dbTable = table;
	}

	/**
	 * 
	 */
	public function applyFilters():Void
	{
	}
}