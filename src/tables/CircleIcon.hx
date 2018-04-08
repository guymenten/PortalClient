package tables;

import flash.display.DisplayObject;
import flash.display.Sprite;
import org.aswing.ASColor;
import org.aswing.Component;
import org.aswing.graphics.Graphics2D;
import org.aswing.graphics.SolidBrush;
import org.aswing.Icon;

/**
 * 
 */
class CircleIcon implements Icon
{
	private var shape:Sprite;
	private var color:ASColor;
	private var width:Int;
	private var height:Int;

	public function new(color:ASColor, width:Int, height:Int){
		shape = new Sprite();
		this.color = color;
		this.width = width;
		this.height = height;	
	}

	public function updateIcon(com:Component, g:Graphics2D, x:Int, y:Int):Void{
		shape.graphics.clear();
		g = new Graphics2D(shape.graphics);
		g.fillEllipse(new SolidBrush(color), x, y, width, height);
	}

	public function getIconHeight(com:Component):Int{
		return height;
	}

	public function getIconWidth(com:Component):Int{
		return width;
	}

	public function getDisplay(com:Component):DisplayObject  
	{
		return shape;
	}
}