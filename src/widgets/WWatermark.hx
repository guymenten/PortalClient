package widgets;

import flash.display.Bitmap;
import flash.display.Sprite;

/**
 * ...
 * @author GM
 */
class WWatermark extends Sprite
{
	var waterMark	:Bitmap;
	var widthWM		:Float;

	public function new() 
	{
		super();

	}

	/**
	 * 
	 * @param	bm
	 */
	public function setWaterMarkBitmap(bm:Bitmap)
	{
		waterMark	= bm;
		widthWM = bm.width;
		addChild(waterMark);
		//Images.centerBitmap(waterMark, rectPlot.width, rectPlot.height);
	}

	/**
	 * 
	 * @param	w
	 */
	public function drawWaterMark(xIn:Int, yIn:Int, w:Int)
	{
		waterMark.x = xIn;
		waterMark.y = yIn;
		waterMark.scaleX = waterMark.scaleY = w / widthWM;
		//var matrix 	= new Matrix();
		//matrix.translate(32, 32);
		//matrix.scale(0.64, 0.64);
//
		//bm.bitmapData.draw(waterMark, matrix, false);
	}

}