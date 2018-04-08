package panescenter ;

import camera.WCamera;
import comp.VideoPlayer;
import events.PanelEvents;
import flash.display.Bitmap;
import flash.events.Event;
import org.aswing.ASColor;
import util.Filters;
import util.Images;
import widgets.WBarGraphs;
import widgets.WBase;
import widgets.WHorn;
import widgets.WImage;
import widgets.WIndicatorWithUnits;
import widgets.WScale;
import widgets.WSignalLight;
import widgets.WStatelogo;

/**
 * ...
 * @author GM
 */

class WPortal extends WBase
{
	public var stateLogoWidget		:WStatelogo;
	public var barGraphsWidget		:WBarGraphs;
	var signalLight					:WSignalLight;
	var horn						:WHorn;
	var scale						:WScale;
	var cameraView					:WCamera;
	var videoPlayer					:VideoPlayer;
	var plateNumber					:WIndicatorWithUnits;
	var image						:WImage;

	public function new(name:String)
	{
		super(name);

		stateLogoWidget 	= new WStatelogo(name + "_ID_PORTAL_LOGO");
		addChild(stateLogoWidget);

		//cameraView 				= new WCamera("ID_CAMERA_PANE_PORTAL", 0);
		//addChild(cameraView);

		//videoPlayer				= new VideoPlayer('IDS_VIDEO_PLAYER');
		//addChild(videoPlayer);

		//image				= new WImage('ID_IMAGE_PORTAL', 'plate1.jpg', new IntRectangle(0, 0, 400, 300));
		//addChild(image);

		barGraphsWidget 		= new WBarGraphs("ID_BARGRAPHS_PANE");
		addChild(barGraphsWidget);		
		barGraphsWidget.filters = Filters.winFilters;

		var bmp:Bitmap 			= Images.loadPortal();
		addChild(bmp);
		Images.resize(bmp, 580, 450);
		bmp.alpha = 0.8;
		bmp.filters 			= Filters.portalFilter;

		signalLight 			= new WSignalLight("ID_SIGNAL_LIGHT");
		addChild(signalLight);
	
		horn 			= new WHorn("ID_HORN");
		addChild(horn);
		
		plateNumber				= new WIndicatorWithUnits("IDS_PLATE_NUMBER", '', ASColor.CLOUDS, ASColor.CLOUDS, 140, 40);
		plateNumber.setTopText('IDS_REGISTRATION');
		addChild(plateNumber);
		
		Main.root1.addEventListener(PanelEvents.EVT_ALPR_DETECTED, onALPRDetected);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onALPRDetected(e:Event):Void 
	{
		//plateNumber.setText(Model.alprJsonData.getPlate());
	}

	/**
	 * 
	 * @param	e
	 */
	public override function refresh():Void 
	{
		if (DefaultParameters.scaleEnabled)
		{
			if (scale == null)
				scale = new WScale("ID_SCALE");
			if (!contains(scale))
				addChild(scale);
		}

		else if ((cast scale) && contains(scale))
		{
			removeChild(scale);
		}
	}

	/**
	 * 
	 * @param	visible
	 */
	override public function setVisible(visible:Bool):Void 
	{
		if (cast cameraView)
			cameraView.showCamera(Model.portalCameraEnabled, visible, Model.portalCameraIndex);
	}

}

