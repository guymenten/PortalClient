package tools ;

import comp.JButtonFramed;
import db.DBTranslations;
import flash.display.Bitmap;
import icon.IconFromBm;
import icon.MenuIcon;
import org.aswing.AbstractButton;
import org.aswing.AsWingConstants;
import org.aswing.JToolBar;
import widgets.SpriteMenuButton;
import widgets.WBase;

/**
 * ...
 * @author GM
 */
class ToolButton extends JButtonFramed
{
	//var selected:Bool;
	public var id					:String;
	public var label				:String;
	public var toolTip				:String;
	public var spriteMenuButton		:SpriteMenuButton;
	var W:Int = 24;

	/**
	 * 
	 * @param	idBut
	 * @param	bmEnabled
	 * @param	bmSel
	 * @param	bmSize
	 * @param	label
	 * @param	toolTip
	 * @param	funcPress
	 * @param	funcRelease
	 * @param	selected
	 */
	public function new(?idBut:String = "", ?label:String, ?toolTip:String, bmEn:Bitmap, ?bmDis:Bitmap, ?bmEnSel:Bitmap, ?bmDisSel:Bitmap, ?bmSize:Int, ?funcPress:Dynamic->Void,  ?funcRelease:Dynamic->Void, selected:Bool = false):Void 
	{
		super(idBut, 0, 0, W, W, funcPress, funcRelease);

		this.id				= idBut;
		
		setIcon(new IconFromBm(bmEn, W, W));
		if (cast bmDis) setSelectedIcon(new IconFromBm(bmDis, W, W));
		if (cast bmEnSel) setDisabledIcon(new IconFromBm(bmEnSel, W, W));
		if (cast bmDisSel) setDisabledSelectedIcon(new IconFromBm(bmDisSel, W, W));

		this.label			= DBTranslations.getText(label);
		this.toolTip		= DBTranslations.getText(toolTip);
		this.selected		= selected;
	}
}

/**
 * 
 */
class WTools extends WBase
{
	var dY					:Int = 0;
	var dX					:Int = 0;
	var X					:Int = 0;
	var Y					:Int = 0;
	var toolBar				:JToolBar;

	/**
	 * 
	 * @param	name
	 */
	public function new(name:String, w:Int, h:Int) 
	{
		super(name);

		toolBar = new JToolBar(AsWingConstants.HORIZONTAL, 18);
		addChild(toolBar);

		super(name);

		this.W = w;
		this.H = h;
	}

	/**
	 * 
	 * @param	enable
	 */
	function enableButtons(enabled:Bool = true)
	{
		//for (but in toolArray) {
			//but.button.setEnabled(enabled);
		//}
	}

	/**
	 * 
	 */
	function oninitButtons() 
	{
	}

	/**
	 * 
	 * @param	string
	 */
	//public function invertSelection(name:String) : Bool
	//{
		////var selected:Bool = getButton(name).isSelected();
		////getButton(name).setSelected(!selected);
		//
		//return !selected;
	//}


	/**
	 * 
	 * @param	e
	 */
	public function initButtons(dXIn:Int, dYIn:Int):Void 
	{
		//setSelected();
	}
}