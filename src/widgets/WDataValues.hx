package widgets;

/**
 * ...
 * @author GM
 */

//importing used component classes
import data.DataObject;
import data.ThresholdObject;
import events.PanelEvents.ParameterEvent;
import org.aswing.ASColor;
import org.aswing.JLabel;
import text.LabelValues;

/**
 * 
 */
class WDataValuesWithTitle extends WDataValues
{
	public var txtTitle:	JLabel;

	/**
	 * 
	 * @param	name
	 * @param	dataObjectIn
	 * @param	autoRefreshIn
	 */
	public function new(name:String, dataObjectIn:DataObject, autoRefreshIn:Bool = true)
	{
		super(name, dataObjectIn, autoRefreshIn);

		txtTitle	= new JLabel(dataObjectIn.label);
		txtTitle.setComBoundsXYWH(62, -38, 80, 18);
		txtTitle.setFont(txtTitle.getFont().changeSize(18));
		txtTitle.setFont(txtTitle.getFont().changeBold(true));

		addChild(txtTitle);
		init();
	}
}

class WDataValues extends WBase
{
	var dataObject:			DataObject;

	public var txtMin:		LabelValues;
	public var txtMax:		LabelValues;
	public var txtDev:		LabelValues;
	public var txtBDF:		LabelValues;
	public var txtTrigger:	LabelValues;

	var autoRefresh:		Bool;


	public function new(name:String, dataObjectIn:DataObject, autoRefreshIn:Bool = true)
	{
		super(name);

		autoRefresh = autoRefreshIn;
		//component creation
		dataObject = dataObjectIn;

		txtMin 		= new LabelValues("IDS_MIN", "IDS_CPS");
		txtMax		= new LabelValues("IDS_MAX", "IDS_CPS");
		txtDev 		= new LabelValues("IDS_DEVIATION", "IDS_CPS");
		txtBDF 		= new LabelValues("IDS_BKG", "IDS_CPS");
		txtTrigger	= new LabelValues("IDS_TRIGGER", "IDS_CPS");
	}

	/**
	 * 
	 * @param	e
	 */
	override public function onDataRefresh(e:ParameterEvent):Void
	{
		if (parent.parent.visible && autoRefresh &&( e.parameter =="DATA"))
		{
			//trace("onDataRefresh");
			setValues(dataObject);
		}
	}

	/**
	 * 
	 * @param	bdf
	 * @param	trigger
	 */
	public function setValues(dataObject:DataObject)
	{
		//trace("refresh Min; and max; values");

		var bInitializationState:Bool =  autoRefresh ? Main.model.portalBKGMeasurement : false;
		if (dataObject.minimum == ThresholdObject.MAXINT) bInitializationState = true;
		var strNone:String = "- - - ";
		//var undefined:Bool = dataObject.isValueInvalid();

		var bNone:Bool = bInitializationState; //|| undefined;

		txtMin.setValue(bNone? strNone : Std.string(dataObject.minimum));
		txtMax.setValue(bNone ? strNone : Std.string(dataObject.maximum), dataObject.inRAAlarm ? ASColor.ALIZARIN.getRGB() : null);
		txtDev.setValue(bNone ? strNone : Std.string(Std.int(dataObject.deviation)));
		txtBDF.setValue(bNone ? strNone : Std.string(dataObject.noise));
		txtTrigger.setValue(bNone ? strNone :Std.string(dataObject.thresholdCalculated));
	}

	/**
	 * 
	 * @param	newPos
	 */
	public function init():Void
	{
		var X 	= 0;
		var W 	= 220;
		var tY 	= 0;

		txtMin.setComBoundsXYWH(X, tY, W, 16);
		addChild(txtMin);
		tY += 30;

		txtMax.setComBoundsXYWH(X, tY, W, 16);
		addChild(txtMax);
		tY += 30;

		txtDev.setComBoundsXYWH(X, tY, W, 16);
		addChild(txtDev);
		tY += 30;

		txtBDF.setComBoundsXYWH(X, tY, W, 16);
		addChild(txtBDF);
		tY += 30;

		txtTrigger.setComBoundsXYWH(X, tY, W, 16);
		addChild(txtTrigger);
	}	
}
