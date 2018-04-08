package widgets;

import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BitmapFilter;
import haxe.Timer;
import org.aswing.ASColor;
import org.aswing.JLabel;
//import promhx.Deferred;
//import promhx.Promise;
//import utilities.statemachine.State;
import tweenx909.TweenX;

/**
 * ...
 * @author GM
 */
class WScale extends WBase
{
	static public inline var WI:Int 	= 8;
	static public inline var WI2:Int 	= 4;
	var center		:Sprite;
	var wises		:Sprite;
	var clock		:Sprite;
	var xLabels		:Array<JLabel>;
	var valueLabel:JLabel 	= new JLabel();
	var dX			:Int = 48;
	var radiusFrame	:Int = 50;
	var radiusOut	:Int = 46;
	var radiusTick	:Int = 40;
	var radiusPoint	:Int = 44;
	var radiusWise	:Int = 38;
	var centX		:Int;
	var centY		:Int;
	var min			:Int;
	var max			:Int;
	var diff		:Float = 100;
	var valueTemp	:Float = 0;
	var value		:Float = 0;
	var ratio		:Float;
	var timer		:Timer;

	public function new(nameIn:String, filtersIn:Array<BitmapFilter>=null, ?dup = false) 
	{
		super(nameIn, filtersIn, dup);

		centX = centY = cast dX / 2;

		clock 			= new Sprite();
		wises 			= new Sprite();
		center 			= new Sprite();
		xLabels 		= new Array();

		drawClock();
		addChild(wises);
		drawCenter();
		drawDigitalValue();

		timer = new Timer(2000);

		//addEventListener(Event.ENTER_FRAME, onEnterFrame);

		setRange(0, 80000, 1000);
		setValue(44000);
		refresh();
	}

	/**
	 * 
	 */
	public override function refresh()
	{
		if (DefaultParameters.scaleEnabled)
		{
			timer = new Timer(2000);
			timer.run = onTimer;
		}
		else
			timer.stop();
	}
	
	/**
	 * 
	 * @param	name
	 */	
	public override function duplicate(name:String):WScale
	{
		trace("duplicateScale()");
		return new WScale(name, true);
	}

	private function onTimer():Void 
	{
		//Main.root1.dispatchEvent(new Event(Event.ENTER_FRAME)); // 0 for all channels		return true;

		setValue(cast (Math.random() * 80000));
	}

	/**
	 * 
	 * @param	min
	 */
	function setRange(min:Int, max:Int, div:Int) 
	{
		this.min 	= min;
		this.max 	= max;

		diff 		= max - min;
		ratio 		= 360 / diff;
		var value	:Float = cast min;

		for (label in xLabels)
		{
			label.setText(cast (cast(value / div, Int)));
			value += cast(diff / 12);
		}
	}

	/**
	 * 
	 * @param	min
	 */
	function setValue(valIn:Int) 
	{
		TweenX.tweenFunc1(displayValue, valueTemp, valIn);
		valueTemp = valIn;
	}

	function displayValue(val:Float) 
	{
		//TweenX.
		valueLabel.setText(cast(cast (val, Int)));
		value = (val - min) * ratio;
		_drawWises();
	}

	/**
	 * 
	 */
	function drawDigitalValue() 
	{
		valueLabel.setFont(valueLabel.getFont().changeSize(12));
		valueLabel.setFont(valueLabel.getFont().changeBold(true));
		valueLabel.setComBoundsXYWH(6, 20, 40, 12);
 
		addChild(valueLabel);
	}

	/**
	 * 
	 */
	function drawCenter() 
	{
		var gfx = center.graphics;
		gfx.beginFill(ASColor.WET_ASPHALT.getRGB(), 1);
		gfx.drawCircle(centX, centY, 20);
		addChild(center);
	}

	/**
	 * 
	 */
	function drawClock()
	{
		var secAngle:Float;
		var minAngle:Float;
		var hourAngle:Float;
		var radians:Float;

		addChild(clock);
		//just a movieClip that will hold the 3 arrows.
		var arrows:Sprite = new Sprite();

		//draws the basic chape of the clock. i chose the most borring colors for this -.-'
		var gfx = clock.graphics;
		gfx.lineStyle(1, ASColor.CLOUDS.getRGB());
		gfx.beginFill(ASColor.CLOUDS.getRGB(), 1);
		gfx.drawCircle(centX, centY, radiusFrame);

		//puts a little line for every 6 degrees on the circle, which will add up to 60.
		gfx.lineStyle(3, ASColor.WET_ASPHALT.getRGB());
		for(i in 0 ... 60){
			//this converts degrees to radians.
			radians = i*6 * Math.PI/180;

			//draws a 10 pixel line, using sine, and cosine.
			gfx.moveTo(Math.cos(radians) * radiusOut + centX, Math.sin(radians) * radiusOut + centY);
			gfx.lineTo(Math.cos(radians) * radiusPoint + centX, Math.sin(radians) * radiusPoint + centY);
		}

		//basicly the same, but for every 30 degrees, which ads up 12.
		gfx.lineStyle(3, ASColor.WET_ASPHALT.getRGB());
		var tempX, tempY:Float;
	
		for(j in 3 ... 15){
			radians = j * 30 * Math.PI / 180;

			//make a thicker line to indicate hours.
			gfx.moveTo(Math.cos(radians) * radiusOut + centX, Math.sin(radians) * radiusOut + centY);
			tempX = Math.cos(radians) * radiusTick + centX;
			tempY = Math.sin(radians) * radiusTick + centY;
			gfx.lineTo(tempX, tempY);

			var vLabel:JLabel 	= new JLabel();
			vLabel.setForeground(ASColor.WET_ASPHALT);
			vLabel.setFont(vLabel.getFont().changeSize(10));
			vLabel.setComBoundsXYWH((cast tempX*0.8) - 6, cast tempY*0.8, 20, 10);

			clock.addChild(vLabel);
			xLabels.push(vLabel);
		}
		addChild(clock);
	}

	/**
	 * 
	 */
	function _drawWises():Void 
	{
		var gfx = wises.graphics;
		gfx.clear();

		//Handle the scale arrow.
		var angle = ((getValue() + 90)) * Math.PI / 180;
		
		//trace (angle);
	
		gfx.lineStyle(1, ASColor.ALIZARIN.getRGB());
		gfx.beginFill(ASColor.ALIZARIN.getRGB(), 1);
		gfx.moveTo(centX, centY);
		gfx.moveTo(centX + Math.cos(angle-WI2) * WI, centY + Math.sin(angle-WI2) * WI);
		gfx.lineTo(Math.cos(angle) * radiusWise + centX, Math.sin(angle) * radiusWise + centY);
		gfx.lineTo(Math.cos(angle+WI2) * WI + centX, Math.sin(angle+WI2) * WI + centY);
		gfx.lineTo(centX, centY);
		gfx.endFill();
	}

	/**
	 * 
	 */
	//function test()
	//{
	  //// Set up two async processes, each returning a promise
        //var a = asyncPromiseReturningRandomInt(500);
        //var b = asyncPromiseReturningRandomInt(2000);
 //
        //// Add a handler to be called when both async processes are resolved
        //Promise.when(a.promise(), b.promise()).then(function(aValue, bValue) {
            //trace('Both promises resolved! Sum: ${aValue + bValue}');
        //});
	//}
	
	///**
	 //* 
	 //* @param	timeoutMs
	 //* @return
	 //*/
    //static function asyncPromiseReturningRandomInt(timeoutMs:Int) : Deferred<Int>
    //{
        //var p = new Deferred<Int>();
        //Timer.delay(function() {
            //var randomInt = Std.int(Math.random() * 100);
            //trace('Resolve promise with random value $randomInt');
            //p.resolve (randomInt);
        //}, timeoutMs);
        //return p;
    //}
	/**
	 * 
	 */
	public function getValue() :Float
	{	
		return value;
	}
	
}