package tools ;
import data.Report;
import events.PanelEvents;
import flash.events.DataEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import org.aswing.JToolBar;
import tools.ToolsHorizWidget;
import tools.WTools.ToolButton;
import util.Images;
import widgets.WNotification;

/**
 * ...
 * @author GM
 */
class ToolReport extends ToolsHorizWidget
{
	var notification	:WNotification;
	
	var butView			:ToolButton;
	var butPrinter		:ToolButton;
	var butKeyboard		:ToolButton;
	var butMicro		:ToolButton;
	var butSoundAck 	:ToolButton;
	var butAlarmAck		:ToolButton;

	/**
	 * 
	 * @param	name
	 */
	public function new(name:String,wIn:Int, hIn:Int) 
	{
		super(name, wIn, hIn);

		toolBar = new JToolBar(JToolBar.HORIZONTAL, gap);
		toolBar.x -= 18;
		addChild(toolBar);
	
		butView = new ToolButton("", "", "IDS_TT_REPORT_VIEW", Images.loadView(false), onButView);
		butView.x = gapIndex; gapIndex += gap;
		toolBar.append(butView);
		
		butPrinter = new ToolButton("", "", "IDS_TT_REPORT_PRINT", Images.loadPrinter(false), onButPrint);
		butPrinter.x = gapIndex; gapIndex += gap;
		toolBar.append(butPrinter);
		
		butKeyboard = new ToolButton("", "", "IDS_TT_REPORT_KEYBOARD", Images.loadKeyboard(), onButKeyboard);
		butKeyboard.x = gapIndex; gapIndex += gap;
		toolBar.append(butKeyboard);
		
		butMicro = new ToolButton("", "", "IDS_TT_REPORTMICRO", Images.loadMicrophone(), onButMicrophone);
		butMicro.x = gapIndex; gapIndex += gap;
		toolBar.append(butMicro);
		
		butSoundAck = new ToolButton("", "", "IDS_TT_REPORT_MUTE", Images.loadMute(), onButSoundAck);
		butSoundAck.x = gapIndex; gapIndex += gap;
		toolBar.append(butSoundAck);
		
		butAlarmAck = new ToolButton("", "", "IDS_TT_REPORT_ACK", Images.loadAckDis(), onButAlarmAck);
		butAlarmAck.x = gapIndex; gapIndex += gap;
		toolBar.append(butAlarmAck);

		Main.root1.addEventListener(PanelEvents.EVT_REPORT_CREATED, onreportCreated);
		Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_ON, onRAAlarm);

		oninitButtons();
		notification	= new WNotification("ID_NOTIFICATION_REPORT");
		addChild(notification);
		//butAlarmAck.setEnabled(false);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onRAAlarm(e:Event):Void 
	{
		//butAlarmAck.button.setEnabled(true);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onreportCreated(e:ParameterEvent):Void 
	{
		notification.setValue(Report.reportsNotAck);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButView(e:MouseEvent):Void 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_VIEW_REPORT));				
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButPrint(e:MouseEvent):Void 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.PRINT_REPORT));				
	}

	/**
	 * 
	 * @param	e
	 */
	function onButMicrophone(e:MouseEvent) 
	{
		
	}

	/**
	 * 
	 * @param	e
	 */
	function onButKeyboard(e:MouseEvent) 
	{
		
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButSoundAck(e:Event):Void 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_RA_ALARM_SOUND_ACK));
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButAlarmAck(e:Event):Void 
	{
		Main.root1.dispatchEvent(new DataEvent(PanelEvents.EVT_RA_ALARM_ACK));
		Main.root1.dispatchEvent(new DataEvent(PanelEvents.EVT_RA_ALARM_SOUND_ACK));
		Report.reportsNotAck = 0;
		notification.setValue(0);
		
		if (!Main.model.isBusy()) {
			
			Main.root1.dispatchEvent(new DataEvent(PanelEvents.EVT_RESET_FIRST_INIT)); // Restart the BKG measurement
		}
	}
}