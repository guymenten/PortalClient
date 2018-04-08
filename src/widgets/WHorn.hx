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
import widgets.WStateBase;

/**
 * ...
 * @author GM
 */
class WHorn extends WStateBase
{
	var spriteHorn	:BitmapsFaded;
	var alarmActive	:Bool;

	/**
	 * 
	 * @param	nameIn
	 * @param	filtersIn
	 */
	public function new(nameIn:String, filtersIn:Array<BitmapFilter> = null) 
	{
		super(nameIn, filtersIn);

		spriteHorn 			= new BitmapsFaded(Images.loadHornOff());
		spriteHorn.filters	= Filters.centerWinFilters;

		addChild(spriteHorn);
		Main.root1.addEventListener(PanelEvents.EVT_TEST_MODE_TOGGLE, onTestToggle);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onTestToggle(e:Dynamic):Void 
	{
		switch(e.parameter)
		{
			case 1, 3: spriteHorn.setNewBitmap(Images.loadHornOn());
			case 2, 4: spriteHorn.setNewBitmap(Images.loadHornOff());
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private override function OnState(evt:StateMachineEvent = null):Void 
	{
/*		var state:PanelState 	= Model.stateMachine.stateMachine;

		if (state != oldState)
		{
			oldState = state;
			//spriteHorn.setNewBitmap(Model.stateMachine.portalInTest
		}
*/	}
}