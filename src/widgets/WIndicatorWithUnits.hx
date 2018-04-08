package widgets;

import db.DBTranslations;
import org.aswing.ASColor;
import org.aswing.JLabel;
import text.JTextH1;
import org.aswing.geom.IntPoint;

/**
 * ...
 * @author GM
 */
class WIndicatorWithUnits extends WIndicator
{
	var textTop		:JLabel;
	var textRight	:JLabel;

	public function new(name:String, textIn:String, colorIn:ASColor, colTextIn:ASColor, wIn:Int, hIn:Int) 
	{
		super(name, textIn, colorIn, colTextIn, wIn, hIn, cast hIn / 2.4);

		textTop = new JLabel();
		textTop.setComBounds(rectBut);
		textTop.y -= 4 + rectBut.height / 2;
		textTop.x -= 10;
		textTop.setAlignmentX(0.5);
		addChild(textTop);

		textRight = new JLabel();
		textRight.setAlignmentX(1);
		rectLight.grow( -8, -5);
		rectLight.x -= 12;
		rectLight.y += 4;
		var pnt:IntPoint = rectLight.rightTop();
		textRight.setComBoundsXYWH(pnt.x + 2, pnt.y + 8, 30, 16);
		addChild(textRight);

		label.setComBounds(rectLight);
	}

	public function setRightText(text:String) 
	{
		textRight.setText(text);
	}

	public function setTopText(text:String) 
	{
		textTop.setText(DBTranslations.getText(text));
	}

}