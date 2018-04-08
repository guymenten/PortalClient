package widgets;

import flash.events.Event;
import flash.display.Sprite;
import flash.geom.Rectangle;
import org.aswing.ASColor;
import events.PanelEvents;
import enums.Enums;
import db.DBDefaults;

/**
 * ...
 * @author GM
 */
class WGrid extends WBase
{
	var filmGrid:Sprite;
	var showGrid:Bool;

	public function new(name:String) 
	{
		super(name);

		filmGrid = new Sprite();
		addChild(filmGrid);
		filmGrid.alpha = 0.5;
		filmGrid.visible = false;
		drawGrid(ASColor.GRAY.getRGB());

		if (DBDefaults.getIntParam(Parameters.paramHookMode) ==1)
			Main.root1.addEventListener(PanelEvents.EVT_PANE_HELP, OnGrid);
	}

	/**
	 * 
	 * @return
	 */
	public override  function getMyBounds():Rectangle
	{
		return new Rectangle(0, 0, Model.WIDTH, Model.HEIGHT);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnGrid(e:Event):Void 
	{
		showGrid = !showGrid;
		filmGrid.visible = showGrid;
	}

	/**
	 * 
	 * @param	colgrid
	 */
	function drawGrid(colgrid : Int) : Void
	{
		var X:Int 		= 0;
		var Y:Int 		= 0;
		var XGrid : Int = 0;
		var YGrid : Int = 0;
		
		var XGridIncrement:Int = 8;
		var YGridIncrement:Int = 8;
		
		var gfx = filmGrid.graphics;

		gfx.lineStyle(1, colgrid);
		gfx.moveTo(X, Y);
		var i : Int;
		// Horizontal lines;
		i = 0;
		while(YGrid < Y + Model.HEIGHT)
		{
			gfx.moveTo(X, YGrid);
			gfx.lineTo(X + Model.WIDTH, YGrid);
			YGrid += YGridIncrement;
			i++;
		}

		// Vertical lines
		i = 0;
		while(XGrid < Model.WIDTH)
		{
			gfx.moveTo(X + XGrid, Y);
			gfx.lineTo(X + XGrid, Y + Model.HEIGHT);
			XGrid += XGridIncrement;
			i++;
		}
	}
}