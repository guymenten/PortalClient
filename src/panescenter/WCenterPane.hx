package panescenter ;

import events.PanelEvents;
import flash.events.Event;
import org.aswing.ASColor;
import laf.Colors;
import tabscameras.TabsCameras;
import tabsdb.TabsDB;
import tabssettings.Settings;
import widgets.WBase;
import widgets.WMainPaneTitle;

/**
 * ...
 * @author GM
 */

class WCenterPane extends WBase
{
	var butTitle:WMainPaneTitle;
	var reportWidget:WReport;
	var monitorWidget:WMonitor;
	var measuresWidget:WMeasures;
	var historyWidget:WHistory;
	var previousWidget:WBase;
	var settingsWidget:Settings;
	var dbWidget:TabsDB;
	var cameraWidget:TabsCameras;

	/**
	 * 
	 * @param	name
	 */
	public function new(name:String) 
	{
		super(name);

		butTitle 	= new WMainPaneTitle("ID_TITLE", 0, StateColor.backColorInInUse, ASColor.ASBESTOS, 160, 20, 40);
		addChild(butTitle);

		measuresWidget = new WMeasures("ID_MEASURES");
		measuresWidget.alpha = 0;
		measuresWidget.visible = false;
		addChild(measuresWidget);

		reportWidget = new WReport("ID_REPORT");
		reportWidget.alpha = 0;
		reportWidget.visible = false;
		addChild(reportWidget);

		monitorWidget = new WMonitor("ID_MONITOR");
		monitorWidget.alpha = 0;
		monitorWidget.visible = false;
		addChild(monitorWidget);

		historyWidget = new WHistory("ID_HISTORY");
		historyWidget.alpha = 0;
		historyWidget.visible = false;
		addChild(historyWidget);

		dbWidget = new TabsDB("ID_DB_TABS");
		dbWidget.alpha = 0;
		dbWidget.visible = false;
		addChild(dbWidget);

		settingsWidget = new  Settings("ID_SETTINGS");
		settingsWidget.alpha = 0;
		settingsWidget.visible = false;
		addChild(settingsWidget);

		if (DefaultParameters.cameraEnabled)
		{
			cameraWidget = new  TabsCameras("ID_CAM_PANE");
			cameraWidget.alpha = 0;
			cameraWidget.visible = false;
			addChild(cameraWidget);
		}

		OnMonitorWidget(null);

		Main.root1.addEventListener(PanelEvents.EVT_PANE_MONITOR, OnMonitorWidget);
		Main.root1.addEventListener(PanelEvents.EVT_PANE_MEASURES, onMeasuresWidget);
		Main.root1.addEventListener(PanelEvents.EVT_PANE_REPORT, onReportWidget);
		Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_ON, OnAlarmOn);
		Main.root1.addEventListener(PanelEvents.EVT_PANE_HISTORY, OnHistoryWidget);
		Main.root1.addEventListener(PanelEvents.EVT_PANE_LOG, OndbWidget);
		Main.root1.addEventListener(PanelEvents.EVT_PANE_SETTINGS, OnSettingsWidget);
		Main.root1.addEventListener(PanelEvents.EVT_PANE_CAM, OnCameraWidget);
		Main.root1.addEventListener("SelectReportNumber", onReportWidget);

		Main.root1.addEventListener(PanelEvents.EVT_PANE_PREVIOUS, OnViewPreviousWidget);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnAlarmOn(e:Event):Void 
	{
		if ((previousWidget != settingsWidget) && !cast Model.priviledgeAdmin) Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PANE_MONITOR));
	}

	/**
	 * 
	 * @param	e
	 */
	private function OndbWidget(e:Event):Void 
	{
		hideAll(dbWidget);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnHistoryWidget(e:Event):Void 
	{
		hideAll(historyWidget);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnViewPreviousWidget(e:Event):Void 
	{
		previousWidget.visible = true;
	}

	private function FadeOutWidget(widgetToFade:WBase, widgetToCompare:WBase):Void 
	{
		if (widgetToCompare != widgetToFade)
			widgetToFade.setVisible(false);
	}

	/**
	 * 
	 * @param	widget
	 * @param	previousWidget
	 */
	function FadingWidget(widgetToFade:WBase, widgetToCompare:WBase) 
	{
		if (widgetToCompare != widgetToFade)
			widgetToFade.setVisible(true);
	}

	/**
	 * 
	 * @param	widget
	 */
	function hideAll(widget:WBase = null)
	{
		FadeOutWidget(measuresWidget, widget);
		FadeOutWidget(monitorWidget, widget);
		FadeOutWidget(reportWidget, widget);
		FadeOutWidget(settingsWidget, widget);
		FadeOutWidget(historyWidget, widget);
		FadeOutWidget(dbWidget, widget);
		if (DefaultParameters.cameraEnabled)
			FadeOutWidget(cameraWidget, widget);

		if (widget != null)
		{
			FadingWidget(widget,previousWidget);
			previousWidget = widget;
			Main.model.textTitle = widget.getTitleText();
		}
	}

	/**
	 * 
	 * @param	e200
	 */
	private function onReportWidget(e:Event):Void 
	{
		hideAll(reportWidget);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnMonitorWidget(e:Event):Void 
	{
		hideAll(monitorWidget);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnSettingsWidget(e:Event):Void 
	{
		hideAll(settingsWidget);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onMeasuresWidget(e:Event):Void 
	{
		hideAll(measuresWidget);
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function OnCameraWidget(e:Event):Void 
	{
		hideAll(cameraWidget);
	}
}