package comp;

import flash.events.*;
import flash.media.*;
import flash.display.Bitmap;
import flash.utils.ByteArray;
import flash.utils.Object;
import flash.utils.Timer;
import flash.net.*;
import widgets.*;
import flash.display.BitmapData;
import flash.display.PNGEncoderOptions;
import flash.geom.Rectangle;
import util.NativeProcesses;

/**
 * ...
 * @author GM
 */
class VideoPlayer extends WBase
{
	var ns	:NetStream;
	var nc	:NetConnection;
	var vid	:Video;
	var bmDataCapture:BitmapData;
	var timer:Timer;
	var strMovie = "test.mp4";

	/**
	 * 
	 * @param	str
	 */
	public function new(str:String) 
	{
		super(str);

		nc 		= new NetConnection();
		nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamConnect);
		nc.connect(null);
	
		//timer = new Timer(1000);
		//timer.addEventListener(TimerEvent.TIMER, onTimer);
		//timer.start();
	}

	/**
	 * 
	 */
	function onTimer(e:Event) 
	{
		captureImage();
	}

	/**
	 * 
	 * @param	evt
	 */
	public function onNetStreamConnect(evt:NetStatusEvent):Void
	{
        if (evt.info.code == 'NetConnection.Connect.Success') {

            ns = new NetStream(nc);
			ns.client = this;

            try {                 
				ns.play(strMovie);
				vid		= new Video(640, 480);
				vid.attachNetStream(ns);

                // Now, you just have to add the video to the display list to make appear on the screen
                addChild(vid);

            } catch(error:Dynamic) {

                trace(error.message);
            }
        }
    }

	/**
	 * 
	 */
	function captureImage() 
	{
		trace("captureImage");
		var options 			= new PNGEncoderOptions();
		var rect 				= new Rectangle(0, 0, vid.videoWidth, vid.videoHeight);
		bmDataCapture 			= new BitmapData(vid.videoWidth, vid.videoHeight);

		var bmData:BitmapData 	= new BitmapData(cast rect.width, cast rect.height);
		bmData.draw(vid);
		var ba:ByteArray = new ByteArray();
		ba = bmData.encode(rect, options);
		FileUtils.savePNGData(ba, rect, "plate.png");
		NativeProcesses.startAlpr();
	}

	/**
	 * 
	 * @param	eobj
	 */
	function onPlayStatus(eobj:Object):Void
	{
		if (eobj.code == 'NetStream.Play.Complete')
		{
			trace ("Video Complete");
			play();
		}
	}

	/**
	 * 
	 * @param	eobj
	 */
	function onMetaData(item:Dynamic):Void
	{
		trace('Time: ' + item.time);
		//for(s in eobj){
		//trace(s,eobj[s]);
		//}
		//duration = eobj.duration;
	}

	/**
	 * 
	 * @param	strMovie
	 */
	public function play()
	{
		ns.play(strMovie); 
	}
}