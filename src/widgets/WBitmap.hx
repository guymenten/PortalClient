package widgets;

import flash.display.Bitmap;
import util.Images;

/**
 * ...
 * @author GM
 */
class WBitmap extends WBase
{
	public function new(name:String, bitmap:Bitmap, size:Int) 
	{
		super(name);

		Images.resize(bitmap, size);
		addChild(bitmap);
	}
}