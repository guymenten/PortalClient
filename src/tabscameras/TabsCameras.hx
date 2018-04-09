package tabscameras;

import db.DBTranslations;
import flash.media.Camera;
import tabsCameras.TabCamera;
import util.Images;
import widgets.TabConditional;
import hxIS.examples.NsExample;

/**
 * ...
 * @author GM
 */

class TabsCameras extends TabConditional
{
	/**
	 * 
	 * @param	name
	 */
	public function new(name:String) 
	{
		super(name);
	}

	/**
	 * 
	 */
	private override function createUserTabs():Void
	{
		var index:Int = 0;
		var camName:String = DBTranslations.getText("IDS_CAMERA") + ' ';

		for (name in Camera.names)
		{
			var tab:TabCamera = new TabCamera(index);
			appendTab(tab, camName + index++, 	Images.loadCamera());
		}
		
		var tab:NsExample = new NsExample();
		appendTab(tab, camName + index++, 	Images.loadCamera());

		//appendTab(new TabCamera(-1), "IDS_CAMERAS", Images.loadCamera());
	}

	/**
	 * 
	 * @return
	 */
	public override function getTitleText():String
	{
		return DBTranslations.getText("IDS_STORAGE");
	}
}