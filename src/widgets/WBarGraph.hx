package widgets;

import data.DataObject;
import events.PanelEvents.ParameterEvent;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import org.aswing.ASColor;
import org.aswing.JLabel;
import sound.Sounds;

/**
 * ...
 * @author GM
 */
class Led extends Sprite
{
	public var color:ASColor;

	public function new(colorIn:ASColor)
	{
		super();
		color = colorIn;
	}
}

/**
 * 
 */
class WBarGraph extends WBase
{
	var inAlarm				:Bool = true;
	var dataObject			:DataObject;
	var label				:JLabel;
	var thrRect				:Sprite;
	var thrRectInAlarm		:Sprite;
	var ledsActiveArray		:Array<Led>;
	var ledsInactiveArray	:Array<Led>;
	var thr					:Float;
	var X					:Int;
	var Y					:Int;
	var dX					:Int = 20;
	var dY					:Int = 16;
	var dY1					:Int = 16;
	var ledsNumber			:Int;
	var minValue			:Int;
	var maxValue			:Int;
	var ratio				:Float;
	var range				:Int;
	var peakRect			:Sprite;

	var timerPeak			:Timer;
	var peakValue			:Float = 0;
	var peakDecrement		:Float;
	var delayPeak			:Int = 2000;
	var timePeak			:Int = 20;
	var thrValue			:Float;
	var onthrMove			:Dynamic->Void;
	var onthrStop			:Dynamic->Void;
	var lastValue			:Float;

	/**
	 * 
	 * @param	name
	 */
	public function new(name:String, ?funcMove:Dynamic->Void, ?funcStop:Dynamic->Void)
	{
		super(name);

		onthrMove = funcMove;
		onthrStop = funcStop;
		
		timerPeak = new Timer(100);
		timerPeak.addEventListener(TimerEvent.TIMER, onPeakTimer);		

		_addTitle();

		Y =  16 * dY;
		thrRect 			= new Sprite();
		thrRectInAlarm 		= new Sprite();
		peakRect 			= new Sprite();
		_drawBarGraphThreshold();
		_drawBarGraphPeak();

		thrRect.addEventListener (MouseEvent.MOUSE_DOWN, startThrDrag);

		_addLeds();

		addChild(peakRect);
		addChild(thrRect);
		thrRect.addChild(thrRectInAlarm);

		setMinMax(0, 100, 60);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPeakTimer(e:TimerEvent):Void 
	{
		timerPeak.delay	= timePeak;
		timerPeak.stop();

		if (peakValue > lastValue) {
			peakValue		-= peakDecrement;
		}
		else {
			peakValue 		= Math.max(0, peakValue);
			movePeakCursor(peakValue);

			if (peakValue > 0) {
				timerPeak.start();
			}			
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function movePeakCursor(value:Float):Void 
	{
		var peak:Int	= cast (-value / ratio);
		peakRect.y		= peak * dY1;
		//trace(peakRect.y);
	}

	/**
	 * 
	 * @param	e
	 */
	private function moveThrDrag(e:MouseEvent):Void 
	{
		thrRect.x 		= 0;

		if (thrRect.y > 0) {
			thrRect.y = 0;
		}

		if (thrRect.y < -(height - thrRect.height)) {
			thrRect.y = -height + thrRect.height;
		}

		thrValue = range * ( -thrRect.y / height);
		if (cast onthrMove) {
			onthrMove(thrValue);
		}
	
	}

	/**
	 * 
	 * @param	e
	 */
	private function startThrDrag(e:MouseEvent):Void 
	{
		thrRect.addEventListener (MouseEvent.MOUSE_MOVE, moveThrDrag);
		addEventListener (MouseEvent.MOUSE_OUT, stopThrDrag);
		addEventListener (MouseEvent.MOUSE_UP, stopThrDrag);
		thrRect.startDrag();
	}

	/**
	 * 
	 * @param	e
	 */
	private function stopThrDrag(e:MouseEvent):Void 
	{
		removeEventListener (MouseEvent.MOUSE_MOVE, moveThrDrag);
		removeEventListener (MouseEvent.MOUSE_OUT, stopThrDrag);
		removeEventListener (MouseEvent.MOUSE_UP, stopThrDrag);
		thrRect.stopDrag();
		thrRect.x = 0;
		if (cast onthrStop) {
			onthrStop(thrValue);
		}
	}

	/**
	 * 
	 */
	public function setValue(value:Float)
	{
		lastValue 	= value;
		var temp 	= value / ratio;

		if (peakValue < value) {
			timerPeak.delay = delayPeak;
			peakValue = value;
			timerPeak.stop();
			movePeakCursor(value);
			timerPeak.start();
		}

		label.setText(cast value);

		for (i in 0...ledsActiveArray.length)
		{
			ledsActiveArray[i].visible 		= temp > i;
			ledsInactiveArray[i].visible 	= temp <= i;
		}
	}

	/**
	 * 
	 */
	public function setInAlarm(alarm:Bool)
	{
		thrRectInAlarm.visible = alarm;
	}

	/**
	 * 
	 * @param	min
	 * @param	max
	 */
	public function setMinMax(min:Int, max:Int, thrIn:Float)
	{
		thr				= thrIn;
		minValue 		= min; 
		maxValue 		= max;
		range 			= max - min;
		ratio			= (max - min) / (ledsNumber-1);
		thrRect.y		= ( -thr / ratio) * dY1;

		peakDecrement 	= range / ledsNumber;
	}

	/**
	 * 
	 * @param	colorIn
	 */
	function _addLed(colorIn:Int)
	{
		var ledA = new Led(new ASColor(colorIn, 1));
		var ledI = new Led(new ASColor(ASColor.CLOUDS.getRGB(), 1));

		ledsActiveArray.push(ledA);
		ledsInactiveArray.push(ledI);

		var gfx = ledA.graphics;
		gfx.lineStyle(0, 0, 0);
		gfx.beginFill(colorIn);
		gfx.drawRect(X, Y, dX, dY-1);
		gfx.endFill();

		this.addChild(ledA);

		var gfx = ledI.graphics;
		gfx.lineStyle(0, 0, 0);
		gfx.beginFill(colorIn, 0.1);
		gfx.drawRect(X, Y, dX, dY-1);
		gfx.endFill();
		Y -= dY1;
		ledsNumber ++;

		this.addChild(ledI);
	}

	/**
	 * 
	 */
	function _drawBarGraphThreshold()
	{
		var gfx = thrRect.graphics;
		var col = ASColor.RED.getRGB();

		gfx.clear();
		gfx.lineStyle(4, col, 1);
		gfx.beginFill(0, 0);
		gfx.drawRect(X, Y, dX, dY);
		gfx.endFill();

		gfx.lineStyle(0, 0, 0);
		gfx.beginFill(0, 0);
		gfx.drawRect(X - dX, Y, dX * 3, dY);
		gfx.endFill();

		gfx = thrRectInAlarm.graphics;
		gfx.lineStyle(0, 0, 0);
		gfx.beginFill(col);
		gfx.drawRect(X, Y, dX, dY);
		gfx.endFill();
	}

	/**
	 * 
	 */
	function _drawBarGraphPeak()
	{
		var gfx = peakRect.graphics;

		gfx.lineStyle(2, 0xffffff, 1);
		gfx.beginFill(0, 0);
		gfx.drawRect(X, Y, dX, dY);
		gfx.endFill();
	}

	/**
	 * 
	 */
	function _addLeds():Void 
	{
		ledsActiveArray 	= new Array<Led> ();
		ledsInactiveArray 	= new Array<Led> ();
		_addLed(0x00ff00); // Green
		_addLed(0x00ff00); // Green
		_addLed(0x00ff00); // Green
		_addLed(0x00ff00); // Green
		_addLed(0x00ff00); // Green
		_addLed(0x00ff00); // Green
		_addLed(0x00ff00); // Green
		_addLed(0x00ff00); // Green

		_addLed(0xc8f122);
		_addLed(0xc8f122);
		_addLed(0xf5dd0f);
		_addLed(0xfbac01); // Orange
		_addLed(0xff0000); // Red
		_addLed(0xeb3463);
		_addLed(0xc92751);
		_addLed(0xb20834); // Red
	}

	/**
	 * 
	 */
	function _addTitle():Void 
	{
		label	= new JLabel();
		//addChild(label);
		label.setFont(label.getFont().changeSize(8));
		label.setFont(label.getFont().changeBold(true));
		label.setComBoundsXYWH(cast x - 10, cast y - 10, cast width, 8);
	}

}