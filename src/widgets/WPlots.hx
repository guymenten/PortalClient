package widgets;

import flash.Lib;
import util.Images;
import flash.display.Bitmap;
import Array;
import util.Images;
import util.Filters;
import util.Gradients;
import text.JTextH2;
import util.plot.PlotBase;
import flash.display.Sprite;
import db.DBTranslations;
import flash.display.BlendMode;
import flash.events.Event;
import flash.display.DisplayObject;
import events.PanelEvents;
import data.DataObject;
import enums.Enums;

/**
 * ...
 * @author GM
 */

class WPlots extends WBase
{
	var plotWidgetList:List<WPlotRefreshed>;
	var minMaxPlot:MinMax;

	/**
	 * 
	 */
	public function new(name:String, widthIn:Int = 300, heightIn = 182, xScaleIn:Int = 120, logoOnly:Bool = false) 
	{
		super(name);

		minMaxPlot = new MinMax();
		var cntWidget:WCounter;
		plotWidgetList = new List<WPlotRefreshed>();

		var dataObject:DataObject;
		var plotWidget:WPlotRefreshed;

		var index:Int = 0;

		for (dao in Model.channelsArray)
		{
			dataObject =  Model.channelsArray.get(dao.getAddress());
			plotWidget =  new WPlotRefreshed("ID_PLOT" + dao.channelIndex, dataObject);
			plotWidgetList.add(plotWidget);
			plotWidget.init(widthIn, heightIn, 0, xScaleIn, 200, Math.POSITIVE_INFINITY);
			addChild(plotWidget);

			cntWidget = new WCounter("ID_PLOT_COUNTER_" + index, dataObject);
			index ++;
		}

		Main.model.refreshCnt !.add(refreshData);
		Main.model.elapsedBKGMeasurement !.add(onResetMinMax);
	}

	/**
	 * 
	 * @param	e
	 */
	public function onResetMinMax(elapsed:Bool):Void 
	{
		if (elapsed)
		{
			minMaxPlot.reset();

			for (plotWidget in plotWidgetList)
			{
				plotWidget.resetMinAndMaxYValues();		
			}
		}
	}
	
	/**
	 * 
	 * @param	e
	 */
	public function setXScale(xScale:Int):Void 
	{
		minMaxPlot.reset();

		for (plotWidget in plotWidgetList)
		{
			plotWidget.setXRange(0, xScale);		
		}
	}

	/**
	 * 
	 * @param	e
	 */
	public function refreshData(cnt:Int)
	{
		var sameYScale:Bool 	= false;
		var modified:Bool 		= false;

		for (plotWidget in plotWidgetList)
		{
			minMaxPlot.reset();

			if (plotWidget.graphVal.maxValueY > minMaxPlot.maxValue)
			{
				minMaxPlot.maxValue = plotWidget.graphVal.maxValueY;
				modified = true;
			}

			if (plotWidget.graphTrg.maxValueY > minMaxPlot.maxValue)
			{
				minMaxPlot.maxValue = plotWidget.graphTrg.maxValueY;
				modified = true;
			}

			if (plotWidget.graphTrg.minValueY < minMaxPlot.minValue)
			{
				minMaxPlot.minValue = plotWidget.graphTrg.minValueY;
				modified = true;
			}

			if (plotWidget.graphVal.minValueY < minMaxPlot.minValue)
			{
				minMaxPlot.minValue = plotWidget.graphVal.minValueY;
				modified = true;
			}

			if (modified)
			{
				plotWidget.setYRange(minMaxPlot.rounded(100));
				plotWidget.drawGrid();
			}
		}

		if (sameYScale && modified)
		{
			for (plotWidget in plotWidgetList)
			{
				plotWidget.setYRange(minMaxPlot.rounded(100));
			}
		}
	}

	/**
	 * 
	 * @param	vis
	 */
	public override function setVisible(vis)
	{
		super.setVisible(vis);

		for (plotWidget in plotWidgetList)
		{
			plotWidget.visible = vis;
		}

		Main.root1.dispatchEvent (new Event(PanelEvents.EVT_ON_SHOW));
	}

	/**
	 * 
	 * @param	linearScale
	 */
	public function setLinearYScale(linearScale:Bool) 
	{
		for (plotWidget in plotWidgetList)
		{
			plotWidget.setLinearYScale(linearScale);
		}
		
	}
}