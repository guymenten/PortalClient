package widgets;

import flash.filesystem.File;
import flash.net.URLRequest;
import flash.events.MouseEvent;
import org.aswing.AssetPane;
import org.aswing.JLoadPane;
import org.aswing.geom.IntDimension;
import org.aswing.geom.IntRectangle;

/**
 * ...
 * @author GM
 */
class WImage extends WBase
{
	var loadPane:JLoadPane;

	public function new(name: String, strURL:String, rect:IntRectangle) 
	{
		super(name);

		loadPane = new JLoadPane();
		loadPane.setSize(new IntDimension(rect.width, rect.height));
		loadPane.x = rect.x;
		loadPane.y = rect.y;
		loadPane.setScaleMode(AssetPane.SCALE_FIT_PANE);

		loadPane.setVisible(true);
		loadPane.load(new URLRequest(File.applicationDirectory.nativePath + '\\' + strURL));
		loadPane.addEventListener(MouseEvent.CLICK, onImageClick);

		//loadPane.butCursorAllowed = true;
		//loadPane.setRightButtonEnabled();

		addChild(loadPane);
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function onImageClick(e:MouseEvent):Void 
	{
		trace("onImageClick");
	}	
}