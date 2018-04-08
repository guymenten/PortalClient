package widgets;

import events.PanelEvents;
import flash.events.Event;
import flash.events.MouseEvent;
import tools.ToolCenterPanes;
import tools.ToolMainMenu;
import util.Images;
import widgets.WBase;

/**
 * ...
 * @author GM
 */

class WRightPane extends WBase
{
	var butLogoTop		:WBitmap;
	var toolCenterPanes	:ToolCenterPanes;
	var toolMain		:ToolMainMenu;

	/**
	 * 
	 * @param	name
	 */
	public function new(name:String) 
	{
		super(name);

		oninitButtons(null);
	}

	/**
	 * 
	 * @param	e
	 */
	private function oninitButtons(e:Event):Void 
	{
		butLogoTop		= new WBitmap			("ID_CUSTOMER_LOGO", Images.loadMXT(), 80);
		toolCenterPanes	= new ToolCenterPanes	("ID_TOOL_RIGHTMENU_L");
		toolMain		= new ToolMainMenu		("ID_TOOL_RIGHTMENU_R");	

		addChild(butLogoTop);
		addChild(toolCenterPanes);
		addChild(toolMain);
		
		addEventListener(MouseEvent.RIGHT_CLICK, onReadWindowsPositions);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onReadWindowsPositions(e:MouseEvent):Void 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_WIN_REFRESH));
	}
}