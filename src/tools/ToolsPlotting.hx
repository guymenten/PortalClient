package tools;

import util.Images;
import widgets.WBase;

/**
 * ...
 * @author GM
 */
class ToolsPlotting extends WBase
{
	public function new(name:String, ?w:Int=32, ?h:Int=32, onButReset:Dynamic->Void, onButZoomPlus:Dynamic->Void, onButZoomMinus:Dynamic->Void, onButScale:Dynamic->Void) 
	{
		super(name);

		//push(Images.loadReset(), null,		 								 " ", "IDS_TT_PLOT_RESET", 		onButReset);
		//push(Images.loadZoomPlus(), null,									 " ", "IDS_TT_PLOT_ZOOM_PLUS", 	onButZoomPlus);
		//push(Images.loadZoomMinus(), null,								 	 " ", "IDS_TT_PLOT_ZOOM_MINUS", onButZoomMinus);
		//push("ID_LIN_LOG", Images.loadLinScale(), Images.loadLogScale(), 	 " ", "IDS_TT_PLOT_LIN_LOG", 	onButScale);

	}
}