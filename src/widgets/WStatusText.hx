package widgets;

import events.PanelEvents;
import org.aswing.ASColor;
import text.StatusText;

/**
 * ...
 * @author GM
 */
class WStatusText extends WBase
{
	var statusText:StatusText;

	public function new(name:String, wIn:Int = 100, hIn:Int = 20, cSize:Int = 18) 
	{
		super(name);

		statusText = new StatusText(wIn, hIn, cSize); // Width as Input
		addChild(statusText);
	}
}