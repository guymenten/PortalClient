package tables;

import db.DBTranslations;
import error.Errors.Error;
import events.PanelEvents;
import org.aswing.table.GeneralTableCellFactory;
import org.aswing.table.PropertyTableModel;
import tables.renderer.DateCell;
import tables.Table.MessagesTableData;

/**
 * ...
 * @author GM
 */
class TableLogBook extends Table
{
	public function new(name:String, wIn:Int, hIn:Int)
	{
		super(name, wIn, hIn);
	
		setDBTable(Model.dbLog);
		dbTable.setIntervalFromCount(0, tableRows);

		model = new PropertyTableModel(
			listData,
			["V", DBTranslations.getText("IDS_DATE"), DBTranslations.getText("IDS_HOUR"), DBTranslations.getText("IDS_MESSAGE")],
			["select","date", "time", "label",],
			[null, null, null, null] // no translators
		);

		init();

		setColWidth(0, 20);	// Report
		setColWidth(1, 80);	// Date
		setColWidth(2, 80);	// Hour
		setColWidth(3, 400);// Text

		table.setSelectionMode(0); // One line selected
		setCellRenderer();

		Main.root1.addEventListener(PanelEvents.EVT_LOG, onMessage);
	}

	/**
	 * 
	 */
	public override function setCellRenderer():Void
	{
		return; //GM
		super.setCellRenderer();

		setCellFactory("IDS_DATE", 			new GeneralTableCellFactory(DateCell));
		setCellFactory("IDS_HOUR", 			new GeneralTableCellFactory(TimeCell));
	}

	/**
	 * 
	 * @param	e
	 */
	private function onMessage(logMsg:ParameterEvent):Void 
	{	
		var logData:Error = logMsg.parameter;

		if (logData.time == null)
			logData.time = Date.now();

		var logListObject:MessagesTableData = new MessagesTableData(logData.time, logData.getLabelText());

		listData.insertElementAt(logListObject, 0);
	}
}
