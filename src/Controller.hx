package;

import enums.Enums.PanelState;
import events.PanelEvents;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;
import hxfsm.FSM;
import hxfsm.FSMController;
import hxfsm.integrations.callback.CallbackIntegration;
import statemachine.States;

/**
 * ...
 * @author GM
 */
class Controller extends EventDispatcher
{
	public var fsmController:FSMController;
	var timerRefresh:Timer;

	public function new(?target:IEventDispatcher) 
	{
		super(target);
		
		Main.controller = this;

		var fsm:FSM 	= new FSM(new CallbackIntegration());
		fsmController 	= new FSMController(fsm);		

		// Add states and transitions
        fsm.add(IdleState,			[IdleState, InitialisingState, InErrorState]);
        fsm.add(InitialisingState,	[MeasuringBKG, InErrorState]);
        fsm.add(MeasuringBKG,		[MeasuringBKG, MeasuringRA, InitialisingState, MeasuringWaiting, InErrorState]);
        fsm.add(MeasuringRA,		[MeasuringBKG, InitialisingState, MeasuringWaiting, InErrorState]);
        fsm.add(MeasuringWaiting,	[InitialisingState, MeasuringRA, MeasuringBusy, MeasuringBKG, InErrorState]);
        fsm.add(MeasuringBusy,		[InitialisingState, MeasuringWaiting, MeasuringBKG, InErrorState]);

        fsm.add(InErrorState, 		[]);

		fsmController.goto(IdleState);
		timerRefresh = new Timer(1000); // Init Time
		timerRefresh.start();
		timerRefresh.addEventListener(TimerEvent.TIMER, onTimerRefresh);
		Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_ACK, OnAlarmAck);
	}

	private function OnAlarmAck(e:Event):Void 
	{
		Main.model.alarmAckCnt ++;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onTimerRefresh(e:Event):Void 
	{
		Main.model.timerCnt ++;

		if (Main.model.receivingTimeout ++ >= DefaultParameters.paramErrorTimeout)
		{
			Main.model.receivingData = false;
		}
	}

	/**
	 * 
	 */
	public function restartBKGMeasure() 
	{
		Main.model.portalBKGMeasurement = true;
		Main.model.resetBKGMeasurement = false;
		Main.model.elapsedBKGMeasurement = false;
		Main.model.timeBKGMeasurement = DefaultParameters.bkgMeasureTime;

		Main.model.panelState = PanelState.BKG_MEASURE;
	}

	/**
	 * 
	 */
	public function init() 
	{
		fsmController.goto(InitialisingState);
	}

}