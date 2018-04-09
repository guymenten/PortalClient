package tabssettings ;

import comp.JAdjuster1;
import comp.JComboBox1;
import comp.JStepper1;
import comp.JTextTitleArea;
import db.DBDefaults;
import db.DBTranslations;
import events.PanelEvents;
import flash.display.Bitmap;
import flash.display.StageAlign;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import org.aswing.AbstractButton;
import org.aswing.event.AWEvent;
import org.aswing.event.AWEvent;
import org.aswing.event.SelectionEvent;
import org.aswing.geom.IntRectangle;
import org.aswing.JCheckBox;
import org.aswing.JPanel;
import org.aswing.LayoutManager;
import tweenx909.TweenX;

/**
 * ...
 * @author GM
 */
class SetBase extends JPanel
{
	//var butApply:JButton2;
	//var butCancel:JButton2;
	var sigmaAdjusted:Bool;
	static var cps:String;

	var X:Int = 40;
	var Y:Int = 80;

	var W:Int = 80;
	var H:Int = 24;

	public static var dX:Int = 125;
	public static var dY:Int = 60;
	public static var x1:Int = 20;
	public static var x2:Int = x1 + dX;
	public static var x3:Int = x2 + dX;
	public static var x4:Int = x3 + dX;
	public static var x5:Int = x4 + dX;
	public static var x6:Int = x5 + dX;

	public static var y1:Int = 44;
	public static var y2:Int = y1 + dY;
	public static var y3:Int = y2 + dY;
	public static var y4:Int = y3 + dY;
	public static var y5:Int = y4 + dY;

	/**
	 * 
	 * @param	layout
	 */
	public function new(?layout:LayoutManager=null) 
	{
		super(layout);

		addEventListener(Event.ADDED_TO_STAGE, added);
	
		cps = ' ' + DBTranslations.getText("IDS_CPS");
		visible = false;
	
		//setBorder(new LineBorder(null, new ASColor( ASColor.MIDNIGHT_BLUE.getRGB(), 0.6)));
	}

	/**
	 * 
	 * @param	e
	 */
	public function added(e) 
	{
		init();
		refresh();
		removeEventListener(Event.ADDED_TO_STAGE, added);
	}

	static private inline var EASE:Float = 0.2;

	//override public function setVisible(v:Bool):Void 
	//{
//
		//if (v)
		//{
			//super.setVisible(true);
			//TweenX.tweenFunc(fadeNewBitmap, [0.2], [1], EASE);
		//}
		//else
		//{
			//if (isVisible())
			//{
				//trace("SetVisible " + v);
				//TweenX.tweenFunc(fadeNewBitmap, [0.8], [0], EASE).onFinish(_hide);
			//}
		//}
	//}

	function fadeNewBitmap(alpha:Float) 
	{
		this.alpha = alpha;
	}
	
	function _hide() 
	{
		super.visible = false;
	}

	/**
	 * 
	 */
	function init():Void 
	{
		//butApply = new JButton2(190, 212, 100, 32, "IDS_APPLY", onButApply);
		//butApply.setVisible(false);
		//addChild(butApply);		

		//butCancel = new JButton2(320, 212, 100, 32, "IDS_BUT_CANCEL", onButCancel);
		//butCancel.setVisible(false);
		//addChild(butCancel);		

		Main.root1.addEventListener(PanelEvents.EVT_PANEL_STATE, onStateRefreshHandle);
	}

	/**
	 * 
	 * @param	value
	 * @return
	 */
	function translatorToCPS(value:Int):String
	{
		return Math.round(value) + cps;
	}

	/**
	 * 
	 * @param	value
	 * @return
	 */
	function translatorToRatio(value:Int):String
	{
		return Math.round(value) + '%';
	}

	/**
	 * 
	 */
	function translatorToSec(value:Int):String
	{
		return Math.round(value)+" sec";
	}

	/**
	 * 
	 * @param	e
	 */
	private function onStateRefreshHandle(e:StateMachineEvent):Void 
	{
		onStateRefresh();
	}

	function setModified() 
	{
		//butApply.setEnabled(true);
		//butCancel.setEnabled(true);
	}

	/**
	 * 
	 */
	function onButApply(e:MouseEvent) 
	{
		update();
	}

	/**
	 * 
	 */
	function onButCancel(e:MouseEvent) 
	{
		refresh();
	}

	/**
	 * 
	 */
	function update(refresh:Bool = true):Void 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PARAM_UPDATED));
	}

	function refresh():Void 
	{
	}
	
	/**
	 *
	 */
	function onStateRefresh():Void 
	{
	}
}