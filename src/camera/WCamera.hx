package camera;

import db.DBCameras.CameraData;
import events.PanelEvents;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.PNGEncoderOptions;
import flash.display.Sprite;
import flash.events.ActivityEvent;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.media.Camera;
import flash.media.Video;
import org.aswing.ASColor;
import sound.Sounds;
import widgets.WBase;

/**
 * ...
 * @author GM
 */
class WCamera extends WBase
{
	public var camera			:Camera;
	var video					:Video;
	var camNum					:Int;
	var wCameraBound			:Int;
	var hCameraBound			:Int;
	var frame					:Sprite;
	var activityHandlerCallBack	:ActivityEvent->Void;
	var onVideoFrameCallBack	:Float->Void;
	var bmDataCapture			:BitmapData;
	var _cameraData				:CameraData;
	var camW:Int				= 640;
	var camH:Int				= 480;

	public function new(name:String, ?camNum:Int, ?dup = false) 
	{
		this.camNum		= camNum;
		super(name, dup);

		if(W > 0) createCameraView(camNum, W, H );
	}

	/**
	 * 
	 * @param	name
	 */	
	public override function duplicate(name:String):WCamera
	{
		trace("duplicateCamera()");
		return new WCamera(name, this.camNum, true);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPortalBusy(e:Event):Void 
	{
		//if(_cameraData.triggerOnBusy()) captureScreen();
	}

	/**
	 * 
	 * @param	data
	 * @param	func
	 */
	public function setMotionLevel(data:CameraData, activityFunc:ActivityEvent->Void, ?videoFrameFunc:Float->Void)
	{
		_cameraData = data;
		activityHandlerCallBack = activityFunc;
		camera.setMotionLevel(data.MotionDetection ? data.DetectionLevel : 100, data.Timeout * 1000);
		camera.addEventListener(ActivityEvent.ACTIVITY, activityHandler);

		if (cast videoFrameFunc) {
			onVideoFrameCallBack = videoFrameFunc;
			camera.addEventListener(Event.VIDEO_FRAME, onVideoFrame);
		}
		Main.root1.addEventListener(PanelEvents.EVT_PORTAL_BUSY, onPortalBusy);
	}

	/**
	 * 
	 */function onVideoFrame(e:Event):Void 
	{
		onVideoFrameCallBack(camera.activityLevel);
	}

	/**
	 * 
	 */
	public function showCamera(enabled:Bool = true, visible:Bool = true, index:Int = -1) 
	{
		if (index != -1 && index != camNum)
			createCameraView(camNum, W, H );

		setVisible(enabled && visible);

		if (isVisible()) {
			camera.setMode(camW, camH, 8);
		}
	}

	/**
	 * 
	 * @param	e
	 */
	function activityHandler(e:ActivityEvent):Void
	{
		if (e.activating) {
			if (_cameraData.triggerOnMotion())
			{
				//captureScreen();
			}

			if (_cameraData.triggerOnAlarm()) {
				Sounds.sndMotion.play();
				//captureScreen();
			}
		}

		activityHandlerCallBack(e);
	}

	/**
	 * 
	 */
	public function captureScreen() 
	{
		trace("captureScreen");
		var options 	= new PNGEncoderOptions();
		bmDataCapture 	= new BitmapData(camW, camH);

		camera.drawToBitmapData(bmDataCapture);

		var rect = new Rectangle(0, 0, video.videoWidth, video.videoHeight);
		Model.captureBiteArray = bmDataCapture.encode(rect, options);
		FileUtils.savePNGData(Model.captureBiteArray, rect, "plate.png");
	}

	/**
	 * 
	 * @param	index
	 */
	function createCameraView(camNum:Int, wIn:Int, hIn:Int):Void 
	{
		var dX 			= 4;
		wCameraBound 	= wIn + dX;
		hCameraBound	= hIn + dX;
		
		camera 			= Camera.getCamera(cast camNum);

		//camera.setQuality(0x80000, 100);
		//camera.setKeyFrameInterval(1);

		showCamera();

		video			= new Video(wIn, hIn);
		video.x += dX;
		video.y += dX;
		video.attachCamera(camera);
		video.smoothing = true;

		frame = new Sprite();
		var gfx:Graphics = frame.graphics;
		gfx.lineStyle(dX, ASColor.BELIZE_HOLE.getRGB());
		gfx.drawRoundRect( 2, 2, wCameraBound, hCameraBound, 2);
		addChild(video);
		addChild(frame);
	}

}