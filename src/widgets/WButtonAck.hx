package widgets;

import comp.ButtonMenu;
import flash.display.Bitmap;

/**
 * ...
 * @author GM
 */
class WButtonAck extends ButtonMenu
{

	public function new(bmData:Bitmap, label:String, xIn:Int, yIn:Int, bitmapName:Bool = true, wIn:Int = 48, hIn:Int = 48)
	{
		super(bmData, label, xIn, yIn, bitmapName, wIn, hIn);
	}
}