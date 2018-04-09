package widgets;

import flash.display.Bitmap;
import flash.display.Sprite;
import org.aswing.Component;
import util.Images;

/**
 * ...
 * @author GM
 */
class SpriteMenuButton extends Sprite
{
	public var spriteEnabled	:Sprite;
	public var spriteDisabled	:Sprite;
	public var spriteEnabledSel	:Sprite;
	public var spriteDisabledSel:Sprite;
	public var sizeX	:Int;
	public var sizeY	:Int;

	public function new(?bmEn:Bitmap, ?bmDis:Bitmap, ?bmEnSel:Bitmap, ?bmDisSel:Bitmap, sizeXIn:Int = 26, sizeYIn:Int = 26) 
	{
		super();

		sizeX = sizeXIn;
		sizeY = sizeYIn;

		x += 8;
		y += 4;

		if (cast bmEn)	{
			spriteEnabled 	= new Sprite();
			spriteEnabled.addChild(bmEn);
			spriteEnabled.scaleY = spriteEnabled.scaleX = sizeY / spriteEnabled.height;
			addChild(spriteEnabled);
		}
	
		if (cast bmDis)	{
			spriteDisabled 	= new Sprite();
			spriteDisabled.addChild(bmDis);
			spriteDisabled.scaleY = spriteDisabled.scaleX = sizeY / spriteDisabled.height;
			addChild(spriteDisabled);
		}
		
		if (cast bmEnSel)	{
			spriteEnabledSel 	= new Sprite();
			spriteEnabledSel.addChild(bmEnSel);
			spriteEnabledSel.scaleY = spriteEnabledSel.scaleX = sizeY / spriteEnabledSel.height;
			addChild(spriteEnabledSel);
		}
		
		if (cast bmDisSel)	{
			spriteDisabledSel 	= new Sprite();
			spriteDisabledSel.addChild(bmDisSel);
			spriteDisabledSel.scaleY = spriteDisabled.scaleX = sizeY / spriteDisabledSel.height;
			addChild(spriteDisabledSel);
		}
	}

	/**
	 * 
	 * @param	comp
	 * @return
	 */
	public function getComponent(comp:Component):Sprite
	{
		spriteEnabled.visible 	= comp.isEnabled();
		spriteDisabled.visible	= !spriteEnabled.visible;
		
		//spriteEnabledSel.visible = 

		return this;
	}
}