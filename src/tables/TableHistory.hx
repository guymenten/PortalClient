package tables;

import db.DBTranslations;
import flash.display.Sprite;
import org.aswing.ASColor;
import org.aswing.JScrollPane;
import org.aswing.JTable;
import org.aswing.table.PropertyTableModel;
import org.aswing.table.PropertyTranslator;
import org.aswing.VectorListModel;


/**
 * Table displaying the Reports
 */

/**
 * ...
 * @author GM
 */
class TableHistory extends Sprite
{
	public var reportSelected:Int;
	private var listData:VectorListModel;
	private var table:JTable;

	public function new(xIn:Int, yIn:Int, wIn:Int, hIn:Int)
	{
		super();

		listData = new VectorListModel();

		var tableModel:PropertyTableModel = new PropertyTableModel(
			listData,
			[DBTranslations.getText("IDS_DATE"), DBTranslations.getText("IDS_TIME"), DBTranslations.getText("IDS_CHANNEL"), DBTranslations.getText("IDS_BKG"), DBTranslations.getText("IDS_TRIGGER"), DBTranslations.getText("IDS_MIN"), DBTranslations.getText("IDS_MAX")],
			["date", "time", "channel", "noise", "thr", "min", "max"],
			[null, null, null, null, null, null, null]
		);

		table = new JTable(tableModel);

		var scrollPane:JScrollPane = new JScrollPane(table);

		addChild(scrollPane);
		scrollPane.x = xIn;
		scrollPane.y = yIn;
		scrollPane.setWidth(wIn);
		scrollPane.setHeight(hIn);

		table.setSelectionBackground(new ASColor(0x82ccff, 1));
		table.setSelectionMode(0); // One line selected

		init();
	}

	/**
	 * 
	 */
	public function init()
	{
		for (data in LogHistory.historyArray)
			listData.append(data);
	}

	/**
	 * 
	 */
	public function refresh()
	{
		//var data:ReportData = LogHistory.reportsArray[Model.lastReport.reportNumber - 1];

		//listData.append(data);
	}
}

/**
 * 
 */
class DateTranslator implements PropertyTranslator
{
	public function new()
	{
	}
	
	public function translate(info:Dynamic, key:String):Dynamic
	{
		//trace("Info : " + info + " ,Key : " + key);
		var sex:Int = info[Std.parseInt(key)];

			if(sex == 0){
				return "female";
			}else{
			return "male";
			}
		}
}
