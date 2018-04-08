package widgets;

import db.DBDefaults;
import enums.Enums.PanelState;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import panesmain.MainWindow;
import util.ScreenManager;

/**
 * ...
 * @author GM
 */
class WBig extends Widget
{
	public var mainWindow	:MainWindow;
	var frameWidget			:Sprite;

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

		if (x > rect.width)
			x = 0;

		if (y > rect.height)
			y = 0;

		frameWidget = new Sprite();
		drawBackground();
		addChild(frameWidget);

		if (cast DBDefaults.getIntParam(Parameters.paramServerMode))
		{
			mainWindow = new MainWindow();
			addChild(mainWindow);
		}

		Main.root1.addEventListener(PanelEvents.EVT_PANEL_STATE, onStateRefresh);
		Main.root1.addEventListener(PanelEvents.EVT_BACK_COLOR_CHANGED, onColorChanged);
		onStateRefresh(null);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onColorChanged(e:Event):Void 
	{
		drawBackground();
	}

	/**
	 * 
	 */
	function drawBackground() 
	{
		var gfx = frameWidget.graphics;
		gfx.clear();
		gfx.beginFill(DBDefaults.getIntParam(Parameters.paramBackgroundColor));
		gfx.drawRoundRect(-8, -8, 16 + Model.WIDTH + 12, 16 + Model.HEIGHT + 12, 10);
		gfx.endFill();
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
	 * @param	evt
	 */
	function onStateRefresh(e:StateMachineEvent):Void
	{
		if (Main.model == null)
			return;

	//	var state:PanelState = Main.model.get_stateMachine();
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
