package statemachine;
import flash.events.EventDispatcher;
import events.PanelEvents;
import enums.Enums;
import error.Errors;
import org.aswing.ASColor;
import sound.SoundPlay;
import sound.Sounds;

/**
 * ...
 * @author GM
 */
class StateColor
{
	static var alpha:Float = 1;
	public static var backColorInStart:ASColor 			= new ASColor(ASColor.CLOUDS.getRGB(), alpha);
	public static var backColorInInit:ASColor 			= new ASColor(ASColor.CLOUDS.getRGB(), alpha);
	public static var backColorInInitBusy:ASColor 		= new ASColor(ASColor.CLOUDS.getRGB(), alpha);
	public static var backColorInInUse:ASColor  		= new ASColor(ASColor.EMERALD.getRGB(), alpha);
	public static var backColorInControlling:ASColor 	= new ASColor(ASColor.ORANGE.getRGB(), alpha);
	public static var backColorInTest					= new ASColor(ASColor.SUN_FLOWER.getRGB(), alpha);
	public static var backColorInRAAlarm:ASColor 		= new ASColor(ASColor.ALIZARIN.getRGB(), alpha);
	public static var backColorInBKG:ASColor 			= new ASColor(ASColor.BELIZE_HOLE.getRGB(), alpha);
	public static var backColorInOUT:ASColor 			= new ASColor(ASColor.ALIZARIN.getRGB(), alpha);
	public static var backColorInUnknown:ASColor		= new ASColor(ASColor.CLOUDS.getRGB(), alpha);
	public static var backColorInSpeed:ASColor			= new ASColor(ASColor.AMETHYST.getRGB(), alpha);
}

class OldStateMachine extends StateMachine
{
	var _stateMachine:PanelState;
	var evt:StateMachineEvent;
	var _portalBusy:Bool; // Set
	var previousState:PanelState;
	public var inRAAlarmToAck:Bool;
	var panelInitialization:PanelInitialization;
	var _portalInUse:Bool;

public function new() 
	{
		super();

		evt = new StateMachineEvent();
	}

	/**
	 * 
	 * @return
	 */
	public function get_stateMachine():PanelState 
	{
		return _stateMachine;
	}

	/**
	 * 
	 * @param	value
	 * @return
	 */
	function set_stateMachine(value:PanelState):PanelState 
	{
		if (_stateMachine != value)
		{
			_stateMachine = value;
			stateModified(value);
		}

		return value;
	}

	public function stateModified(value:PanelState = null) 
	{
		if (value != null && value != previousState)
		{
			previousState = value;
			evt.stateMachine = value;
			//trace(" ****************************Dispatch State: " + evt.stateMachine);
			if (_portalInUse) panelInitialization.autoThresholdComputing.setDebounce();
			else panelInitialization.autoThresholdComputing.stopDebounce();
		}

		Main.root1.dispatchEvent(new StateMachineEvent()); // 0 for all channels		return true;
	}

	/**
	 * 
	 */
	public var stateMachine (get_stateMachine, set_stateMachine):PanelState;	
}