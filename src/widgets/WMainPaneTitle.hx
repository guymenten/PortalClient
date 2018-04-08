package widgets;

import flash.text.TextFormat;
import org.aswing.ASColor;
import org.aswing.geom.IntRectangle;
import org.aswing.JLabel;

/**
 * ...
 * @author GM
 */
class WMainPaneTitle extends WBase
{
	public var txtValue		:JLabel;

	/**
	 * 
	 * @param	textIn
	 * @param	indexIn
	 * @param	colorIn
	 * @param	colTextIn
	 * @param	wIn
	 * @param	hIn
	 * @param	fontSizeIn
	 */
	public function new(textIn:String, indexIn:Int, colorIn:ASColor, colTextIn:ASColor, wIn:Int, hIn:Int, fontSizeIn:Int) 
	{
		super(textIn);
	
		txtValue 		= new JLabel();
		txtValue.font.changeSize(fontSizeIn);
		txtValue.setComBoundsXYWH(0, 0, wIn, hIn);
		txtValue.setForeground(colorIn);

		addChild(txtValue);
		Main.model.textTitle !.add (setText);
	}

	/**
	 * 
	 * @param	text
	 */
	public function setText(text:String) 
	{
		visible = !(text == "");
		txtValue.setText(text);
	}
}