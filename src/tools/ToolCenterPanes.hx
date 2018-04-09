package tools;

import events.PanelEvents;
import flash.events.Event;
import org.aswing.JToolBar;
import tools.WTools.ToolButton;
import util.Images;
import widgets.WBase;

/**
 * ...
 * @author GM
 */
class ToolCenterPanes extends WBase
{
	var butReports:ToolButton;
	var butPortal:ToolButton;
	var butHistory:ToolButton;
	var but:ToolButton;
	var butCamera:ToolButton;
	var butSettings:ToolButton;
	var butLog:ToolButton;
	var butMeasures:ToolButton;
	var toolBar:JToolBar;

	public function new(name:String) 
	{
		super(name);
	
		toolBar = new JToolBar(JToolBar.VERTICAL, gap);
		addChild(toolBar);

		butPortal = new ToolButton("ID_PORTAL", "", "IDS_TT_MENU_PORTAL", Images.loadButPortal(), onButPortal);
		toolBar.append(butPortal);
	
		butMeasures = new ToolButton("ID_MEASURES", "", "IDS_TT_MENU_MEASURES", Images.loadMeasures(), onButMeasures);
		butMeasures.y = gapIndex; gapIndex += gap;
		toolBar.append(butMeasures);

		butReports = new ToolButton("ID_REPORT", "", "IDS_TT_MENU_REPORT", Images.loadReport(), onButReport);
		butReports.y = gapIndex; gapIndex += gap;
		toolBar.append(butReports);

		butHistory = new ToolButton("ID_HISTORY", "", "IDS_TT_MENU_HISTORY", Images.loadHistory(), onButHistory);
		butHistory.y = gapIndex; gapIndex += gap;
		toolBar.append(butHistory);

		butLog = new ToolButton("ID_LOG", "", "IDS_TT_MENU_LOG", Images.loadDataBase(), onButDataBase);
		butLog.y = gapIndex; gapIndex += gap;
		toolBar.append(butLog);
	
		if (DefaultParameters.cameraEnabled)
		{
			butCamera = new ToolButton("ID_CAMERA", "", "IDS_TT_MENU_CAMERA", Images.loadCamera(), onButCameraView);
			butCamera.y = gapIndex; gapIndex += gap;
			toolBar.append(butCamera);
		}

		butSettings = new ToolButton("ID_SETTINGS", "", "IDS_TT_MENU_SETTINGS", Images.loadSettings(), onButSettings);
		butSettings.y = gapIndex; gapIndex += gap;
		toolBar.append(butSettings);

		Main.root1.addEventListener("SelectReportNumber", OnReportsWidget);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnReportsWidget(e:Event):Void 
	{
		//setSelected(butReports);

		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PANE_REPORT));		
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PANE_CHANGE));		
	}

	/**
	 * 
	 * @param	e
	 * @param	evtViewSettings
	 */
	function selectPane(e:Event, evtViewSettings:String) 
	{
		//setSelected(e.target);
		Main.root1.dispatchEvent(new Event(evtViewSettings));		
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PANE_CHANGE));		
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButSettings(e:Event):Void { selectPane(e, PanelEvents.EVT_PANE_SETTINGS); }

	/**
	 * 
	 * @param	e
	 */
	private function onButReport(e:Event = null):Void  { selectPane(e, PanelEvents.EVT_PANE_REPORT); }

	/**
	 * 
	 * @param	e
	 */
	private function onButDataBase(e:Event):Void  { selectPane(e, PanelEvents.EVT_PANE_LOG); }

	/**
	 * 
	 * @param	e
	 */
	private function onButHistory(e:Event):Void  { selectPane(e, PanelEvents.EVT_PANE_HISTORY); }

	/**
	 * 
	 * @param	e
	 */
	private function onButPortal(e:Event):Void  { selectPane(e, PanelEvents.EVT_PANE_MONITOR); }

	/**	/**
	 * 
	 * @param	e
	 */
	private function onButCameraView(e:Event = null):Void  { selectPane(e, PanelEvents.EVT_PANE_CAM); }

	/**
	 * 
	 * @param	e
	 */
	private function onButMeasures(e:Event):Void  { selectPane(e, PanelEvents.EVT_PANE_MEASURES); }
}