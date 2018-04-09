package tabsCameras;

import camera.WCamera;
import comp.JAdjuster1;
import db.DBCameras;
import events.PanelEvents;
import flash.events.ActivityEvent;
import flash.events.Event;
import flash.media.Camera;
import org.aswing.event.AWEvent;
import org.aswing.event.InteractiveEvent;
import org.aswing.JCheckBox;
import org.aswing.util.CompUtils;
import tabssettings.SetBase;
import util.Images;
import util.NativeProcesses;
import widgets.WBarGraph;

/**
 * ...
 * @author GM
 */
class TabCamera extends SetBase
{
	static var chkMotion:JCheckBox;
	static var chkAlarm:JCheckBox;
	static var chkReport:JCheckBox;
	static var chkANPR:JCheckBox;
	static var adjMotion:JAdjuster1;
	static var adjTimeout:JAdjuster1;
	var cameraIndex:Int;
	var initialized:Bool;
	var cameraViews:Array<WCamera>;
	var currentIndex:Int;
	var barGraphWidget:WBarGraph;
	var camera:Camera;

	/**
	 * 
	 * @param	name
	 */
	public function new(index:Int) 
	{
		super();

		cameraViews = new Array <WCamera>();
		cameraIndex = index;
	}

	/**
	 * 
	 */
	override function refresh(): Void
	{
		var data = DBCameras.getCameraData(cameraIndex);
	
		chkMotion.setSelected(data.MotionDetection);
		chkAlarm.setSelected(data.triggerOnAlarm());
		chkReport.setSelected(data.triggerOnBusy());
		adjMotion.adjuster.setValue(data.DetectionLevel);
		adjTimeout.adjuster.setValue(data.Timeout);
	}

	/**
	 * 
	 * @param	e
	 */
	function _onAdjMotion(e:AWEvent) 
	{
		trace("_onAdjMotion");
		updateDB();
	}

	/**
	 * 
	 * @param	e
	 */
	function _onAdjAlarm(e:AWEvent) 
	{
		updateDB();
	}

	/**
	 * 
	 */
	function onButAlpr(e:Dynamic) 
	{
		NativeProcesses.startAlpr();
		//videoPlayer.play(File.applicationDirectory.nativePath + '\\test.mp4');
	}
	/**
	 * 
	 * @param	e
	 */
	private function onchkANPR(e:AWEvent):Void 
	{
		if (chkANPR.selected)
		{
			Main.root1.addEventListener(PanelEvents.EVT_PORTAL_FREE, onPortalFree);
		}
		else {
			Main.root1.removeEventListener(PanelEvents.EVT_PORTAL_FREE, onPortalFree);

		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPortalFree(e:Event):Void 
	{
		_getCamView().captureScreen();
		NativeProcesses.startAlpr();
	}
	
	/**
	 * 
	 * @param	e
	 */
	function _onAdjReport(e:AWEvent) 
	{
		updateDB();
	}

	/**
	 * 
	 * @param	refresh
	 */
	function updateDB(refresh:Bool = true, fromBarGraph:Bool = false):Void 
	{
		var data = DBCameras.getCameraData(cameraIndex);

		if (refresh)
		{
			data.DetectionLevel 	= adjMotion.getValue();
			data.Timeout		 	= adjTimeout.getValue();
			data.MotionDetection 	= chkMotion.isSelected();
			data.setTriggerOnAlarm(chkAlarm.isSelected());
			data.setTriggerOnBusy(chkReport.isSelected());
			Model.dbCameras.updateDetectionLevel(data);

			if (!fromBarGraph) _updateBarGraph();
		}

		_getCamView().setMotionLevel(data, _activityHandler, _onVideoFrame);		
		barGraphWidget.setVisible(data.MotionDetection);
	}

	/**
	 * 
	 * @param	index
	 */
	function _getCamView() : WCamera
	{
		return cameraViews[currentIndex];
	}

	/**
	 * 
	 * @param	v
	 */
	override public function setVisible(v:Bool):Void 
	{
		var ratio:Float = 1.5;

		if (v)
		{
			if (!initialized)
			{
				initialized = true;
				initCameras(cameraIndex, cast 384 * ratio, cast 264 * ratio);
				addChild(_getCamView());
			}

			addChild(chkMotion);
			addChild(chkAlarm);
			addChild(chkReport);
			addChild(adjMotion);
			addChild(adjTimeout);
			addChild(chkANPR);
			refresh();
		}

		super.setVisible(v);
	}

	/**
	 * 
	 */
	private override function init():Void
	{
		super.init();

		if (!cast chkMotion) // Singleton
		{
			adjMotion 	= CompUtils.addAdjuster(this, "IDS_MOTION_VALUE", Images.loadMotion(), SetBase.x5+20, SetBase.y1, 0, 100, translatorToRatio, _onAdjMotion, 100);
			adjTimeout 	= CompUtils.addAdjuster(this, "IDS_ACTIVITY_TIMEOUT", Images.loadClock(), SetBase.x5+20, SetBase.y2, 0, 10, translatorToSec, _onAdjMotion, 100);
			chkMotion 	= CompUtils.addCheckBox(this, "IDS_MOTION_DETECTION", SetBase.x5+20, SetBase.y3 , onchkMotion);
			chkAlarm 	= CompUtils.addCheckBox(this, "IDS_SND_RAALARM", SetBase.x5+20, SetBase.y4 , onchkAlarm);
			chkReport 	= CompUtils.addCheckBox(this, "IDS_REPORT", SetBase.x5+20, SetBase.y5 , 100, onchkReport);
			chkANPR 	= CompUtils.addCheckBox(this, "IDS_ANPR", SetBase.x6 + 40, SetBase.y5 , onchkANPR);
		}

		//adjMotion.adjuster.addStateListener(_onMotionChanging);
		barGraphWidget = new WBarGraph("ID_BARGRAPH_CAM" + cameraIndex, _onthrMove, _onthrStop);
		barGraphWidget.setVisible(false);
		addChild(barGraphWidget);
 	}

	/**
	 * 
	 * @param	e
	 */
	function _onthrMove(e:Dynamic) :Void
	{
		var val:Int = cast e;
		adjMotion.adjuster.getModel().setValue(val);
	}
	
	/**
	 * 
	 * @param	e
	 */
	function _onthrStop(e:Dynamic) :Void
	{
		_onthrMove(e);
		updateDB(true, true);
	}

	/**
	 * 
	 * @param	e
	 */
	private function _onMotionChanging(e:InteractiveEvent):Void 
	{
		_updateBarGraph();
	}

	/**
	 * 
	 */
	public function initCameras(camNum:Int, wIn:Int, hIn:Int)
	{
		var ratio:Float = 1;
		var xCam:Int = 0, yCam:Int = 0, index:Int = 0;

		if (camNum == -1)
		{
			for (name in Camera.names)
			{
				_createCameraView(index++, xCam, yCam, cast wIn / ratio, cast hIn / ratio);
				xCam += 10 + cast wIn / ratio;

				if (xCam > 400)
				{
					xCam = 0;
					yCam += 10 + cast hIn / ratio;
				}
			}
			return;
		}

		_createCameraView(camNum, 0, 0, wIn, hIn);
	}

	/**
	 * 
	 * @param	index
	 * @param	w
	 * @param	h
	 */
	function _createCameraView(index:Int, x:Int, y:Int, w:Int, h:Int):Void 
	{
		cameraViews[currentIndex] = new WCamera("ID_CAMERA_PANE_0", index);
		camera = cameraViews[currentIndex].camera;
		updateDB(false);
	}

	/**
	 * 
	 * @param	e
	 */
	function _activityHandler(e:ActivityEvent):Void
	{
		barGraphWidget.setInAlarm(e.activating);
	}

	/**
	 * 
	 */
	function _onVideoFrame(activity:Float):Void
	{
		barGraphWidget.setValue(activity);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkMotion(e:AWEvent):Void 
	{
		_onAdjMotion(e);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkAlarm(e:AWEvent):Void 
	{
		_onAdjAlarm(e);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkReport(e:AWEvent):Void 
	{
		_onAdjReport(e);
	}

	/**
	 * 
	 */
	function _updateBarGraph():Void 
	{
		barGraphWidget.setMinMax(0, 100, cast  adjMotion.getValue());
	}

}