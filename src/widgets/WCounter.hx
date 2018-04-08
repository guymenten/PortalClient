package widgets;

/**
 * ...
 * @author GM
 */

//importing used component classes
import data.DataObject;
import db.DBTranslations;
import enums.Enums.ChannelState;
import events.PanelEvents;
import events.PanelEvents.ParameterEvent;
import events.PanelEvents.StateMachineEvent;
import flash.events.Event;
import org.aswing.ASColor;
import laf.Colors;

/**
 * 
 */
class WCounter extends WIndicatorWithUnits
{
	public var dataObject				:DataObject;
	var _redOnAlarm						:Bool;

	/**
	 * CounterWidget Constructor
	 */
	public function new(name:String, dataObjectIn:DataObject)
	{
		super(name, "", StateColor.backColorInOUT, ASColor.CLOUDS, 124, 52);

		dataObject 					= dataObjectIn;
		setRightText(DBTranslations.getText("IDS_CPS"));
		onParamUpdated();
		
		dataObject.datagramNumber !.add(refreshCounter);
		dataObject.channelState !.add(refreshState);
	}

	/**
	 * 
	 * @param	e
	 */
	private override function onParamUpdated(e:Event = null):Void 
	{
		setTopText(dataObject.label);
	}

	function getBaseID()
	{
		return ("");
	}

	/**
	 * 
	 * @param	e
	 */
	function refreshState(state:ChannelState):Void
	{
		setBackgroundColor(dataObject.getCounterBackColor(_redOnAlarm));
		setTextColor(Main.model.getCounterTextColor(state));
		setValues(dataObject);
	}

	/**
	 * 
	 * @param	e
	 */
	function refreshCounter(cnt:Int):Void
	{	
		setValues(dataObject);
	}

	/**
	 * 
	 * @param	bdf
	 * @param	trigger
	 */
	public function setValues(dataObject:DataObject)
	{
		setText(Main.model.getCounterTextLabel(dataObject));
	}

	/**
	 * 
	 * @param	object
	 */
	public function setRedOnAlarmOnly(set:Bool) 
	{
		_redOnAlarm = set;
	}
}
