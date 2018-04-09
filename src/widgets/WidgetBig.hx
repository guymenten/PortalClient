package widgets;

import db.DBDefaults;
import enums.Enums.Parameters;
import flash.display.Sprite;
import panesmain.MainWindow;
import util.Filters;

/**
 * ...
 * @author GM
 */
class WBig extends Widget
{
	public var mainWindow:MainWindow;

	/**
	 * 
	 */
	public function new()
	{
		super();

		createWidget();

		x = cast DBDefaults.getIntParam(Parameters.paramWindowposX);
		y = cast DBDefaults.getIntParam(Parameters.paramWindowposY);
		var rect:Rectangle = ScreenManager.getMaximumAvailableResolution();			

		//if (x - Capabilities.screenResolutionX < 200)
			//x = 0;

		createbackground();

		if (cast DBDefaults.getIntParam(Parameters.paramServerMode))
		{
			mainWindow = new MainWindow();
			addChild(mainWindow);
			mainWindow.scaleX	= Model.ScaleX;
			mainWindow.scaleY	= Model.ScaleY;
		}
	}

	/**
	 * 
	 */
	function createbackground() 
	{
		var frameWidget = new Sprite();
		var gfx = frameWidget.graphics;
		gfx.beginFill(DBDefaults.getIntParam(Parameters.paramBackgroundColor));
		gfx.drawRoundRect(0, 0, Model.WIDTH * Model.ScaleX, Model.HEIGHT * Model.ScaleY, 10);
		gfx.endFill();
		frameWidget.filters = Filters.centerWinFilters;
		addChild(frameWidget);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onDataRefresh(e:ParameterEvent):Void 
	{
		if (e.parameter == "DATA")
		{
		}	
	}

	/**
	 *
	 */
	override function saveWinPos():Void
	{
		super.saveWinPos();

		Model.dbDefaults.setIntParam(Parameters.paramWindowposX, cast x);
		Model.dbDefaults.setIntParam(Parameters.paramWindowposY, cast y);
	}

	/**
	 *
	 */
	public function bringToFront(sprite:Sprite):Void
	{
		sprite.parent.setChildIndex(sprite, sprite.parent.numChildren - 1);
	}
}
