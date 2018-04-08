package widgets;

import data.DataObject;

/**
 * ...
 * @author GM
 */


/**
 * 
 */
class WCounterMeasure extends WDataValues
{
	var counterWidget	:WCounter;

	/**
	 * CounterWidget Constructor
	 */
	public function new(name:String,  dataObjectIn:DataObject)
	{
		super(name, dataObjectIn);

		counterWidget 			= new WCounter("ID_COUNTER_MEASURE_" + dataObjectIn.channelIndex, dataObjectIn);
		counterWidget.setRedOnAlarmOnly(true);

		addChild(counterWidget);
	}

}
