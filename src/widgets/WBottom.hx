package widgets;
import tools.ToolReport;
import db.DBTranslations.Tr;
/**
 * ...
 * @author GM
 */
class WBottom extends WBase
{
	var timeWidget			:WTime;
	var	alalogClock			:WAnalogClock;
	var reportNumberWidget	:WReportNumber;
	var heartWidget			:WLed;
	var messagesWidget		:WMessages;
	var toolReport			:ToolReport;

	public function new(name:String) 
	{
		var dY:Float = 44;

		super(name);

		messagesWidget = new WMessages("ID_MESSAGES", 320, dY);
		addChild(messagesWidget);
		messagesWidget.setToolTipText(Tr.txt("IDS_TT_TABLE_MESSAGES"));

		timeWidget = new WTime("ID_TIME_PANE", 160, dY);
		addChild(timeWidget);

		alalogClock = new WAnalogClock("ID_ANALOG_CLOCK");
		addChild(alalogClock);

		heartWidget = new WLed("ID_HEART");
		addChild(heartWidget);

		reportNumberWidget = new WReportNumber("ID_REPORT_NUMBER_PANE", 168, dY);
		
		toolReport 		= new ToolReport		("ID_TOOLW_REPORT", W, H);
		toolReport.addChild(reportNumberWidget);
		addChild(toolReport);
	}
}