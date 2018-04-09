package widgets;

import db.ResObject;
import flash.filesystem.File;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.ui.Mouse;
import org.aswing.Component;

/**
 * ...
 * @author GM
 */
class WColorPalette extends WSlideShow
{
	var test:Sprite;

	public function new(strName:String, wd:Bool = false) 
	{
		super();

		test = new Sprite();
		test.x = 400;
		test.y = 40;

		addChild(test);
		
		if (wd)
			strName =  File.applicationDirectory.nativePath + strName;

		_addSlideShowToPage(new ResObject(0,"", "", "", 0, "", "strName", "", "", 60, 60, 200, 200));
		//loadPane.addEventListener(MouseEvent.MOUSE_MOVE, getColorSample);
	}

	static public inline var GRID_WIDTH:Float = 20;
	static public inline var SNAP:Float = 10;
	/**
	 * 
	 * @param	e
	 */
	private function getColorSample(e:MouseEvent):Void 
	{		
		if (e.localX % GRID_WIDTH < SNAP)
		{
			e.localX = cast((e.localX / GRID_WIDTH), Int) * GRID_WIDTH;
			//trace(e.localX);
		}
		else if (e.localX % GRID_WIDTH > GRID_WIDTH - SNAP)
		{
			e.localX = (cast(e.localX / GRID_WIDTH) + 1) * GRID_WIDTH;
		}
		else
		{
			//obj.x = e.mouseX;
		}
		//Mouse.cursor.

		var bm:Bitmap = cast loadPane.loader.contentLoaderInfo.content;
		var rgb:UInt = bm.bitmapData.getPixel(cast e.localX / loadPane.loader.contentLoaderInfo.content.scaleX, cast e.localY / loadPane.loader.contentLoaderInfo.content.scaleY);
		if (rgb == 0) rgb = 0xffffff;
		test.graphics.clear();
		test.graphics.beginFill(rgb);
		test.graphics.drawRect(0, 0, 80, 80);
		test.graphics.endFill();
	}

}