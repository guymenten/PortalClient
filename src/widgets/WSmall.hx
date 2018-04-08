package widgets;

import db.DBDefaults;
import enums.Enums.Parameters;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import panescenter.WPortal;
import util.Images;
import util.ScreenManager;
import widgets.WStatelogo;

/**
 * ...
 * @author GM
 */
class WSmall extends Widget
{
	//var previousLogo:Sprite;
	var hook:Bitmap;
	var portalWidget	:WPortal;
	var widgetSize:Int;
	var stateLogoWidget:WStatelogo;
	var widgets:Array<Dynamic>;

	/**
	 * 
	 */
	public function new()
	{
		super();

		hook = Images.loadMenu();
		x			= cast DBDefaults.getIntParam(Parameters.paramWidgetposX);
		y			= cast DBDefaults.getIntParam(Parameters.paramWidgetposY);
		widgetSize	= cast DBDefaults.getIntParam(Parameters.paramWidgetSize);

		var rect:Rectangle = ScreenManager.getMaximumAvailableResolution();

		if (x > rect.width)
		{
			rect = ScreenManager.getActualScreenBounds(1);
			x = rect.right - widgetSize;
			y = rect.top;
		}
		
		Images.resize(hook, 24);
		addChild(hook);

		widgets = new Array<Dynamic>();
		createWidget();
	}

	override function createWidget():Void
	{
		addEventListener(MouseEvent.MOUSE_DOWN, onWidgetDown);
		super.createWidget();

		//portalWidget = new WPortal("ID_PORTAL_SMALL");
		//addChild(portalWidget);
//
		//var dataObject:DataObject;
		//var cntWidget:WCounter;
//
		//for (dao in Model.channelsArray)
		//{
			//dataObject =  Model.channelsArray.get(dao.getAddress());
//
			//cntWidget = new WCounter("ID_COUNTER_SMALL" + dao.channelIndex, dataObject);
			//cntWidget.scaleX = cntWidget.scaleY = 0.64;
			//cntWidget.y += 134;
			//cntWidget.x -= 64;
			//addChild(cntWidget);
		//}
	}

	/**
	 *
	 */
	override function saveWinPos():Void
	{
		super.saveWinPos();

		Model.dbDefaults.setIntParam(Parameters.paramWidgetposX, cast x);
		Model.dbDefaults.setIntParam(Parameters.paramWidgetposY, cast y);
	}

	/**
	 *
	 */
	public function bringToFront(sprite:Sprite):Void
	{
		sprite.parent.setChildIndex(sprite, sprite.parent.numChildren - 1);
	}

	/**
	 * 
	 * @param	duplicated
	 */
	public function addWidget(duplicated:Dynamic) 
	{
		if (cast duplicated.alpha)
		{
			widgets.push(duplicated);
			addChild(duplicated);
		}
	}

	/**
	 * 
	 * @param	duplicated
	 */
	public function removeWidget(duplicated:Dynamic) 
	{
		if (cast duplicated)
		{		
			if (getChildIndex(duplicated) > -1)
			{
				removeChild(duplicated);
				duplicated.visible = false;
			}
			widgets.remove(duplicated);
		}
	}
}
