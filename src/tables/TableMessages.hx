package tables;

import flash.display.Sprite;
import org.aswing.JList;
import org.aswing.JScrollPane;
import org.aswing.VectorListModel;

/**
 * ...
 * @author GM
 */
class TableMessages extends Sprite
{
	public var listData:VectorListModel;
	public var listMessages:JList;

	public function new(xIn:Int, yIn:Int, wIn:Int, hIn:Int)
	{
		super();
		scaleX = scaleY = 0.7;

		listData = new VectorListModel();

		listMessages = new JList(listData);

		listMessages.setEnabled(false);
		listMessages.setBorder(null);

		var scrollPane:JScrollPane = new JScrollPane(listMessages);
		addChild(scrollPane);
		scrollPane.x = xIn;
		scrollPane.y = yIn;
		scrollPane.setWidth(wIn);
		scrollPane.setHeight(hIn);
		scrollPane.setBorder(null);
		scrollPane.invalidate();
		listMessages.invalidate();

		listMessages.setSelectionBackground(listMessages.getBackground());
		listMessages.setSelectionMode(0); // One line selected
		//scrollPane.addEventListener(MouseEvent.CLICK, selectionListener);
	}

	///**
	 //* 
	 //* @param	e
	 //*/
	//public  function selectionListener(e:MouseEvent):Void
	//{
		////trace("addSelectionListener " + e.getFirstIndex());
		////var data:MessageData = listData.get(e.getFirstIndex());
		////trace("addSelectionListener " + data.reportNumber);
	//}
}
