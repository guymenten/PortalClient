package widgets;

import data.DataObject;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.Bitmap;
import flash.events.Event;
import util.Images;

/**
 * ...
 * @author GM
 */
class WPlotRefreshed extends WPlot
{
	public function new(name:String, data:DataObject)
	{
		super(name, data);
		
		drawAll = true;

		var bm:Bitmap = Images.loadNuclear();
		Images.resize(bm, 48, 48);
		bm.alpha = 0.6;
		graphVal.setBackgroundBitmap(bm, 164, 46);

		XRange = DBDefaults.getIntParam(Parameters.paramMeasuresXRange);

		Main.root1.addEventListener(PanelEvents.EVT_CLOCK, onShowEvent);
		Main.root1.addEventListener(PanelEvents.EVT_ON_SHOW, onShowEvent);
		Main.model.refreshCnt !.add(refreshData);
	}

	/**
	 * 
	 * @param	e
	 */
	function onShowEvent(e:Event):Void
	{
		if (visible)
			super.drawValues();
	}

	/**
	 * 
	 * @param	e
	 */
	public function refreshData(cnt:Int)
	{
		super.pushValue(dataObject);
		graphVal.setBackgroundBitmapVisible(dataObject.inRAAlarm);

		if (!graphVal.logoMode)
			graphVal.setTitle(DBTranslations.getReportLegend());
	}

	public function setLogoMode() 
	{
		graphVal.logoMode = true;
	}
}