package tabsdb ;

import flash.data.SQLResult;
import org.aswing.AsWingConstants;
import org.aswing.event.InteractiveEvent;
import org.aswing.JScrollBar;
import tools.ToolSQLog.ToolSQLLog;
import widgets.WPlotStatistics;

/**
 * ...
 * @author GM
 */
class TabStatistics extends TabSQL
{
	var plotStatistics	:WPlotStatistics;
	var scrollBar		:JScrollBar;
	var valuesDisplayed	:Int;

	public function new() 
	{
		super();

		plotStatistics = new WPlotStatistics("ID_PLOT_STATISTICS");
		addChild(plotStatistics);
		plotStatistics.init			(620, 290, 120, 3000);
		scrollBar = new JScrollBar(AsWingConstants.HORIZONTAL);
		scrollBar.setComBoundsXYWH	(28, 294, 634, 20);
		scrollBar.addStateListener(scrollStateChanged);
		addChild(scrollBar);
		valuesDisplayed = 512;

		toolSQL = new ToolSQLLog("ID_PLOT_TOOL_LOG", onApplyFilters);
		//toolSQL.init();
		addChild(toolSQL);
	}

	/**
	 * 
	 * @param	comp
	 */
	function scrollStateChanged(comp:InteractiveEvent) : Void
	{
		if (!comp.isProgrammatic() || !initialized)
		{
			var val:Int = scrollBar.getValue();
			//Model.dbHistory.getLogHistory(val, valuesDisplayed);
			plotStatistics.update();
			initialized = true;
		}
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
				//Model.dbHistory.getLogHistoryCount(getHistoryResult);
				initialized = true;
			}
			else
				plotStatistics.update();
		}
	}
	/**
	 * 
	 */
	function onApplyFilters(res:SQLResult):Void
	{
	}

}