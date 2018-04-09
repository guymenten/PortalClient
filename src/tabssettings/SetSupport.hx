package tabssettings ;
import comp.JAdjuster1;
import comp.JButtonFramed;
import comp.JComboBox1;
import comp.JStepper1;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.ErrorCode;
import enums.Enums.Parameters;
import error.Errors;
import events.PanelEvents;
import flash.events.Event;
import org.aswing.AbstractButton;
import org.aswing.BorderLayout;
import org.aswing.event.AWEvent;
import org.aswing.event.SelectionEvent;
import org.aswing.geom.IntRectangle;
import org.aswing.JCheckBox;
import org.aswing.util.CompUtils;
import org.aswing.VectorListModel;
import util.Images;

/**
 * ...
 * @author GM
 */
class SetSupport extends SetBase
{
	var chkChannelEnabled		:JCheckBox;
	var cbChannelName			:JComboBox1;
	var adjRASmoothMeasure		:JAdjuster1;
	var butCalibration			:JButtonFramed;
	var adjDetections			:JAdjuster1;
	var adjDeviation			:JAdjuster1;
	var stepCom					:JAdjuster1;
	var stepIO					:JAdjuster1;
	var tfBKGMeasureTotalTime	:JAdjuster1;
	var tfAutoBKGTime			:JAdjuster1;
	var tfAutoBKGMeasureTime	:JAdjuster1;
	var vecComName				:VectorListModel;
	var strChannelNameSelected	:String;

	/**
	 * 
	 */
	public function new() 
	{
		super(new BorderLayout(0, 0));
	}

	/**
	 * 
	 */
	private override function init():Void
	{
		super.init();

		butCalibration 			= new JButtonFramed("ID_CALIBRATION", SetBase.x5, SetBase.y4, 120, 32, "IDS_CALIBRATION", null, onButCalibrate);
		addChild(butCalibration);

		cbChannelName 			= CompUtils.addComboBox(this, "IDS_CHANNEL", Images.loadEncoder(), SetBase.x1 + 60, SetBase.y1, 260, onChannelNamechanged);

		tfBKGMeasureTotalTime 	= CompUtils.addAdjuster(this, "IDS_BKG_TIME", 				Images.loadChrono(), 	SetBase.x5, SetBase.y1, 	Parameters.paramBKGMeasurementTime, translatorToSec, ontfBKGMeasureTotalTime);
		tfAutoBKGTime 			= CompUtils.addAdjuster(this, "IDS_BKG_AUTO_MEASURE_TIME",	Images.loadChrono(), 	SetBase.x5, SetBase.y2, 	Parameters.paramBKGReactualizationTime, translatorToSec, ontfAutoBKGTime);
		tfAutoBKGMeasureTime 	= CompUtils.addAdjuster(this, "IDS_BKG_COMPUTE_TIME",		Images.loadChrono(), 	SetBase.x5, SetBase.y3, 	Parameters.paramBKGMeasureTime, translatorToSec, ontfAutoBKGMeasureTime);

		chkChannelEnabled 		= CompUtils.addCheckBox(this, "IDS_ENABLED", 										SetBase.x3, SetBase.y3, onchkChannelEnabled);
		adjRASmoothMeasure 		= CompUtils.addAdjuster(this, "IDS_BUT_SMOOTHING", 			Images.loadAverage(), 	SetBase.x1 + 60, SetBase.y2, 	Parameters.paramRateMeterBufferSize, 	onSmoothingAdjChanged);
		adjDetections			= CompUtils.addAdjuster(this, "IDS_BUT_COUNT_BEFORE_ALARM",	Images.loadLEDRAOn(), 	SetBase.x3, SetBase.y2, 		Parameters.paramDetectionsBeforeAlarm, 	onRACountAdjChanged);
		adjDeviation			= CompUtils.addAdjuster(this, "IDS_MIN_DEVIATION",			Images.loadDeviation(), SetBase.x1 + 60, SetBase.y3, 	Parameters.paramMinimumDeviation, 		onDeviationAdjChanged);

		stepCom					= CompUtils.addAdjuster(this, "IDS_COM",					Images.loadSerial(), SetBase.x1 + 60, SetBase.y4,  	Parameters.paramComIO, 					onComIOChanged);
		stepIO					= CompUtils.addAdjuster(this, "IDS_IO_COM",					Images.loadSerial(), SetBase.x1 + 60, SetBase.y5, 	Parameters.paramComArduino, 			onComArduinoChanged);

		fillChannelNameCB();
		onChannelNamechanged();
	}

	/**
	 * 
	 * @param	e
	 */
	function onComIOChanged(e:AWEvent):Void 
	{
		DefaultParameters.setPortNumber(Parameters.paramComIO, stepCom.adjuster.getValue());
	}

	/**
	 * 
	 * @param	e
	 */
	function onComArduinoChanged(e:AWEvent):Void 
	{
		DefaultParameters.setPortNumber(Parameters.paramComArduino, stepIO.adjuster.getValue());
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkChannelEnabled(e:AWEvent):Void 
	{
		for (channel in Model.channelsArray)
		{
			if (channel.label == strChannelNameSelected)
			{
				channel.enabled = chkChannelEnabled.isSelected();
				Model.dbChannelsDefaults.updateEnabled(channel.label, channel.enabled);
			}
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function isChannelEnabled():Bool 
	{
		for (channel in Model.channelsArray)
		{
			if (channel.label == strChannelNameSelected)
			{
				return channel.enabled;
			}
		}
		return true;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onChannelNamechanged(e:String = null):Void 
	{
		strChannelNameSelected = cbChannelName.combobox.getSelectedItem();
		refresh();
	}

	/**
	 * 
	 */
	function fillChannelNameCB() 
	{
		vecComName = new VectorListModel([]);
		var strLabel:String;
		
		for (channel in Model.channelsArray)
		{
			strLabel = channel.label;
			vecComName.append(strLabel);
		}

		cbChannelName.combobox.setModel(vecComName);
		cbChannelName.combobox.setSelectedItem(strLabel);
	}

	/**
	 * 
	 * @param	e
	 */
	function ontfAutoBKGMeasureTime(e:Dynamic) 
	{
		Model.dbDefaults.setIntParam(Parameters.paramBKGMeasureTime, tfAutoBKGMeasureTime.adjuster.getValue());
		Update();
	}

	/**
	 * 
	 * @param	e
	 */
	function ontfBKGMeasureTotalTime(e:Dynamic) 
	{
		Model.dbDefaults.setIntParam(Parameters.paramBKGMeasurementTime, tfBKGMeasureTotalTime.adjuster.getValue());
		Update();
	}

	function ontfAutoBKGTime(e:Dynamic) 
	{
		Model.dbDefaults.setIntParam(Parameters.paramBKGReactualizationTime, tfAutoBKGTime.adjuster.getValue());		
		Update();
	}

	/**
	 * 
	 */
	function onButCalibrate(e:Event) 
	{
		Main.dialogWidget.setYesNoDialog(onClose, onCalibrationDone, "IDS_MSG_DLG_CALIBRATION", "IDS_BUT_CANCEL", "IDS_CONFIRMATION");
		Main.dialogWidget.setVisible(true);
	}

	/**
	 * 
	 */
	function onCalibrationDone() 
	{
		var date:String =  Date.now().toString();
		Model.dbDefaults.setStringParam(Parameters.paramCalibrationDate, date);	
		Errors.sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_CALIBRATION, date));

		Main.dialogWidget.setVisible(false);		
	}

	/**
	 * 
	 */
	function onClose() 
	{
		Main.dialogWidget.setVisible(false);
	}

	/**
	 * 
	 * @param	e
	 */	
	private function onSmoothingAdjChanged(e:AWEvent):Void 
	{
		for (channel in Model.channelsArray)
		{
			if (channel.label == strChannelNameSelected)
			{
				channel.Smoothing = adjRASmoothMeasure.adjuster.getValue();
				Model.dbChannelsDefaults.updateSmooting(channel.label, channel.Smoothing);
			}
		}

		Update();
	}

	/**
	 * 
	 * @param	e
	 */	
	private function onRACountAdjChanged(e:AWEvent):Void 
	{
		for (channel in Model.channelsArray)
		{
			if (channel.label == strChannelNameSelected)
			{
				channel.Detections = adjDetections.adjuster.getValue();
				Model.dbChannelsDefaults.updateDetections(channel.label, channel.Detections);
			}
		}

		Update();
	}
	/**
	 * 
	 * @param	e
	 */	
	private function onDeviationAdjChanged(e:AWEvent):Void 
	{
		for (channel in Model.channelsArray)
		{
			if (channel.label == strChannelNameSelected)
			{
				channel.MinimumDeviation = adjDeviation.adjuster.getValue();
				Model.dbChannelsDefaults.updateMinimumDeviation(channel.label, channel.MinimumDeviation);
			}
		}

		Update();
	}

	/**
	 * 
	 * @param	e
	 */
	function Update():Void 
	{
		super.update();
		Main.model.resetBKGMeasurement = true;
	}
 
	/**
	 * 
	 */
	override function refresh(): Void
	{
		tfBKGMeasureTotalTime.adjuster.setValue(DefaultParameters.bkgInitializationTime);
		tfAutoBKGTime.adjuster.setValue(DefaultParameters.BKGReactualizationTime);
		tfAutoBKGMeasureTime.adjuster.setValue(DefaultParameters.bkgMeasureTime);
		chkChannelEnabled.setSelected(isChannelEnabled());
		stepCom.adjuster.setValue(DefaultParameters.IOComNumber);
		stepIO.adjuster.setValue(DefaultParameters.arduinoComNumber);

		for (channel in Model.channelsArray)
		{
			if (channel.label == strChannelNameSelected)
			{
				adjDetections.adjuster.setValue(channel.Detections);
				adjRASmoothMeasure.adjuster.setValue(channel.Smoothing);
				adjDeviation.adjuster.setValue(channel.MinimumDeviation);
			}
		}
	}
}