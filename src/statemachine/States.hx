package statemachine;

import enums.Enums.PanelState;
import hx.event.Signal.Slot;
import hxfsm.integrations.callback.ICallbackState;
import sound.Sounds;

/**
 * ...
 * @author GM
 */

class BaseState implements ICallbackState
{
	var slotPortalBusy:Dynamic;
	var slotRefreshCnt:Dynamic;
	var slotTimerCnt:Dynamic;
	var slotInRA:Dynamic;

	public function enter()
	{
		slotRefreshCnt = Main.model.refreshCnt !.add(onRefreshCnt);
		slotTimerCnt = Main.model.timerCnt !.add(onTimerCnt);
		slotPortalBusy = Main.model.portalBusy !.add(onPortalBusy);
	}
	public function exit()
	{
		slotRefreshCnt.dispose();
		slotTimerCnt.dispose();
		slotPortalBusy.dispose();
	}

	public function onRefreshCnt(cnt:Int) {
		Main.model.receivingData = true;
	}

	public function onTimerCnt(cnt:Int) {}
	public function onPortalBusy(busy:Bool) {}
}

/**
 * 
 */
class IdleState extends BaseState implements ICallbackState
{
	public override function enter()
	{
		super.enter();
		Main.model.panelState = PanelState.IDLE;
		Main.model.portalInUse = false;
	}
}

/**
 * 
 */
class InitialisingState extends BaseState implements ICallbackState
{
	var slotResetBKGMeasurement:Dynamic;
	var slotReceivingData:Dynamic;

	public override function enter()
	{
		super.enter();
		
		if (slotResetBKGMeasurement == null)
		{
			slotResetBKGMeasurement = Main.model.resetBKGMeasurement !.add(onSlotResetBKGMeasurement);
			slotReceivingData = Main.model.receivingData !.add(onSlotReceivingData);
		}

		Main.model.panelState = PanelState.INIT;
		trace("InitialisingState...");
		Main.model.portalInUse = false;
	}

	/**
	 * 
	 */
	public function onSlotReceivingData(receiving:Bool) 
	{
		if (receiving)
		{
			
		}
	}

	public override function onRefreshCnt(cnt:Int) 
	{
		//trace("Refresh...");
		super.onRefreshCnt(cnt);
		Main.model.resetBKGMeasurement = true;
	}
	
	/**
	 * 
	 * @param	reset
	 */
	public function onSlotResetBKGMeasurement(reset:Bool)
	{
		if (reset)
		{
			Main.controller.fsmController.goto(MeasuringBKG);
		}
	}
}

/**
 * 
 */
class MeasuringBKG extends BaseState implements ICallbackState
{
	public function new()
	{
	}

	/**
	 * 
	 */
	public override function enter()
	{
		super.enter();

		trace("MeasuringBKG...");

		Main.controller.restartBKGMeasure();
		onPortalBusy(Main.model.portalBusy);
	}

	/**
	 * 
	 * @param	busy
	 */
	public override function onPortalBusy(busy:Bool) 
	{
		if (busy)
		{
			Main.model.strCounterTextLabel = "";
			Main.model.panelState = PanelState.BKG_MEASURE_BUSY;
			Main.controller.restartBKGMeasure();
			Sounds.onPortalBusy();
		}
		else
		{
			Main.model.panelState = PanelState.BKG_MEASURE;
		}
	}

	/**
	 * 
	 * @param	cnt
	 */
	public override function onTimerCnt(cnt:Int) 
	{
		trace("MeasuringBKG: " + Main.model.timeBKGMeasurement);
		
		if (Main.model.isInRAAlarm())
		{
			Main.controller.fsmController.goto(MeasuringRA);
			return;
		}

		if (!Main.model.isBusy())
		{
			Sounds.playBKGClic();
			Main.model.strCounterTextLabel = " " + Main.model.timeBKGMeasurement;

			if (Main.model.timeBKGMeasurement -- == 0) {
				Main.model.elapsedBKGMeasurement = true;
				Main.model.portalBKGMeasurement = false;
				Main.controller.fsmController.goto(MeasuringWaiting);
			}
		}
	}
}

/**
 * 
 */
class MeasuringWaiting extends BaseState implements ICallbackState
{
	var slotBusy:Dynamic;
	var slotRefresh:Dynamic;

	public override function enter()
	{
		super.enter();

		trace("MeasuringWaiting...");
		Main.model.panelState = PanelState.INUSE;
		Main.model.portalInUse = false;
	}
	
	public override function onPortalBusy(busy:Bool) 
	{
		Main.controller.fsmController.goto(MeasuringBusy);
	}
}

/**
 * 
 */
class MeasuringBusy extends BaseState implements ICallbackState
{
	public override function enter()
	{
		super.enter();
		trace("MeasuringBusy...");
		Main.model.panelState = PanelState.INUSE_BUSY;
		Sounds.onPortalBusy();
		Main.model.portalInUse = true;
	}
	
	public override function onPortalBusy(busy:Bool) 
	{
		Main.controller.fsmController.goto(MeasuringWaiting);
	}

}
/**
 * 
 */
class MeasuringRA extends BaseState implements ICallbackState
{
	public override function enter()
	{
		trace("MeasuringRA...");
		Main.model.panelState = PanelState.RA;
		Main.model.portalInUse = true;
	}
	
	public override function exit()
	{
	}
}
/**
 * 
 */
class InErrorState extends BaseState implements ICallbackState
{
	public override function enter()
	{
		trace("InErrorState...");
		Main.model.panelState = PanelState.IN_ERROR;
		Main.model.portalInUse = false;
	}
	
	public override function exit()
	{
	}
}