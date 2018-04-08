package widgets;
import comp.BitmapsFaded;
import enums.Enums.PanelState;
import events.PanelEvents;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filters.BitmapFilter;
import flash.utils.Timer;
import util.Filters;
import util.Images;

/**
 * ...
 * @author GM
 */
class WSignalLight extends WStateBase
{
	var spriteSignal		:BitmapsFaded;
	var bmCurrent			:Bitmap;
	var alarmActive			:Bool;

	/**
	 * 
	 * @param	nameIn
	 * @param	filtersIn
	 */
	public function new(nameIn:String, filtersIn:Array<BitmapFilter> = null) 
	{
		super(nameIn, filtersIn);

		spriteSignal 			= new BitmapsFaded(Images.loadSignalNeutral());
		spriteSignal.filters	= Filters.centerWinFilters;

		addChild(spriteSignal);
		Main.root1.addEventListener(PanelEvents.EVT_TEST_MODE_TOGGLE, onTestToggle);
	}

	/**
	 * 
	 * @param	index
	 */
	private function onTestToggle(e:Dynamic):Void 
	{
		switch(e.parameter)
		{
			case 1: spriteSignal.setNewBitmap(Images.loadSignalRed());
			case 2: spriteSignal.setNewBitmap(Images.loadSignalOrange());
			case 3: spriteSignal.setNewBitmap(Images.loadSignalGreen());
			case 4: spriteSignal.setNewBitmap(Images.loadSignalRed());
		}
	}

	/**
	 * 
	 */
	public override function stateChanged(state:PanelState) 
	{

		spriteSignal.setNewBitmap(Main.model.statusStateArray[state.getIndex()].signalFunction());
		Main.root1.dispatchEvent(new Event((state == PanelState.INUSE) ? PanelEvents.EVT_GREEN_LIGHT : PanelEvents.EVT_RED_LIGHT)); // restart the BKG measurement
	}

}