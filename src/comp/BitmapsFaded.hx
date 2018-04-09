package comp;

import flash.display.Bitmap;
import flash.display.Sprite;
import tweenx909.TweenX;
import tweenx909.EaseX;

/**
 * ...
 * @author GM
 */
class BitmapsFaded extends Sprite
{
	var bmOld			:Bitmap;
	var bmNew			:Bitmap;

	public function new(bm:Bitmap = null) 
	{
		super();

		if (cast bm) addChild(bm);

		bmOld 			= new Bitmap();
		bmNew 			= new Bitmap();

		addChild(bmNew);
		addChild(bmOld);
	}

	/**
	 * 
	 * @param	bm
	 */
	public function animateBitmaps(bm1:Bitmap, bm2:Bitmap, repInterval:Float):Void
	{
		bmOld.bitmapData = bm1.bitmapData;
		bmNew.bitmapData = bm2.bitmapData;

		//TweenX.parallel([
			//TweenX.tweenFunc(fadeNewBitmap, [0] , [1], 10),
			//TweenX.tweenFunc(fadeOldBitmap, [1] , [0], 10), ]).repeat().interval(repInterval);
	}

	/**
	 * 
	 */
	public function setNewBitmap(bm:Bitmap):Void
	{
		var bN:Bool = bmNew.alpha == 1;
		trace("setNewBitmap " + bN);
	
		if (bmNew.bitmapData != bm.bitmapData)
		{
			bmNew.bitmapData = bm.bitmapData;

			TweenX.to(bmNew, { alpha: bN } ).delay(0.1).time(1).ease(EaseX.linear);
		}
	}

}