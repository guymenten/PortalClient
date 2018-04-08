package widgets;

import events.PanelEvents.ParameterEvent;
import widgets.WBase;


/**
 * ...
 * @author GM
 */

class WBarGraphs extends WBase
{
	var barGraphsWidgets: Map<String, WBarGraph>;
	var barGraphWidget:WBarGraph;

	public function new(name:String) 
	{
		super(name);

		barGraphsWidgets = new Map<String, WBarGraph>();

		for (dao in Model.channelsArray) // Create a widget for each Channel
		{	
			barGraphWidget = new WBarGraph("ID_BARGRAPH" + dao.channelIndex);
			barGraphWidget.setMinMax(0, 3000, 1500);
			barGraphsWidgets.set(dao.getAddress(), barGraphWidget); // Push in the address indexed array
			addChild(barGraphWidget);
		}

		leftSide = false;
		Main.model.refreshCnt !.add(refreshData);
	}

	/**
	 * 
	 * @param	e
	 */
	public function refreshData(cnt:Int):Void
	{
		if (visible) {

			for (dao in Model.channelsArray) // Create a widget for each Channel
			{
				barGraphsWidgets.get(dao.getAddress()).setValue(dao.getBarGraphValue());
			}
		}
	}
}