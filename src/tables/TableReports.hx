package tables;

import db.DBReports.ReportData;
import db.DBTranslations;
import events.PanelEvents;
import flash.events.Event;
import flash.events.MouseEvent;
import org.aswing.ASColor;
import org.aswing.JScrollPane;
import org.aswing.JTable;
import org.aswing.VectorListModel;
import org.aswing.geom.IntRectangle;
import org.aswing.table.DefaultTableModel;
import org.aswing.table.GeneralTableCellFactory;
import org.aswing.table.PropertyTableModel;
import org.aswing.table.PropertyTranslator;
import org.aswing.table.TableColumnModel;
import org.aswing.table.sorter.TableSorter;
import panescenter.WReport;
import tables.renderer.DateCell;
import tables.renderer.RAIconCell;
import tables.Table.MessagesTableData;
import util.Printf;

/**
 * Table displaying the Reports
 */
/**
 * ...
 * @author GM
 */
class TranslatorToReportNumber implements PropertyTranslator
{
	public function new() { }

	public function translate(info:Dynamic, key:String):String{

		var str:String = Printf.format("%05d", [cast info.reportNumber]);

		return str;
	}
}

/**
 * 
 */
class TranslatorToDuty implements PropertyTranslator
{
	public function new() { }

	public function translate(info:Dynamic, key:String):String{

		var str:String = Printf.format("%05d", [cast info.duty]);

		return str;
	}
}

/**
 * 
 */
class TableReports extends Table
{
	public var TABLE_LINES:Int 	= 16;
	var reportWidget				:WReport;

	public function new(wIn:Int, hIn:Int, comp:WReport)
	{
		super("ID_REPORT_TABLE", wIn, hIn);
		setDBTable(Model.dbReports);
		dbTable.setIntervalFromCount(0, tableRows);

		reportWidget = comp;
		listData.append(new MessagesTableData(1, 3, Date.now(), 1200));

		 model = new PropertyTableModel(
			listData,
			["V", DBTranslations.getText("IDS_REPORT"), DBTranslations.getText("IDS_DATE"), DBTranslations.getText("IDS_HOUR"), DBTranslations.getText("IDS_UNIT_SECOND"), "RA"],
			["select", "reportNumber", "date", "time", "duty", "result"],
			[ null, new TranslatorToReportNumber(), null, null, new TranslatorToDuty(), null]);

		table.setFont(table.getFont().changeSize(10));
		init();

		setColWidth(0, 20);	// Report
		setColWidth(1, 50);	// Report
		setColWidth(2, 64);	// Date
		setColWidth(3, 64);	// Hour
		setColWidth(4, 40);	// Duty
		setColWidth(5, 40);	// RA

		table.setSelectionMode(0); // One line selected

		setCellRenderer();

	//	table.getTableHeader().setToolTipText(DBTranslations.getText("IDS_MSG_SORT_TABLE"));

		Main.root1.addEventListener(PanelEvents.EVT_REPORT_CREATED, onReportCreated);
		Main.root1.addEventListener(PanelEvents.EVT_VIEW_REPORT , onViewReport);
		Main.root1.addEventListener(PanelEvents.PRINT_REPORT , onPrintReport);
	}

	private override function onHeaderClick(e:MouseEvent = null):Void 
	{
		super.onHeaderClick(e);

		if (cast e)
		{
			var col:Dynamic = tableSorter.getSortingColumns()[0];
			if (cast col)
			{
				switch col.column
				{
					case 1: Model.dbReports.sortBy("ReportNumber", col.direction);
					case 2:
					case 3: Model.dbReports.sortBy("TimeIn", col.direction);
					case 4: Model.dbReports.sortBy("Duty", col.direction);
					case 5: Model.dbReports.sortBy("ReportResult", col.direction);
				}
			}
			else Model.dbReports.sortBy();

		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function onViewReport(e:Event = null):Void // When Button Pressed
	{
		if((cast Model.buildPrintableReport) && cast reportSelected)
			Model.buildPrintableReport.viewReport(reportSelected, reportWidget.plotsWidgets, true);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPrintReport(e:Event = null):Void 
	{
		Model.buildPrintableReport.printReport(reportSelected, reportWidget.plotsWidgets, true);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onReportCreated(e:ParameterEvent):Void 
	{
		var data:ReportData = Model.lastReport.lastReportData;
		listData.append(new MessagesTableData(data.ReportNumber, data.ReportResult, data.TimeOut, data.Duty));
		selectItem(previousIndexSelected);
		Model.buildPrintableReport.printReport(reportSelected, reportWidget.plotsWidgets, false);
	}

	/**
	 * 
	 */
	override function getDefaultData() : Dynamic
	{
		return new MessagesTableData();
	}

	/**
	 * 
	 * @param	sel
	 */
	override function onSelectionListener(sel:Int)
	{
		var index = sel;
		var data:MessagesTableData = cast listData.get(index);

		if ((cast data) && data.reportNumber != 0)
		{
			reportSelected = data.reportNumber;
			reportWidget.onReportSelected(reportSelected);
		}
	}

	/**
	 * 
	 */
	override function doubleClickAction() {
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_VIEW_REPORT));				
	}

	/**
	 * 
	 */
	public override function setCellRenderer():Void
	{
		//return;//GM
		super.setCellRenderer();

		setCellFactory("RA", 										new GeneralTableCellFactory(RAIconCell));
		setCellFactory(DBTranslations.getText("IDS_DATE"), 			new GeneralTableCellFactory(DateCell));
		setCellFactory(DBTranslations.getText("IDS_HOUR"), 			new GeneralTableCellFactory(TimeCell));
		setCellFactory(DBTranslations.getText("IDS_UNIT_SECOND"), 	new GeneralTableCellFactory(DutyCell));
		setCellFactory(DBTranslations.getText("IDS_REPORT"), 		new GeneralTableCellFactory(ReportCell));
	}
}
