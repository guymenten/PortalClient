package widgets;

import flash.display.Sprite;
import org.aswing.ASColor;
import org.aswing.geom.IntRectangle;
import org.aswing.JLabel;
import tweenx909.rule.RgbX;
import tweenx909.TweenX;
import util.Filters;


/**
 * ...
 * @author GM
 */
class WIndicator extends WBase
{
	public var lightArea:Sprite;
	public var label:JLabel;

	var backColorStateActive:ASColor;
	var textColorStateActive:ASColor;

	var butWidth:Int;
	var butHeight:Int;

	var textLabel:String;

	public var rectBut:IntRectangle;
	public var rectLight:IntRectangle;

	var fontSize:Int 			= 20;
	static var butWidthDefault 	= 99;
	static var butHeightDefault = 28;
	var activated:Bool;
	var currentBackColor:ASColor;
	var currentTextColor:Int;

	public function new(name:String, textIn:String, colorIn:ASColor, colTextIn:ASColor, wIn:Int, hIn:Int, fontSizeIn:Int) 
	{
		super(name);
		
		activated 			= true;
		currentBackColor 	= colorIn;

		fontSize			= fontSizeIn;

		if (hIn == 0)
			butHeight = butHeightDefault;
		else
			butHeight = hIn;

		if (wIn == 0)
			butWidth = butWidthDefault;
		else
			butWidth = wIn;

		var fat:Bool = hIn > butHeightDefault;

		rectBut 	= new IntRectangle(0 , 0,  butWidth, butHeight);
		rectLight 	= rectBut.clone();

		backColorStateActive 	= colorIn;
		textColorStateActive 	= colTextIn;
		lightArea 				= new Sprite();

		//rectLabel.setLocation(;
		label 					= new JLabel("");
		label.setComBounds(rectBut);
		label.y ++;

		label.setFont(label.getFont().changeSize(cast rectBut.height / (fat ? 1.5 : 1.8)));
		textLabel 				= textIn;
		//lightArea.filters 		= Filters.centerWinFilters;		

		init(butWidth);
	}

	/**
	 * 
	 * @param	activated
	 * @param	colorIn
	 */
	function drawBackgroundColor(activatedIn:Bool, colorIn: ASColor):Void
	{
		if ((currentBackColor != colorIn) || (activatedIn != activated))
		{
			var col:ASColor = activatedIn ? colorIn : backColorStateActive.darker(0.2);
			TweenX.tweenFunc(drawBackgroundColorCB, [activatedIn, RgbX.of(currentBackColor.getRGB()), currentBackColor.getAlpha()] , [activatedIn, RgbX.of(col.getRGB()), col.getAlpha()]);

			currentBackColor 	= col;
			activated 			= activatedIn;
		}
	}

	/**
	 * 
	 * @param	col
	 * @param	alpha
	 */
	function drawBackgroundColorCB(activated:Bool, col:Int, alpha:Float) 
	{
		var colorIn:ASColor = new ASColor(col, alpha);
		var gfx = lightArea.graphics;

		gfx.clear();
		gfx.lineStyle(0, 0, 0);
		gfx.beginFill(colorIn.getRGB());
		gfx.drawRoundRect(rectLight.x, rectLight.y, rectLight.width, rectLight.height, 1);
		gfx.endFill();
	}

	public function init(wIn:Int)
	{
		addChild(lightArea);
		addChild(label);
		setText(textLabel);
		setEnabled(false);
		//filters = Filters.winFilters;
	}

	public function setBackgroundColor(col:ASColor)
	{
		drawBackgroundColor(true, col);
	}

	/**
	 * 
	 * @param	activated
	 */
	public override function setEnabled(activatedIn:Bool):Void
	{
		if (activatedIn != activated)
			drawBackgroundColor(activatedIn, backColorStateActive);

		var col:Int 	= activatedIn ? textColorStateActive.getRGB() : ASColor.MIDNIGHT_BLUE.getRGB();
		var alpha:Float = activatedIn ? textColorStateActive.getAlpha() : 0.2;
		TweenX.tweenFunc(drawBackgroundTextColor, [activatedIn, RgbX.of(currentTextColor), 1] , [activatedIn, RgbX.of(col), 1]);

		currentTextColor = col;

		if (textLabel != null)
			label.setText(textLabel);
	}

	/**
	 * 
	 * @param	activated
	 * @param	col
	 * @param	alpha
	 */
	function drawBackgroundTextColor(activated:Bool, col:Int, alpha:Float) 
	{
		label.setForeground(new ASColor(col, alpha));
		label.alpha = alpha;
	}

	/**
	 * 
	 * @param	strIn
	 * @param	sizeIn
	 */
	public function setText(textIn:String):Void
	{
		label.setText(textIn);
	}

	/**
	 * 
	 * @param	col
	 */
	public function setTextColor(col:ASColor) 
	{
		textColorStateActive = col;
		setEnabled(true);
	}
}