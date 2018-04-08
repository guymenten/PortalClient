package widgets;

import data.Report;
import events.PanelEvents;
import flash.display.Sprite;
import flash.events.Event;
import org.aswing.ASColor;
import org.aswing.JLabel;
import util.Filters;

/**
 * ...
 * @author GM
 */
class WNotification extends WBase
{
	var bubble			:Sprite;
	var label			:JLabel;
	var GraphWidth		:Int = 8;

	public function new(name:String) 
	{
		super(name);

		bubble 	= new Sprite();
		label 	= new JLabel(); // Trigger

		//bubble.visible = false;

		addChild(bubble);
		bubble.addChild(label);
		_drawNotification();

		label.setFont(label.getFont().changeSize(10));
		label.setFont(label.getFont().changeBold(true));
		label.setComBoundsXYWH(-11, -6, 24, 12);
	}

	/**
	 * 
	 * @param	value
	 */
	public function setValue(value:Int):Void 
	{
		label.setText(cast value);
		//bubble.visible = value > 0;
	}

	/**
	 * 
	 */
	function _drawNotification() 
	{
		var gfx = bubble.graphics;
		gfx.lineStyle(0, 0, 0);
		gfx.beginFill(ASColor.ALIZARIN.getRGB());
		gfx.drawCircle(0, 0, GraphWidth);
		gfx.endFill();
		bubble.filters = Filters.winFilters;
	}	
}