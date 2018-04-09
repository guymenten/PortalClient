package widgets;
import db.DBTranslations;
import enums.Enums.PanelState;
import error.Errors;
import events.PanelEvents;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BitmapFilter;
import haxe.Timer;
import Main;
import org.aswing.ASColor;
import laf.Colors;
import statemachine.States;
import widgets.WBase;

/**
 * ...
 * @author GM
 */

class WIndicatorsPane extends WBase
{
	var butOutOfOrder:WIndicator;
	var butWarning:WIndicator;
	var butRAAlarm:WIndicator;
	var butControl:WIndicator;
	var butInUse:WIndicator;
	var butBKG:WIndicator;
	var bTest:Bool;
	var butAllIndicators:Sprite;
	var fontSize:Int = 10;
	var strBKG:String;
	static var butWidthDefault	= 98;
	static var butWidthOffset	= 97;
	static var butHeightDefault = 22;

	public function new(nameIn:String, filtersIn:Array<BitmapFilter>=null, ?dup = false) 
	{
		super(nameIn, filtersIn, dup);

		butAllIndicators = new Sprite();
		strBKG = DBTranslations.getText("IDS_BKG") + ' ';

		butInUse = new WIndicator("ID_STATUS_INUSE", DBTranslations.getText("IDS_STATUS_INUSE"), StateColor.backColorInInUse, ASColor.MIDNIGHT_BLUE, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butInUse);

		butControl = new WIndicator("ID_STATUS_CONTROL", DBTranslations.getText("IDS_STATUS_CONTROLLING"), StateColor.backColorInControlling, ASColor.MIDNIGHT_BLUE, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butControl);
		butControl.x = butWidthOffset;

		butRAAlarm = new WIndicator("ID_STATUS_ALARM", DBTranslations.getText("IDS_STATUS_ALARM"), StateColor.backColorInRAAlarm,  ASColor.CLOUDS, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butRAAlarm);
		butRAAlarm.x = butWidthOffset * 2;

		butBKG = new WIndicator("ID_STATUS_BKG", strBKG, StateColor.backColorInBKG,  ASColor.CLOUDS, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butBKG);
		butBKG.x = butWidthOffset * 3;

		butWarning = new WIndicator("ID_STATUS_WARNING", DBTranslations.getText("IDS_STATUS_WARNING"), StateColor.backColorInTest, ASColor.MIDNIGHT_BLUE, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butWarning);
		butWarning.x = butWidthOffset * 4;

		butOutOfOrder = new WIndicator("ID_STATUS_OUT", DBTranslations.getText("IDS_STATUS_OUT"), StateColor.backColorInOUT, ASColor.CLOUDS, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butOutOfOrder);
		butOutOfOrder.x = butWidthOffset * 5;

		addChild(butAllIndicators);

		Main.model.enabledWarning !.add(refreshButWarning);
		Main.model.enabledAlarmRA !.add(refreshButRAAlarmWarning);
		Main.model.panelState !.add(onStateRefresh);
		Main.model.testMode !.add(onTestRefresh);
	}
	
	function onTestRefresh(test:Bool) 
	{
		test? onTestOn : onTestOff;
	}
	
	/**
	 * 
	 * @param	name
	 */	
	public override function duplicate(name:String):WIndicatorsPane
	{
		trace("duplicateIndicatorsPane()");
		return new WIndicatorsPane(name, true);
	}

	function refreshButWarning(enabled:Bool) 
	{
		butWarning.setEnabled(enabled);
	}

	function refreshButRAAlarmWarning(enabled:Bool) 
	{
		butRAAlarm.setEnabled(enabled);
	}

	private function onTestOn():Void 
	{
		bTest = true;
		onStateRefresh(null);
	}

	private function onTestOff():Void 
	{
		bTest = false;
		onStateRefresh(null);
	}

	/**
	 * 
	 * @param	e
	 */
	function onStateRefresh(state:PanelState):Void
	{
		butRAAlarm.setEnabled		(bTest || Main.model.inRAAlarmToAck);
		butInUse.setEnabled		(bTest || Main.model.portalInUse);
		butControl.setEnabled	(bTest || Main.model._portalControlling);
		butOutOfOrder.setEnabled(bTest || Errors.portalInError);
		butBKG.setEnabled		(bTest || Main.model.portalBKGMeasurement);
		butBKG.setText(strBKG + Main.model.getShortStatusTextLabel());
	}
}