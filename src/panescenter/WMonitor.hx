package panescenter ;

import db.DBTranslations;
import widgets.WBase;
import widgets.WCounters;
import widgets.WStatelogo;
import widgets.WStatusText;

/**
 * ...
 * @author GM
 */
class WMonitor extends WBase
{
	//var cameraWidget	:CameraWidget;
	var portalWidget	:WPortal;
	var countersWidget	:WCounters;
	var statusTextWidget:WStatusText;
	var stateLogoWidget	:WStatelogo;

	public function new(name:String) 
	{
		super(name);
		countersWidget = new WCounters("ID_COUNTERS");
		addChild(countersWidget);
		portalWidget = new WPortal("ID_PORTAL");
		addChild(portalWidget);

		statusTextWidget = new WStatusText("ID_STATUSTEXT_WIDGET", 320, 32, 30);
		addChild(statusTextWidget);
	}

	/**
	 * 
	 * @param	v
	 */
	override public function setVisible(v:Bool):Void 
	{
		super.setVisible(v);
		portalWidget.setVisible(v);
	}

	/**
	 * 
	 * @return
	 */
	public override function getTitleText():String
	{
		return DBTranslations.getText("IDS_BUT_MONITOR");
	}
}