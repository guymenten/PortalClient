package panesmain ;

import flash.display.BitmapData;
import flash.display.Sprite;
import util.BitmapUtils;
import util.Images;

/**
 * ...
 * @author GM
 */
@:bitmap("assets/img/WinDesign.png") class WinDesign extends flash.display.BitmapData{}

class SplashScreen extends Sprite
{
	public function new() 
	{
		super();

		visible = false;

		var bm:BitmapSmoothed = new BitmapSmoothed(new WinDesign(0, 0));
		bm.scaleX = Model.WIDTH / bm.width;
		bm.scaleY = Model.HEIGHT/ bm.height;
		addChild(bm);
	}

	/**
	 * 
	 * @param	vis
	 */
	public function setVisible(vis:Bool):Void 
	{
		super.visible = vis;
		//if (vis)
			//Fading.fadeIn(this, 1, 0.5);
//
		//else
			//Fading.fadeOut(this, 0, 0.5);
	}
}