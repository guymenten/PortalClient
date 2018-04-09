package widgets;

import flash.display.Graphics;
import flash.display.Sprite;
import org.aswing.BorderLayout;
import org.aswing.Component;
import org.aswing.graphics.Graphics2D;
import org.aswing.GroundDecorator;

/**
 * ...
 * @author GM
 */
//class BorderDecorator implements GroundDecorator {
//
   //// decorated component
	//var child: Component;
//
   //public function new(component:Component) {
      //child = component;
      ////this.setLayout(new BorderLayout());
      //this.add(child);
   //}
//
   //public function paint(g:Graphics2D) {
      //super.paint(g);
      //var height = this.getHeight();
      //var width = this.getWidth();
      //g.drawRect(0, 0, width - 1, height - 1);
   //}
//}

class WComponent extends Component
{
		
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
	function drawDashedRect(rect:Sprite, xIn:Float=0, yIn:Float=0, wIn:Float=0, hIn:Float=0, strokeLength:Float=0, gap:Float=0, w:Float = 0):Sprite
	{
		if (rect == null)
			rect = new Sprite();
			rect.graphics.clear();
		drawDashedLine(rect, xIn, yIn, xIn + wIn, yIn, strokeLength, gap, w);
		drawDashedLine(rect, xIn + wIn, yIn, xIn + wIn, yIn + hIn, strokeLength, gap, w);
		drawDashedLine(rect, xIn + wIn, yIn + hIn, xIn, yIn + hIn, strokeLength, gap, w);

		return drawDashedLine(rect, xIn, yIn + hIn, xIn, yIn, strokeLength, gap, w);
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
	 
	public static function drawDashedLine(line:Sprite, startX:Float = 0, startY:Float = 0, endX:Float = 0, endY:Float = 0, strokeLength:Float = 0, gap:Float = 0, lineWidth:Float = 1):Sprite
	{
		var lineGraphics:Graphics = line.graphics;
		lineGraphics.lineStyle( lineWidth, 0x000000, 1.0 );
		 
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
	 
		return line;
	}
}