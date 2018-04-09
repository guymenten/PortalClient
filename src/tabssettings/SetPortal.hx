package tabssettings ;

import com.ComBase.DataGram;
import comp.JTextTitleArea;
import data.DataObject;
import db.DBTranslations;
import events.PanelEvents;
import flash.events.Event;
import flash.events.MouseEvent;
import org.aswing.BorderLayout;

/**
 * ...
 * @author GM
 */
class SetPortal extends SetBase
{
	var counterTextArray:Map<String, JTextTitleArea>;
	var addressArray:Map<String, JTextTitleArea>;
	var IOArray:Map<String, JTextTitleArea>;
	var counterCRCErrorsArray:Map<String, JTextTitleArea>;
	var counterTimeoutErrorsArray:Map<String, JTextTitleArea>;
	var dataNumberArray:Map<String, JTextTitleArea>;
	//var butDebug:JButton2;
	var xPos:Int;
	var yPos:Int;

	/**
	 * 
	 * @param	name
	 */
	public function new() 
	{
		super(new BorderLayout(0, 0));
		//scaleX = scaleY = 0.8;
	}

	private override function init():Void
	{
		super.init();

		counterTextArray			= new Map<String, JTextTitleArea>();
		counterCRCErrorsArray		= new Map<String, JTextTitleArea>();
		counterTimeoutErrorsArray	= new Map<String, JTextTitleArea>();
		dataNumberArray				= new Map<String, JTextTitleArea>();
		addressArray				= new Map<String, JTextTitleArea>();
		IOArray						= new Map<String, JTextTitleArea>();
		xPos						= SetBase.x2;

		for (channel in Model.channelsArray)
		{
			appendChannel(channel);
			xPos += 2 * SetBase.dX;
		}

		//butDebug = new JButton2(280, 212, 100, 32, "IDS_DEBUG", onButGrid);
		//addChild(butDebug);	
	}

	private function onButGrid(e:MouseEvent):Void 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PANE_HELP));
		//Main.root1.dispatchEvent(new Event(PanelEvents.EVT_WIN_REFRESH));
	}

	/**
	 * 
	 */
	function onDataRefresh(e:ParameterEvent):Void
	{
		if (isVisible())
		{		
			if (e.parameter == "DATA")
			{
				for(dao in Model.channelsArray)
				{
					var dt:DataGram = Model.comThread.getLastDatagram(dao.address);

					if (dt == null)
						return;

					var address:String 			= Std.string(dao.address);
					counterTextArray.get(address).textArea.setText(Std.string(dt.counter));
					dataNumberArray.get(address).textArea.setText(Std.string(dt.datagramNumber));
					counterCRCErrorsArray.get(address).textArea.setText(Std.string(dao.checkSumErrors));
					counterTimeoutErrorsArray.get(address).textArea.setText(Std.string(dao.timeoutErrors));
					addressArray.get(address).textArea.setText(Std.string(dt.address));
					IOArray.get(address).textArea.setText(Std.string(dt.IOStatus));
				}
			}
		}
	}

	/**
	 * 
	 * @param	v
	 */
	override public function setVisible(v:Bool):Void 
	{
		super.setVisible(v);

		if (v)
		{
			for(dao in Model.channelsArray)
			{
				counterTextArray.get(cast dao.address).setTitle(Std.string(dao.label));
			}
		}
	}

	/**
	 * 
	 * @param	data
	 */
	function appendChannel(dao:DataObject)
	{
		var address:String = dao.getAddress();

		yPos = SetBase.y1 - 14;

		// Label
		appendMonitoredValue(dao.label, address, counterTextArray);
		// Data Number
		appendMonitoredValue(DBTranslations.getText("IDS_COUNTER"), address, dataNumberArray);
		 // Address
		appendMonitoredValue(DBTranslations.getText("IDS_ADDRESS"), address, addressArray);
		 // IO
		appendMonitoredValue(DBTranslations.getText("IDS_ERROR_SUCCESS"), address, IOArray);
		// CRC Counter
		appendMonitoredValue(DBTranslations.getText("IDS_CRC_ERRORS"), address, counterCRCErrorsArray);
		// Timeout Counter
		appendMonitoredValue(DBTranslations.getText("IDS_TIMEOUT_ERRORS"), address, counterTimeoutErrorsArray);
	}

	/**
	 * 
	 * @param	label
	 * @param	address
	 * @param	mapArray
	 * @param	JTextTitleArea>
	 */
	function appendMonitoredValue(label:String, address:String, mapArray:Map<String, JTextTitleArea>):Void
	{
		var txtArea:JTextTitleArea = new JTextTitleArea(label);
		txtArea.setComBoundsXYWHTopAlign(xPos, yPos, 100);
		yPos += 56;
		addChild(txtArea);
		mapArray.set(address, txtArea);
	}
}