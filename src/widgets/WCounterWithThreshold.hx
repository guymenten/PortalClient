package widgets;

import data.DataObject;
import events.PanelEvents.ParameterEvent;
import org.aswing.ASColor;
import org.aswing.geom.IntRectangle;
import text.LabelValues;

/**
 * ...
 * @author GM
 */
class WCounterWithThreshold extends WCounter
{
	public var txtTrigger:LabelValues;

	public function new(name:String, strIndex:String, dataObjectIn:DataObject) 
	{
		super(name, dataObjectIn);

		var col:Int 		= ASColor.ALIZARIN.getRGB();
		txtTrigger 			= new LabelValues("IDS_TRIGGER", "IDS_CPS", 16, 50, col, ASColor.ALIZARIN.getAlpha());
		txtTrigger.setComBounds(new IntRectangle(-12, cast txtTrigger.y + 80, 134, 18));
		addChild(txtTrigger);
	}

	/**
	 * 
	 * @param	e
	 */
	override public function onDataRefresh(e:ParameterEvent):Void
	{
		//trace("CounterWithThresholdWidget onDataRefresh");
		if (e.parameter == dataObject.address || e.parameter == "DATA")  // 0 for all channels
		{
			setValues(dataObject);
			txtTrigger.setValue(cast dataObject.thresholdCalculated, ASColor.ALIZARIN.getRGB());
		}
	}
}