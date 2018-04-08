package widgets;

import data.DataObject;
import db.DBTranslations;
import enums.Enums.MinMax;
import events.PanelEvents;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import org.aswing.ASColor;
import org.aswing.geom.IntRectangle;
import util.PlotGraph;

/**
 * ...
 * @author GM
 */
class WPlot extends WBase
{
	public var graphVal:	PlotGraph;
	public var graphValI:	PlotGraph;
	public var graphBkG:	PlotGraph;
	public var graphTrg:	PlotGraph;
	public var XRange:		Int;
	public var drawAll		:Bool;

	var maxY:				Float;
	var minY:				Float;

	var dataObject:			DataObject;
	var iCount:				Int = 0;
	var rectPlot			:IntRectangle;

	public function new(name:String, dataObjectIn:DataObject, parent:Dynamic = null) 
	{
		super(name);

		XRange 		= 60;
		dataObject 	= dataObjectIn;

		graphVal	= new PlotGraph();
		graphValI	= new PlotGraph();
		graphBkG 	= new PlotGraph();
		graphTrg 	= new PlotGraph();

		graphVal.setPlotColor(new ASColor(ASColor.ALIZARIN.getRGB()), 0);
		graphVal.setPlotColor(new ASColor(ASColor.PETER_RIVER.getRGB()), 2);
		graphVal.setPlotColor(new ASColor(ASColor.EMERALD.getRGB()), 1);

		graphValI.setPlotColor(new ASColor(ASColor.AMETHYST.getRGB()));
		graphBkG.setPlotColor(new ASColor(ASColor.PETER_RIVER.getRGB()));
		graphTrg.setPlotColor(new ASColor(ASColor.ALIZARIN.getRGB()));

		this.cacheAsBitmap = true;
	}

	/**
	 * 
	 * @param	log
	 */
	public function setLinearYScale(linear:Bool):Void
	{
		graphVal.setlinearScale(linear);
		graphValI.setlinearScale(linear);
		graphBkG.setlinearScale(linear);
		graphTrg.setlinearScale(linear);
	}

	/**
	 * 
	 */
	public function eraseValues():Void
	{
		graphVal.eraseValues();
		graphValI.eraseValues();
		graphBkG.eraseValues();
		graphTrg.eraseValues();
		iCount = 0;
	}

	/**
	 * 
	 */
	public function resetMinAndMaxYValues() 
	{
		graphVal.resetMinAndMaxYValues();
		graphValI.resetMinAndMaxYValues();
		graphTrg.resetMinAndMaxYValues();
	}

	/**
	 * 
	 * @param	bmData
	 */
	public function drawBitmapObjectOnBm(bmData:BitmapData) 
	{
		//var mat:Matrix = new Matrix();
		//mat.translate(32, 32);
		//mat.scale(0.64, 0.64);
		
		graphVal.setDrawingOnPaper();
		drawOverlay(bmData);
		bmData.draw(graphVal, true);
		bmData.draw(graphBkG, true);
		bmData.draw(graphTrg, true);
		graphVal.setDrawingOnScreen();
	}
	
	function drawOverlay(bmData:BitmapData, ?mat:Matrix) 
	{
		
	}

	/**
	 * 
	 */
	public function drawGrid():Void 
	{
		graphVal.drawGrid();
	}

	/**
	 * 
	 */
	public function pushValue(dataObject:DataObject):MinMax
	{
		graphVal.pushValue(iCount,		dataObject.counterF, 	true);
		graphValI.pushValue(iCount,		dataObject.counter, 	true);
		graphTrg.pushValue(iCount, 		dataObject.thresholdCalculated, true);
		graphBkG.pushValue(iCount ++, 	dataObject.noise, 	false);

		return new MinMax(Math.min(graphVal.minValueY, graphTrg.minValueY), Math.max(graphVal.maxValueY, graphTrg.maxValueY));
	}

	/**
	 * 
	 * @param	float
	 * @param	float1
	 * @param	float2
	 * @param	float3
	 */
	public function init(w:Int, h:Int, minX:Float, maxX:Float, minY:Float, maxY:Float) 
	{
		//createBackgroundWithPaper(w, h, false);
		rectPlot = new IntRectangle(0, 0, w, h);

		addChild(graphValI);
		addChild(graphBkG);
		addChild(graphTrg);
		addChild(graphVal);

		graphVal.setLabels(DBTranslations.getText("IDS_UNIT_SECOND"), DBTranslations.getText("IDS_CPS"));

		graphVal.x 	= rectPlot.x;
		graphValI.x = rectPlot.x;
		graphBkG.x 	= rectPlot.x;
		graphTrg.x 	= rectPlot.x;

		graphVal.y 	= rectPlot.y;
		graphValI.y = rectPlot.y;
		graphBkG.y 	= rectPlot.y;
		graphTrg.y 	= rectPlot.y;

		graphVal.init(0, 0, rectPlot.width, rectPlot.height, false, mouseMoveFunc);
		graphValI.init(0, 0, rectPlot.width, rectPlot.height, true); // Overlay
		graphBkG.init(0, 0, rectPlot.width, rectPlot.height, true); // Overlay
		graphTrg.init(0, 0, rectPlot.width, rectPlot.height, true); // Overlay

		setXYRange(minX, maxX, minY, maxY);
		Main.root1.addEventListener(PanelEvents.EVT_USER_LOGGING, onUserLogging);
		graphVal.setColorBackground(new ASColor(ASColor.MIDNIGHT_BLUE.getRGB()));

		drawValues();
	}

	/**
	 * 
	 * @param	e
	 */
	function mouseMoveFunc(e:MouseEvent) 
	{
		graphVal.showValuesUnderCursor(e);
		graphBkG.showValuesUnderCursor(e);
		graphTrg.showValuesUnderCursor(e);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onUserLogging(e:Event):Void 
	{
		graphValI.visible = Model.priviledgeAdmin;
	}

	/**
	 * 
	 */
	public function drawValues():Void
	{
		graphVal.drawValues();
		if (drawAll && Model.priviledgeAdmin) graphValI.drawValues();
		graphBkG.drawValues();
		graphTrg.drawValues();
	}

	public function setXRange(minXIn:Float, maxXIn:Float):Void
	{
		graphVal.setXRange(minXIn, maxXIn);
		graphValI.setXRange(minXIn, maxXIn);
		graphBkG.setXRange(minXIn, maxXIn);
		graphTrg.setXRange(minXIn, maxXIn);
	}

	/**
	 * 
	 * @param	minXIn
	 * @param	maxXIn
	 */
	public function setYRange(minMax:MinMax):Void
	{
		graphVal.setYRange(minMax);
		graphValI.setYRange(minMax);
		graphBkG.setYRange(minMax);
		graphTrg.setYRange(minMax);
	}

	/**
	 * 
	 * @param	rangeX
	 * @param	minY
	 * @param	maxY
	 */
	public function setXYRange(minXIn:Float, maxXIn:Float, minYIn:Float, maxYIn:Float):Void
	{
		setXRange(minXIn, maxXIn);
	}
}