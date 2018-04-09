package tools;

import flash.display.Sprite;
import org.aswing.ASColor;
import org.aswing.JToolBar;
import tools.WTools.ToolButton;
import util.Images;
import widgets.WBase;

/**
 * ...
 * @author GM
 */
class ToolsView extends WBase
{
	public var butPrint:ToolButton;
	public var butZoomPlus:ToolButton;
	public var butCancel:ToolButton;
	public var butZoomMin:ToolButton;
	var bgSprite	:Sprite;
	var toolBar:JToolBar;

	public function new(name:String, ?w:Int=32, ?h:Int=32, onButZoomPlus:Dynamic->Void, onButZoomMinus:Dynamic->Void, onButPrint:Dynamic->Void, onButCancel:Dynamic->Void) 
	{
		super(name);
		//scaleX = scaleY = 0.75;
		bgSprite 	= new Sprite();
		var gfx 	= bgSprite.graphics;
		gfx.beginFill(ASColor.WET_ASPHALT.getRGB());
		gfx.drawRoundRect(0, 0, w - 10, h*3.7, 8);
		gfx.endFill();
		addChild(bgSprite);

		x = y = 4;

		toolBar = new JToolBar(JToolBar.VERTICAL, gap);
		addChild(toolBar);
		
		butZoomPlus = new ToolButton("", "", "IDS_TT_PLOT_ZOOM_PLUS", Images.loadZoomPlus(), onButZoomPlus);
		toolBar.append(butZoomPlus);
		butZoomPlus.y += gapIndex; gapIndex += gap;
		
		butZoomMin = new ToolButton("", "", "IDS_TT_PLOT_ZOOM_MINUS", Images.loadZoomMinus(), onButZoomMinus);
		toolBar.append(butZoomMin);
		butZoomMin.y += gapIndex; gapIndex += gap;
	
		butPrint = new ToolButton("", "", "IDS_TT_REPORT_PRINT", Images.loadPrinter(), onButPrint);
		toolBar.append(butPrint);
		butPrint.y += gapIndex; gapIndex += gap;
	
		butCancel = new ToolButton("", "", "IDS_TT_CLOSE_PREVIEW", Images.loadCancel(), onButCancel);
		toolBar.append(butCancel);
		butCancel.y += gapIndex; gapIndex += gap;
	}
}