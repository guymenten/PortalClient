package widgets;
import db.DBReports.ReportData;
import db.DBTranslations;
import events.PanelEvents;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import org.aswing.ASColor;
import org.aswing.JToolBar;
import org.aswing.geom.IntRectangle;
import org.aswing.JLabel;
import util.DateFormat;
import util.Filters;
import util.Images;

/**
 * ...
 * @author GM
 */
class WReportNumber extends WBase
{
	var txtReport		:JLabel;
	var txtReportNr		:JLabel;
	var txtDate			:JLabel;
	
	var bmApply			:Bitmap;
	var bmRA			:Bitmap;

	var spApply			:Bitmap;
	var butLastReport	:JToolBar;

	public function new(name:String, wIn:Float, hin:Float) 
	{
		super(name);

		var width 		= 140;

		bmApply 		= Images.loadLEDRAOff();
		Images.resize(bmApply, 24);
		bmApply.x 		+= 6;
		bmApply.y 		+= 20;
		addChild(bmApply);

		bmRA 			= Images.loadLEDRAOn();
		Images.resize(bmRA, 28);
		bmRA.x 			+= 2;
		bmRA.y 			+= 18;
		bmRA.alpha 		= 0.8;
		bmRA.filters	= Filters.glowFilters;
		addChild(bmRA);

		setReportRA(false);

		txtReport 		= new JLabel();
		txtReportNr 	= new JLabel();
		txtDate 		= new JLabel();

		txtReport.setComBounds(new IntRectangle(20, 4, width, 16));
		txtReport.setForeground(ASColor.CLOUDS);
		
		txtReportNr.setComBounds(new IntRectangle(20, 18, width, 28));
		txtReportNr.setFont(getFont().changeSize(20));
		txtReportNr.setForeground(ASColor.CLOUDS);
		
		txtDate.setFont(getFont().changeSize(12));
		txtDate.setComBounds(new IntRectangle(20, 44, width, 16));
		txtDate.setForeground(ASColor.CLOUDS);

		butLastReport 			= new JToolBar(JToolBar.VERTICAL, 60);
		//butLastReport.push("", null, null, " ",  "IDS_TT",	onOpenLastReport, false);

		addChild(txtReportNr);
		addChild(txtReport);
		addChild(txtDate);

		Main.root1.addEventListener(PanelEvents.EVT_REPORT_CREATED, onreportCreated);
		addEventListener(MouseEvent.CLICK, onOpenLastReport);
		onreportCreated(null);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onOpenLastReport(e:MouseEvent):Void 
	{
		Main.root1.dispatchEvent(new ParameterEvent("SelectReportNumber", 0));
	}

	/**
	 * 
	 */
	function setReportRA(ra:Bool = true)
	{
		bmApply.visible = !ra;
		bmRA.visible 	= ra;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onreportCreated(e:Event):Void 
	{
		trace("onreportCreated");
		var reportData:ReportData = Model.lastReport.lastReportData;

		txtReport.setText(DBTranslations.getText("IDS_LAST_REPORT"));		
		txtReportNr.setText(Std.string(reportData.ReportNumber));
		trace("Time : ");

		if (reportData.TimeIn != null)
		{
			txtDate.setText(DateFormat.getDateString(reportData.TimeOut) + "  " + DateTools.format(reportData.TimeOut, "%H:%M:%S"));
			setReportRA(reportData.ReportResult == 1);
		}
	}
}