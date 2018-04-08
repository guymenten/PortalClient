package panesmain ;

import flash.events.MouseEvent;
import flash.geom.Rectangle;
import haxe.Timer;
import flash.events.KeyboardEvent;
import org.aswing.AWKeyboard;
import panescenter.WCenterPane;
import print.BuildPrintableReport;
import widgets.WApplicationTitle;
import widgets.WBase;
import widgets.WBottom;
import widgets.WIndicatorsPane;
import widgets.WRightPane;

/**
 * ...
 * @author GM
 */
class MainPane extends WBase
{
	var centerPaneWidget:WCenterPane;
	var indicatorsPaneWidget:WIndicatorsPane;
	var bottomWidget:WBottom;
	var rightPaneWidget:WRightPane;
	//var gridWidget:WGrid;
	public var buildPrintableReport:BuildPrintableReport;
	public var titleWidget:WApplicationTitle;

	/**
	 * 
	 */
	public function new() 
	{
		super("ID_MAIN_PANE");

		visible = false;

		titleWidget = new WApplicationTitle("ID_TITLE_PANE");
		addChild(titleWidget);

		//gridWidget = new WGrid("ID_GRID");
		//addChild(gridWidget);

		bottomWidget = new WBottom("ID_BOTTOM_PANE");
		addChild(bottomWidget);
		bottomWidget.visible = true;

		trace("new WIndicatorsPane");
		indicatorsPaneWidget = new WIndicatorsPane("ID_INDICATORS_PANE");
		addChild(indicatorsPaneWidget);
		indicatorsPaneWidget.visible = true;

		centerPaneWidget = new WCenterPane("ID_CENTERPANE");
		addChild(centerPaneWidget);
		centerPaneWidget.visible = true;

		rightPaneWidget = new WRightPane("ID_RIGHTPANE");
		//append(rightPaneWidget, BorderLayout.EAST);
		addChild(rightPaneWidget);
		rightPaneWidget.visible = true;

		haxe.Timer.delay(onInit, 100); // iOS 6
		trace("!!!!!MainPane()!!!!!!!!");

		buildPrintableReport 	= new BuildPrintableReport("ID_PRINTABLE_REPORT");
		buildPrintableReport.setVisible(false);
		addChild(buildPrintableReport);
		Model.buildPrintableReport = buildPrintableReport;
		addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
		addEventListener(KeyboardEvent.KEY_UP, onKeyboardUpEvent);
		//addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
	}
	
	/**
	 * 
	 * @param	key
	 */
	function onKeyboardUpEvent(key:KeyboardEvent) 
	{
		 removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
	}
	
	/**
	 * 
	 * @param	key
	 */
	function onKeyboardEvent(key:KeyboardEvent) 
	{
		if (key.controlKey == cast AWKeyboard.CONTROL)
			addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
	}
	
	private function onWheel(e:MouseEvent):Void 
	{
		e.stopPropagation();
		Model.ScaleX += e.delta * 0.01;
		Main.rescaleWindows(cast Model.ScaleX);
	}

	/**
	 * 
	 * @return
	 */
	public override  function getMyBounds():Rectangle
	{
		return new Rectangle(0, 0, Model.WIDTH, Model.HEIGHT);
	}

	/**
	 * 
	 */
	function onInit() 
	{
		titleWidget.addEventListener(MouseEvent.MOUSE_DOWN, Main.widgetBig.onWidgetDown);		
	}
}