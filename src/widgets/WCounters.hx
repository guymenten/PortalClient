package widgets;
import widgets.WBase;
//import hsl.haxe.Signaler;
//import flash.Assets;

/**
 * ...
 * @author GM
 */

class WCounters extends WBase
{
	var cntWidgets: Map<String, WCounterWithThreshold>;

	public function new(name:String) 
	{
		super(name);

		cntWidgets 		= new Map<String, WCounterWithThreshold>();

		var index:Int 	= 1;
		var cntWidget:WCounterWithThreshold;

		for (dao in Model.channelsArray) // Create a widget for each Channel
		{	
			cntWidget = new WCounterWithThreshold("ID_COUNTER_MONITOR" + dao.channelIndex, Std.string(index), Model.channelsArray.get(dao.getAddress()));
			cntWidgets.set(dao.getAddress(), cntWidget); // Push in the address indexed array
			addChild(cntWidget);

			index ++;
		}
	}
}