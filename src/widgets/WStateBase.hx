package widgets;

import enums.Enums.PanelState;
import events.PanelEvents;
import flash.filters.BitmapFilter;
import flash.events.Event;

/**
 * ...
 * @author GM
 */
class WStateBase extends WBase
{
	var oldState	:PanelState;

	/**
	 * 
	 * @param	nameIn
	 *
	 */
	public function new(nameIn:String, filtersIn:Array<BitmapFilter> = null, ?duplicating:Bool = false)
	{
		super(nameIn);
		
		Main.root1.addEventListener(PanelEvents.EVT_PANEL_STATE, OnState);

	}

	/**
	 * 
	 * @param	evt
	 */
	private function OnState(evt:StateMachineEvent = null):Void {
/*		var state:PanelState 	= Model.panelStateMachine.stateMachine;

		if (true || (state != oldState))
		{
			oldState = state;
			stateChanged(state);
		}	
		*/
	}
	
	public function stateChanged(state:PanelState) {}

}