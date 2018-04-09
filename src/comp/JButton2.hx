package comp;

import flash.events.MouseEvent;
import icon.MenuIcon;
import org.aswing.ASColor;
import org.aswing.JButton;
import db.DBTranslations;

/**
 * ...
 * @author GM
 */
class JButton2 extends JButton
{	
	public function new(?x:Int, ?y:Int, ?wIn:Int, ?hIn:Int, label:String = "", iconIn:MenuIcon = null, funcPress: Dynamic -> Void = null, funcRelease: Dynamic -> Void = null) 
	{
		super(label.indexOf("IDS") >= 0 ? DBTranslations.getText(label) : label, iconIn);

		if(x != null) setComBoundsXYWH(x, y, wIn, hIn);
		setBackground(ASColor.ALIZARIN);

		if (funcPress != null)
			addEventListener(MouseEvent.CLICK, funcPress);
	
		if (funcRelease != null)
		{
			addEventListener(MouseEvent.MOUSE_OUT, funcRelease);
			addEventListener(MouseEvent.MOUSE_UP, funcRelease);
		}
	}

	/**
	 * 
	 * @param	text
	 */
	public override function setText(label:String)
	{
		super.setText(label.indexOf("IDS") >= 0 ? DBTranslations.getText(label) : label);
	}
}