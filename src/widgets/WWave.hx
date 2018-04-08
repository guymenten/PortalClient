package widgets;
import flash.display.Sprite;
import org.aswing.ASColor;

/**
 * ...
 * @author GM
 */
class WWave extends Sprite
{

	public function new() 
	{
		super();

		_drawWave();
	}

	/**
	 * 
	 */
	function _drawWave() 
	{
		var gfx = graphics;
		gfx.lineStyle(0, 0, 0);
		gfx.beginFill(ASColor.ALIZARIN.getRGB());
		gfx.drawCircle(0, 0, 10);
		gfx.endFill();
	}	
}