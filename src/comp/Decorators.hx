package comp;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import org.aswing.ASColor;
import org.aswing.Component;
import org.aswing.geom.IntRectangle;
import org.aswing.graphics.Graphics2D;
import org.aswing.graphics.SolidBrush;
import org.aswing.GroundDecorator;
import org.aswing.plaf.UIResource;

/**
 * ...
 * @author GM
 */
class Decorators
{

	public function new() 
	{
		
	}
	
}

/**
 * 
 */
class WDragDecorator implements GroundDecorator
{
    private var shape:Shape;

	public function new() 
	{
		shape = new Shape();
	}
	
	/* INTERFACE org.aswing.GroundDecorator */
	
	public function updateDecorator(c:Component, g:Graphics2D, bounds:IntRectangle):Void 
	{
		shape.graphics.clear();
		g = new Graphics2D(shape.graphics);
		var color: ASColor = ASColor.ASBESTOS;
		g.fillRoundRect(new SolidBrush(color), bounds.x, bounds.y, bounds.width, bounds.height, 1);
	}

	/**
	 * 
	 * @param	c
	 * @return
	 */
	public function getDisplay(c:Component):DisplayObject 
	{
		return shape;
	}
	
}

/**
 * 
 */
class TransparentDecorator implements GroundDecorator implements UIResource
{
	private var shape:Shape;
	
	public function new(){
		shape = new Shape();
	}

	public function updateDecorator(c:Component, g:Graphics2D, r:IntRectangle):Void
	{
		shape.visible = c.isOpaque();
    
		if(c.isOpaque()){
    		shape.graphics.clear();
    		g 					= new Graphics2D(shape.graphics);
			var br:SolidBrush 	= new SolidBrush(new ASColor(ASColor.WHITE.getRGB(), 0));
			g.fillRectangle(br, r.x, r.y, r.width, r.height);
		}
	}

	public function getDisplay(c:Component):DisplayObject{
		return shape;
	}
}

/**
 * 
 */
class DraggingDecorator extends TransparentDecorator
{
	public override function updateDecorator(c:Component, g:Graphics2D, r:IntRectangle):Void
	{
		shape.visible = c.isOpaque();
    
		if(c.isOpaque()){
			drawDashedRect(shape,  r.x, r.y, r.width, r.height);
		}
	}
	
	/**
	 * 
	 * @param	xIn
	 * @param	yIn
	 * @param	wIn
	 * @param	hIn
	 * @param	strokeLength
	 * @param	gap
	 * @return
	 */
	function drawDashedRect(rect:Shape, xIn:Float=0, yIn:Float=0, wIn:Float=0, hIn:Float=0, strokeLength:Float=10, gap:Float=4, w:Float = 2)
	{
		if (rect == null)
			rect = new Shape();
		
		rect.graphics.clear();
		drawDashedLine(rect, xIn, yIn, xIn + wIn, yIn, strokeLength, gap, w);
		drawDashedLine(rect, xIn + wIn, yIn, xIn + wIn, yIn + hIn, strokeLength, gap, w);
		drawDashedLine(rect, xIn + wIn, yIn + hIn, xIn, yIn + hIn, strokeLength, gap, w);
		drawDashedLine(rect, xIn + wIn, yIn + hIn, xIn, yIn + hIn, strokeLength, gap, w);
		drawDashedLine(rect, xIn, yIn + hIn, xIn, yIn, strokeLength, gap, w);
	}

	/**
	* @description – returns a sprite with a dashed line
	* @langversion 3.0
	* @usage drawDashedLine( 30, 30, 100, 100, 5, 3 );
	*
	* @param graphicsObject The object where to draw the line
	* @param startX Start X of dashed line
	* @param startY Start Y of dashed line
	* @param endX End X of dashed line
	* @param endY End Y of dashed line
	* @param strokeLength Stroke length of dash
	* @param gap Length of gap between dashes
	*
	* @return sprite containing the dashed line
	*/
	 
	public static function drawDashedLine(shape:Shape, startX:Float = 0, startY:Float = 0, endX:Float = 0, endY:Float = 0, strokeLength:Float = 0, gap:Float = 0, lineWidth:Float = 0.5)
	{
		var lineGraphics:Graphics = shape.graphics;
		lineGraphics.lineStyle( lineWidth, 0x000000, 0.5 );
		 
		//lineGraphics.lineTo( startX, startY );
		 
		// calculate the length of the segment
		var segmentLength:Float = strokeLength + gap;
		 
		// calculate the length of the dashed line
		var deltaX:Float = endX - startX;
		var deltaY:Float = endY - startY;
		 
		//By Pythagorous theorem
		var _delta:Float = Math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
		 
		// calculate the number of segments needed
		var segmentsCount:Float = Math.floor(Math.abs( _delta / segmentLength ));
		 
		// get the angle of the line in radians
		var radians:Float = Math.atan2( deltaY, deltaX );
		 
		// start the line here
		var aX:Float = startX;
		var aY:Float = startY;
		 
		// add these to cx, cy to get next seg start
		deltaX = Math.cos( radians ) * segmentLength;
		deltaY = Math.sin( radians ) * segmentLength;
		 
		// loop through each segment
		for (i in 0 ... cast segmentsCount) {
			lineGraphics.moveTo( aX, aY );
			lineGraphics.lineTo( aX + Math.cos( radians ) * strokeLength, aY + Math.sin( radians ) * strokeLength );
			aX += deltaX; aY += deltaY;
		}
		 
		// handling the last segment
		lineGraphics.moveTo( aX, aY );
		_delta = Math.sqrt( ( endX - aX ) * ( endX - aX ) + ( endY - aY ) * ( endY - aY ) );
		if( _delta > segmentLength ){
		// segment ends in the gap; drawing a full dash
			lineGraphics.lineTo( aX + Math.cos( radians ) * strokeLength, aY + Math.sin( radians ) * strokeLength );
		}
		else if( _delta > 0 ) {
			// segment shorter than dash; draw the remaining only
			lineGraphics.lineTo( aX + Math.cos( radians ) * _delta, aY + Math.sin( radians ) * _delta );
		}
		// move to the end position
		lineGraphics.lineTo( endX, endY );
	}
}
