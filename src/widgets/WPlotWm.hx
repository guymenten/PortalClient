package widgets;

import data.DataObject;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;


/**
 * ...
 * @author GM
 */
class WPlotWm extends WPlot
{
	public var watermark		:WWatermark;

	public function new(name:String, dataObjectIn:DataObject, parent:Dynamic = null) 
	{
		super(name, dataObjectIn, parent);
		
		watermark = new WWatermark();
		addChild(watermark);
	}

	/**
	 * 
	 * @param	float
	 * @param	float1
	 * @param	float2
	 * @param	float3
	 */
	public override function init(w:Int, h:Int, minX:Float, maxX:Float, minY:Float, maxY:Float) 
	{
		super.init(w, h, minX, maxX, minY, maxY);
	}

	override function drawOverlay(bmData:BitmapData, ?mat:Matrix) 
	{
		bmData.draw(watermark, mat);
	}

	/**
	 * 
	 */
	public override function drawValues():Void
	{
		super.drawValues();

		watermark.drawWaterMark(40, 40, 160);
	}

	/**
	 * 
	 * @param	waterMark
	 */
	public function setWaterMarkBitmap(wm:Bitmap) 
	{
		watermark.setWaterMarkBitmap(wm);
	}
}