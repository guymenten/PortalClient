package panescenter ;

import db.DBTranslations;
import events.PanelEvents;
import events.PanelEvents.ParameterEvent;
import flash.geom.Rectangle;
import tools.ToolsPlotting;
import widgets.WBase;
import widgets.WCountersMeasure;
import widgets.WPlots;

/**
 * ...
 * @author GM
 */
class WMeasures extends WBase
{
	var xMinRange				:Int = 120;
	var xMaxRange				:Int = 1000;
	var xRange					:Int;
	var plotsWidget				:WPlots;
	var countersMeasureWidget	:WCountersMeasure;
	var toolPlotting			:ToolsPlotting;
	var logScale				:Bool;

	public function new(name:String) 
	{
		super(name);

		xRange = xMinRange;

		plotsWidget 			= new WPlots("ID_DETAILLED_STATUS", 380, 140, xRange);
		addChild(plotsWidget);

		countersMeasureWidget 	= new WCountersMeasure("ID_COUNTER_MEASURES");
		addChild(countersMeasureWidget);

		toolPlotting			= new ToolsPlotting("ID_TOOL_PLOTTING_MEASURE", 40, 40, onButReset, onButZoomPlus, onButZoomMinus, onButLinLogScale);
		addChild(toolPlotting);
	}

	/**
	 * 
	 * @param	e
	 */
	function onButZoomPlus(e:Dynamic) 
	{
		xRange *= 2;
		if (xRange > xMaxRange) xRange = xMaxRange;
		plotsWidget.setXScale(xRange);
	}

	/**
	 * 
	 * @param	e
	 */
	function onButZoomMinus(e:Dynamic) 
	{
		xRange = cast xRange / 2;
		if (xRange < xMinRange) xRange = xMinRange;
		plotsWidget.setXScale(xRange);
	}

	/**
	 * 
	 * @param	e
	 */
	function onButLinLogScale(e:Dynamic = null) 
	{
		logScale = !logScale;
		//toolPlotting.setIconSprite(3, logScale);
		onButReset();
		plotsWidget.setLinearYScale(!logScale);
	}

	/**
	 * 
	 */
	function onButReset(e:Dynamic = null):Void
	{
		countersMeasureWidget.onResetMinMax();
		plotsWidget.onResetMinMax(true);
		Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_DATA_REFRESH, "DATA")); // 0 for all channels		return true;
	}

	/**
	 * 
	 * @param	vis
	 */
	public override function setVisible(vis:Bool)
	{
		super.setVisible(vis);
		plotsWidget.setVisible(vis);
	}

	/**
	 * 
	 * @return
	 */
	public override function getTitleText():String
	{
		return DBTranslations.getText("IDS_BUT_MEASURES");
	}
}