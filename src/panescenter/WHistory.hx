package panescenter ;

import comp.JButtonFramed;
import db.DBTranslations;
import events.PanelEvents;
import flash.data.SQLResult;
import flash.events.Event;
import org.aswing.AsWingConstants;
import org.aswing.event.InteractiveEvent;
import org.aswing.JScrollBar;
import widgets.WBase;
import widgets.WPlotHistory;

/**
 * ...
 * @author GM
 */
class WHistory extends WBase
{
	var plotHistory	:WPlotHistory;
	var butBkg		:JButtonFramed;
	var scrollBar	:JScrollBar;
	var valuesDisplayed:Int;
	var totalValues:Int;
	var pendingRequests:Int;

	public function new(name:String) 
	{
		super(name);

		var Y:Int 	= 60;
		butBkg 		= new JButtonFramed("ID_BUT_BKG", 260, 294, 140, 32, "IDS_STATUS_BKG", null, onbutBkg);
		plotHistory = new WPlotHistory("ID_PLOT_HISTORY");
		scrollBar 	= new JScrollBar(AsWingConstants.HORIZONTAL);
		scrollBar.addStateListener(scrollStateChanged);

		plotHistory.init			(620, 290, 120, 3000);
		scrollBar.setComBoundsXYWH	(28, 260, 634, 20);
		valuesDisplayed = 512;

		initTooltips();

		addChild(plotHistory);
		addChild(scrollBar);

		Main.root1.addEventListener(PanelEvents.EVT_COMPUTE_NOISE, onBKGComputed);
		Main.root1.addEventListener(PanelEvents.EVT_PANEL_STATE, onStateRefresh);
		addChild(butBkg);
	}

	/**
	 * 
	 * @param	comp
	 */
	function scrollStateChanged(comp:InteractiveEvent) : Void
	{
		if (!comp.isProgrammatic() || !initialized)
		{
			updatePlotHistory(scrollBar.getValue());
			initialized = true;
		}
	}

	/**
	 * 
	 * @param	val
	 */
	function updatePlotHistory(val:Int) : Void
	{
		trace(val);
		Model.dbHistory.getRecords(val, valuesDisplayed, onGetDBData);
	}

	/**
	 * 
	 */
	function onApplyFilters(res:SQLResult):Void {

		pendingRequests --;
	
		if(pendingRequests > 0)
		{
			updatePlotHistory(scrollBar.getValue());
			pendingRequests = 1;
		}
		else
			onGetDBData(res);
	}

	/**
	 * 
	 */
	function onGetDBData(res:Dynamic) :Void
	{
		pendingRequests --;

		if(pendingRequests > 0)
		{
			updatePlotHistory(scrollBar.getValue());
			pendingRequests = 1;
		}
		else
			plotHistory.update(res);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onStateRefresh(e:Event):Void 
	{
		butBkg.enabled = Main.model.initTimeDecrementAllowed();
	}

	/**
	 * 
	 * @param	vis
	 */
	public override function setVisible(vis:Bool)
	{
		super.setVisible(vis);

		if (vis)
		{
			if (!initialized)
			{
				Model.dbHistory.getRecordsCount(getHistoryResult);
			}
			else if (!initialized)
				updatePlotHistory(scrollBar.getValue());
		}
	}

	/**
	 * 
	 * @param	res
	 */
	function getHistoryResult(res:SQLResult)
	{
		if (res != null) { totalValues = Model.dbHistory.recordsNumber; }

		scrollBar.setMaximum(totalValues > valuesDisplayed ? totalValues - valuesDisplayed : valuesDisplayed);
		scrollBar.setValue(scrollBar.getMaximum());
		initialized = true;
		updatePlotHistory(0);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onBKGComputed(e:Event):Void 
	{
		if (visible)
			plotHistory.update();
	}

	function initTooltips()
	{
		butBkg.setToolTipText(DBTranslations.getText("IDS_TT_MEASURE_BKG"));
	}

	/**
	 * 
	 */
	function onbutBkg(e:Event) 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_RESET_FIRST_INIT)); // Restart the BKG measurement
	}

	/**
	 * 
	 * @return
	 */
	public override function getTitleText():String
	{
		return DBTranslations.getText("IDS_BUT_HISTORY");
	}
}