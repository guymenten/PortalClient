package widgets;

import data.DataObject;

/**
 * ...
 * @author GM
 */
class WCountersMeasure extends WBase
{
	var counterMeasureWidget:WCounterMeasure;

	public function new(name:String) 
	{
		super(name);

		init();
	}

	/**
	 * 
	 */
	public function onResetMinMax() 
	{
		for (dao in Model.channelsArray)
		{
			dao.resetMaximumAndMinimum();
		}
	}

	/**
	 * 
	 */
	function init()
	{
		var dataObject:DataObject;

		for (channel in Model.channelsArray)
		{
			dataObject =  Model.channelsArray.get(channel.getAddress());

			counterMeasureWidget = new WCounterMeasure("ID_MEASURE_COUNTER" + dataObject.channelIndex, dataObject);
			counterMeasureWidget.init();
			addChild(counterMeasureWidget);
		}
	}
}