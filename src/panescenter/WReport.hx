package panescenter ;

import data.DataObject;
import db.DBChannel.DBChannels;
import db.DBTranslations;
import enums.Enums.MinMax;
import flash.data.SQLResult;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import org.aswing.util.StringUtils;
import tables.TableReports;
import tools.ToolSQLReports;
import util.Images;
import widgets.WBase;
import widgets.WDataValues.WDataValuesWithTitle;
import widgets.WImageDisplay;
import widgets.WPlotWm;

enum DateType
{
	SINGLE;
	FROM;
	TO;
}

/**
 * ...
 * @author GM
 */
class WReport extends WBase
{
	var reportsTable		:TableReports;
	var imageDisplay		:WImageDisplay;
	public var plotsWidgets:Array<WPlotWm>;
	var dataValuesWidgets	:Array<WDataValuesWithTitle>;
	var reportSelected		:Int;
	var minMaxPlot			:MinMax;
	var strTitleText		:String;
	var radioActivity		:Bool;
	var reportDataObject	:DataObject;
	var toolSQLReports		:ToolSQLReports;
	var totalValues			:Int;

	public function new(name:String, logoOnly:Bool = false) 
	{
		super(name);
	
		visible 				= false;

		strTitleText 			= DBTranslations.getText("IDS_REPORT_NUMBER");

		reportsTable			= new TableReports(272, 362, this);
		imageDisplay			= new WImageDisplay("IDS_REPORT_IMAGE");
		imageDisplay.X_ZOOMED	= 32;
		imageDisplay.Y_ZOOMED	= 100;
		imageDisplay.zoomedScale = 3;

		reportsTable.setBorder(null);

		minMaxPlot				= new MinMax();
		plotsWidgets			= new Array<WPlotWm>();
		dataValuesWidgets		= new Array<WDataValuesWithTitle>();

		addChild(reportsTable);

		toolSQLReports 			= new ToolSQLReports("ID_PLOT_TOOL_REPORT", onApplyFilters);
		toolSQLReports.setTable(reportsTable);
		addChild(toolSQLReports);

		createWidgets();

		Main.root1.addEventListener("SelectReportNumber", onSelectLastItem);
	}

	function onPrevRecord()
	{
		reportsTable.selectRecord(-1);
	}

	function onNextRecord()
	{
		reportsTable.selectRecord(1);
	}

	/**
	 * 
	 */
	function onApplyFilters(?res:SQLResult):Void
	{
		toolSQLReports.refresh();
		reportsTable.refreshList(res, toolSQLReports.getTextSQL(), toolSQLReports.getIconSQL());
		onReportSelected(reportSelected);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onSelectLastItem(e:Event):Void 
	{
		//trace("onSelectLastItem");
		
		reportSelected = Model.lastReport.lastReportData.ReportNumber;
				
		toolSQLReports.dbTable.setIntervalFromCount(reportSelected - reportsTable.tableRows, reportsTable.tableRows, reportsTable.tableSorter.getSortingStatus(0) == -1, onApplyFilters);

	}

	/**
	 * 
	 * @return
	 */
	public override function getTitleText():String
	{
		return(StringUtils.replace(strTitleText, "%1", cast reportSelected));
	}

	/**
	 * 
	 */
	function createWidgets():Void
	{
		var index:Int = 0;

		for (channel in Model.channelsArray)
		{
			var dataObject:DataObject 	=  Model.channelsArray.get(channel.getAddress());
			var plotWidget:WPlotWm 		=  new WPlotWm("ID_PLOT_REPORT" + index, dataObject);

			var waterMark:Bitmap 		= Images.loadTruckWatermark();
			waterMark.alpha = 0.8;

			var bm:Bitmap = Images.loadNuclear();
			Images.resize(bm, 48, 48);

			plotWidget.setWaterMarkBitmap(waterMark);
			plotWidget.init(240, 140, 0, 120,  200, 4000);
			plotWidget.graphVal.setBackgroundBitmap(bm, 116, 30);

			plotsWidgets.push(plotWidget);
			addToggleObject(plotWidget);
			addChild(plotWidget);

			var dataValuesWidget:WDataValuesWithTitle =  new WDataValuesWithTitle("ID_CNT_REPORT" + index, dataObject, false);
			dataValuesWidgets.push(dataValuesWidget);
			addToggleObject(dataValuesWidget);
			addChild(dataValuesWidget);

			index++;
		}

		addChild(imageDisplay);
		addToggleObject(imageDisplay);
	}

	/**
	 * 
	 * @param	e
	 */
	public function onReportSelected(reportNumber:Int = 0):Void 
	{
		reportSelected = (cast reportNumber) ? reportNumber : Model.lastReport.lastReportData.ReportNumber;

		if (visible)
		Main.model.textTitle = getTitleText();

		for (channel in Model.channelsArray)
		{
			reportDataObject = Model.dbChannels.getChannelData(channel.channelIndex, reportSelected);
			pushTableValues(channel.channelIndex - 1); // Refresh plot and values
			refreshValuesWidget(channel.channelIndex - 1, reportDataObject);
		}

		if (minMaxPlot != null)
		{
			for (channel in Model.channelsArray)
			{
				minMaxPlot.reset();

				var plot:WPlotWm = plotsWidgets[channel.channelIndex - 1];

				if (plot.graphVal.maxValueY > minMaxPlot.maxValue)
				{
					minMaxPlot.maxValue = plot.graphVal.maxValueY;
				}

				if (plot.graphTrg.maxValueY > minMaxPlot.maxValue)
				{
					minMaxPlot.maxValue = plot.graphTrg.maxValueY;
				}
	
				if (plot.graphTrg.minValueY < minMaxPlot.minValue)
				{
					minMaxPlot.minValue = plot.graphTrg.minValueY;
				}

				if (plot.graphVal.minValueY < minMaxPlot.minValue)
				{
					minMaxPlot.minValue = plot.graphVal.minValueY;
				}
				plot.setYRange(minMaxPlot.rounded(100));
				plot.drawValues();
			}

			Model.dbReports.getReport(reportSelected);
			imageDisplay.setBitmap(Model.dbReports.lastReportData.Picture, getDefaultPicture());

			if ((cast Model.buildPrintableReport) && Model.buildPrintableReport.isSelected())
			{
				Model.buildPrintableReport.selectReport(reportNumber, plotsWidgets);
			}
		}
	}

	/**
	 * 
	 */
	function getDefaultPicture() :Bitmap
	{
		if (Model.dbReports.lastReportData.ReportResult == 0) return Images.loadtruckGreen();
		return Images.loadtruckRed();
	}

	/**
	 * 
	 * @param	channelIndex
	 * @param	channelData
	 */
	function refreshValuesWidget(channelIndex:Int, channelData:DataObject) 
	{
		if (channelData != null)
		{
			var data:DataObject = new DataObject(0, channelIndex, channelData.noise, channelData.thresholdCalculated);
			data.maximum 				= channelData.maximum;
			data.minimum 				= channelData.minimum;
			data.threshold				= channelData.threshold;
			data.thresholdCalculated	= channelData.thresholdCalculated;
			data.deviation				= channelData.deviation;
			data.noise					= channelData.noise;
			data.inRAAlarm				= channelData.inRAAlarm;

			dataValuesWidgets[channelIndex].setValues(data);
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
				Model.dbReports.getRecordsCount();
				toolSQLReports.init();
				onSelectLastItem(null);
				initialized = true;
			}
		}
	}

	/**
	 * 
	 */
	function pushTableValues(channel:Int) 
	{
		var dataOb 			= new DataObject();
		var plotWidget:WPlotWm = plotsWidgets[channel];

		minMaxPlot.reset();
		plotWidget.eraseValues();
		plotWidget.graphVal.setTitle(DBTranslations.getReportLegend());

		radioActivity		 				= false;

		for (data in DBChannels.arrayGetChannelData)
		{
			dataOb.counterF					= data.counter;
			dataOb.noise					= data.noise;
			dataOb.thresholdCalculated 		= data.threshold;
			dataOb.threshold 				= data.threshold;
			dataOb.minimum 					= data.minimum;
			dataOb.maximum 					= data.maximum;
			dataOb.deviation 				= data.deviation;

			if (data.radioActivity == 1)
				radioActivity = true;

			minMaxPlot 			= plotWidget.pushValue(dataOb);
		}

		//trace(DBChannels.arrayGetChannelData.length);
		plotWidget.setXRange(0, DBChannels.arrayGetChannelData.length);
		reportDataObject.inRAAlarm = radioActivity;
		plotWidget.graphVal.setBackgroundBitmapVisible(radioActivity);
	}
}