package widgets;

import error.Errors.Error;
import events.PanelEvents;
import org.aswing.geom.IntRectangle;
import tables.TableMessages;
import util.DateUtil;

/**
 * ...
 * @author GM
 */
class WMessages extends WBase
{
	var messagesTable: TableMessages;

	public function new(name:String, wIn:Float, hIn:Float) 
	{
		super(name);

		var rect:IntRectangle = new IntRectangle(0, 0, cast wIn, cast hIn);

		messagesTable = new TableMessages(rect.x, rect.y, cast (wIn * 1.42), cast( hIn * 1.42));
		addChild(messagesTable);

		//addEventListener(MouseEvent.CLICK, onDoubleClick);
		Main.root1.addEventListener(PanelEvents.EVT_MESSAGE_SET, onMessage);
	}

	///**
	 //* 
	 //* @param	e
	 //*/
	//private function onDoubleClick(e:MouseEvent):Void 
	//{
		//Main.root.dispatchEvent(new Event(PanelEvents.EVT_VIEW_LOG));
	//}

	/**
	 * 
	 * @param	e
	 */
	private function onMessage(logMsg:ParameterEvent):Void 
	{
		var er:Error = logMsg.parameter;
		messagesTable.listData.append(DateUtil.getStringTime(er.time.toString()) + "  " + er.getLabelText());
		messagesTable.listMessages.setSelectedIndex(0);
		messagesTable.listMessages.ensureIndexIsVisible(messagesTable.listData.size() - 1);
	}
}