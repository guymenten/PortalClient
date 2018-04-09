package data;
import db.DBReports;
import db.DBTranslations;
import events.PanelEvents;
import flash.events.Event;
import flash.events.EventDispatcher;
import Session;

/**
 * ...
 * @author GM
 */
class Report extends EventDispatcher
{
	public static var reportsNotAck	:Int;
	public var lastReportData		:ReportData;
	var reportsTable				:DBReports;

	/**
	 * 
	 */
	public function new() 
	{
		super();

		lastReportData = Model.dbReports.getLastReportData();

		Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_ON, OnRAAlarm);
		//Main.model.
		Main.root1.addEventListener(PanelEvents.EVT_CREATE_REPORT, onCreateReport);
	}

	/**
	 * Create a report on portal free
	 * @param	e
	 */
	private function onCreateReport(e:Event):Void 
	{
		lastReportData.TimeIn	=  Main.model.timeBusy;
		lastReportData.TimeOut	=  Main.model.timeFree;

		addReport();
	}

	/**
	 * 
	 */
	function addReport() 
	{
		var reportResult:Int = 0;

		for (channel in Model.channelsArray)
		{
			//
			// Database Writing Here
			//
			reportResult += cast channel.saveReportData(); // Save all Data Values in Channels tables
			Model.lastReport.lastReportData.ReportResult = reportResult;
		}

		lastReportData = new ReportData(lastReportData.ReportNumber + 1, reportResult, lastReportData.TimeIn, lastReportData.TimeOut, Model.dbChannelsDefaults.channelsPattern, Model.captureBiteArray);
		Model.dbReports.createReport(lastReportData);
		
		if(cast lastReportData.ReportResult) reportsNotAck ++;

		for (channel in Model.channelsArray) {
			channel.resetMaximumAndMinimum();
		}

		Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_REPORT_CREATED, getReportInfoText()));
	}

	/**
	 * 
	 * @return
	 */
	function getReportInfoText():String
	{
		var result:Bool = cast Model.lastReport.lastReportData.ReportResult;
		var strStatus:String = DBTranslations.getText(result ? "IDS_MSG_REPORT_POSITIVE" : "IDS_MSG_REPORT_NEGATIVE");
		return DBTranslations.getText("IDS_NR") + cast lastReportData.ReportNumber + ", " + strStatus;
	}

	/**
	 * 
	 * @param	e
	 */
	function OnRAAlarm(e:Event):Void 
	{
		if(!Main.model.portalBusy)
			addReport();
	}
}