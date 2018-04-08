package widgets;

import events.PanelEvents.ParameterEvent;
import flash.display.Bitmap;
import util.Fading;
import util.Images;

/**
 * ...
 * @author GM
 */
class WLed extends WBase
{
	var bmFillOff:Bitmap;
	var bmFillGreen:Bitmap;
	var bmFillRed:Bitmap;
	var bmFillYel:Bitmap;

	public function new(name:String) 
	{
		super(name);

		bmFillOff 	= Images.loadLEDSteel();
		bmFillGreen = Images.loadLEDGreenSteel();
		bmFillRed 	= Images.loadLEDSteel();
		bmFillYel 	= Images.loadLEDSteel();

		Images.resize(bmFillOff, 24, 24);
		Images.resize(bmFillGreen, 24, 24);

		addChild(bmFillOff);
		addChild(bmFillGreen);

		bmFillGreen.visible = false;
	}

	/**
	 * 
	 * @param	e
	 */
	override function onDataRefresh(e:ParameterEvent):Void
	{	
		setGreen();
		haxe.Timer.delay(hideLed, 500); // iOS 6
	}

	/**
	 * 
	 */
	function hideLed() 
	{
		setOff();
	}
	public function setOff():Void
	{
		//bmFillGreen.visible = false;
		bmFillRed.visible 	= false;
		bmFillYel.visible 	= false;
		Fading.fadeOut(bmFillGreen, 0, 0.2);
	}

	public function setGreen():Void
	{
		Fading.fadeOut(bmFillGreen, 1, 0.2);
	}

	public function setRed():Void
	{
		bmFillRed.visible = true;
	}

	public function setYellow():Void
	{
		bmFillYel.visible = true;
	}
}