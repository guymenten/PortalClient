package tabssettings ;
import com.Mailer;
import comp.JAdjuster1;
import comp.JButton2;
import db.DBDefaults;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.StageAlign;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.utils.Timer;
import org.aswing.BorderLayout;
import org.aswing.event.AWEvent;
import org.aswing.JCheckBox;
import org.aswing.VectorListModel;
import util.Images;
import org.aswing.util.CompUtils;
//import jive.plaf.flat.FlatButtonUI;


/**
 * ...
 * @author GM
 */
class SetDebug extends SetBase
{
	var chkSignal				:JCheckBox;
	var chkSiren				:JCheckBox;
	var chkLogActivated			:JCheckBox;
	var chkAutoLogon			:JCheckBox;
	var chkDragging				:JCheckBox;
	var chkSimulation			:JCheckBox;
	var chkTest					:JCheckBox;
	var chkTestAuto				:JCheckBox;
	//var butTest					:FlatButtonUI;
	var butLog					:JButton2;
	var butReport				:JButton2;
	var vecComName				:VectorListModel;
	var adjTestOn				:JAdjuster1;
	var adjTestDelay			:JAdjuster1;
	var timerDelay				:Timer;
	var timerDuty				:Timer;

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

		chkAutoLogon 	= CompUtils.addCheckBox(this, "IDS_CHK_AUTOLOGON",		SetBase.x1 + 40, SetBase.y1, onchkAutoLogon);
		chkDragging 	= CompUtils.addCheckBox(this, "IDS_CHK_DRAGGING",		SetBase.x3 + 40, SetBase.y1, onchkDragging);
		chkSimulation 	= CompUtils.addCheckBox(this, "IDS_SIMULATION_MODE", 	SetBase.x1 + 40, SetBase.y2, onchkSimulation);
		chkSiren 		= CompUtils.addCheckBox(this, "IDS_SIREN",				SetBase.x1 + 40, SetBase.y3, onchkSiren);
		chkSignal 		= CompUtils.addCheckBox(this, "IDS_SIGNAL",				SetBase.x1 + 40, SetBase.y4, onchkSignal);
		chkLogActivated = CompUtils.addCheckBox(this, "IDS_LOGGING", 			SetBase.x5, SetBase.y3, onchkLogActivated);
		chkTest 		= CompUtils.addCheckBox(this, "IDS_BUT_TEST", 			SetBase.x1 + 40, SetBase.y5, onchkTest);
		chkTestAuto		= CompUtils.addCheckBox(this, "IDS_LOOP", 				SetBase.x5, SetBase.y5, onchkTestAuto);

		adjTestOn 		= CompUtils.addAdjuster(this, "IDS_DUTY", Images.loadtruckYellowIcon(), StageAlign.TOP, SetBase.x2 + 20, SetBase.y5, Parameters.paramTestDuty, onTestOnTime, 66);
		adjTestDelay 	= CompUtils.addAdjuster(this, "IDS_DELAY", StageAlign.TOP, SetBase.x3 + 20, SetBase.y5, Parameters.paramTestDelay, onTestDelayTime, 66);

		//butTest = new FlatButtonUI();
		//addChild(butTest);
		butLog				= new JButton2(SetBase.x5, SetBase.y4, 120, 32, "IDS_SAVE_LOGGING", null, onButLog);
		butLog.setToolTipText("IDS_TT_BUT_LOG");
		addChild(butLog);

		butReport			= new JButton2(SetBase.x5, SetBase.y1, 120, 32, "IDS_REPORT", null, onPortalFree);
		butReport.setToolTipText("IDS_TT_BUT_CREATE_REPORT");
		butReport.addEventListener(MouseEvent.MOUSE_DOWN, onPortalBusy);
		addChild(butReport);
	}

	/**
	 * 
	 * @param	e
	 */
	function onTestDelayTime(e:AWEvent) 
	{
		DefaultParameters.paramTestDelay = adjTestDelay.getValue();
		Model.dbDefaults.setIntParam(Parameters.paramTestDelay, DefaultParameters.paramTestDelay);
		updateTest();
	}

	/**
	 * 
	 * @param	e
	 */
	function onTestOnTime(e:AWEvent) 
	{
		DefaultParameters.paramTestDuty = adjTestOn.getValue();
		Model.dbDefaults.setIntParam(Parameters.paramTestDuty, DefaultParameters.paramTestDuty);
		updateTest();
	}

	/**
	 * 
	 * @param	start
	 */
	function updateTest(?start:Bool) 
	{
		if (!cast timerDelay)
		{
			timerDelay	= new Timer(DefaultParameters.paramTestDelay * 1000);
			timerDuty	= new Timer(DefaultParameters.paramTestDuty * 1000);
			timerDelay.addEventListener(TimerEvent.TIMER, onDelay);
			timerDuty.addEventListener(TimerEvent.TIMER, onDuty);
		}
		else {
			timerDelay.delay = DefaultParameters.paramTestDelay * 1000;
			timerDuty.delay = DefaultParameters.paramTestDuty * 1000;
		}

		timerDuty.stop();

		if (start)
			timerDelay.start();
		else
		{
			timerDuty.stop();
			timerDelay.stop();
			setTest(false);		
		}
		//Model.arduino.setPinMode(9, ArduinoBase.PIN_MODE_PWM);
		//Model.arduino.setTestPWM(9, DefaultParameters.paramTestDelay, DefaultParameters.paramTestDuty);		
	}

	/**
	 * 
	 * @param	e
	 */
	function onDuty(e:TimerEvent) 
	{
		timerDuty.stop();
		timerDelay.start();
		setTest(false);
	}

	/**
	 * 
	 * @param	e
	 */
	function onDelay(e:TimerEvent) 
	{
		timerDelay.stop();
		timerDuty.start();
		setTest(true);		
	}

	/**
	 * 
	 * @param	object
	 */
	function setTest(test:Bool) 
	{
		adjTestOn.spriteLeft.visible = test;
		Model.arduino.setTest(test);		
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPortalBusy(e:MouseEvent):Void 
	{
		Model.IOTestStatus = true;
	}

	/**
	 * 
	 */
	function onPortalFree(e:Event) 
	{
		Model.IOTestStatus = false;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkLogActivated(e:AWEvent):Void 
	{
		for (channel in Model.channelsArray)
		{
			channel.enablelog(chkLogActivated.isSelected());
		}
	}

	/**
	 * 
	 * @param	e
	 */
	function onButLog(e:Event) 
	{
		var Log = new Mailer("guymenten@gmail.com", "guymenten@yahoo.com");
		//var Log:Http = new Http("http://www.google.com");
		//Log.request();
		//saveValuesLogFile();
		
	}

	/**
	 * Write Value in Log File
	 * @param	channelData
	 */
	function saveValuesLogFile()
	{
		//strLogFile +=  + ',' + cd._counter + ',' + cd.deviation + ','  + cd.average +','  + cd.threshold + ','  + cd.noise + '\n';
		var strLogFile:String= "";
		var str:String = Date.now().toString();
		var file = File.applicationDirectory.resolvePath("log/log.txt");

		for (channel in Model.channelsArray)
		{
			strLogFile += channel.strLogFile;
		}

		file.save(strLogFile, file.name);
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
		chkAutoLogon.setSelected(cast DBDefaults.getIntParam(Parameters.paramAutoLogon));
		chkSimulation.setSelected(cast DBDefaults.getIntParam(Parameters.paramSimulatorMode));
		chkDragging.setSelected(cast DBDefaults.getIntParam(Parameters.paramHookMode));
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkSimulation(e:AWEvent):Void 
	{
		Model.dbDefaults.setIntParam(Parameters.paramSimulatorMode, cast chkSimulation.isSelected());		
	}

	/**
	 * 
	 */
	function onchkSignal(e:AWEvent):Void 
	{
		Model.arduino.setRedLamp(e.target.isSelected());		
	}

	/**
	 * 
	 */
	function onchkTestAuto(e:AWEvent):Void 
	{
		updateTest(e.target.isSelected());
	}

	/**
	 * 
	 */
	function onchkTest(e:AWEvent):Void 
	{
		setTest(e.target.isSelected());		
	}

	/**
	 * 
	 */
	function onchkSiren(e:AWEvent):Void 
	{
		Model.arduino.playSiren(e.target.isSelected());
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkAutoLogon(e:AWEvent):Void 
	{
		Model.dbDefaults.setIntParam(Parameters.paramAutoLogon, cast chkAutoLogon.isSelected());
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function onchkDragging(e:AWEvent):Void 
	{
		Model.dbDefaults.setIntParam(Parameters.paramHookMode, cast chkDragging.isSelected());
		update();
	}
}