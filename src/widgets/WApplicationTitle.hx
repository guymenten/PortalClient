package widgets;

import db.DBTranslations;
import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.geom.Rectangle;
import haxe.Timer;
import org.aswing.ASColor;
import text.JTextTitle;

/**
 * ...
 * @author GM
 */
class WApplicationTitle extends WBase
{
	var title		:Sprite;
	var textTitle	:JTextTitle;
	var bAlternate	:Bool;
	var strAlternateText:String;
	var strTitle:String;

	public function new(name:String) 
	{
		title = new Sprite();
		super(name);
		loadTitle();
	}

	/**
	 * 
	 * @return
	 */
	public override function getMyBounds():Rectangle
	{
		return new Rectangle(0, 0, Model.WIDTH, 20);
	}

	/**
	 * 
	 */
	function loadTitle() 
	{
		textTitle = new JTextTitle();
		textTitle.setPosition(0, 0, 780, 28);
		textTitle.setPreferredHeight(28);
		textTitle.setEditable(false);

		var applicationDescriptor:String = NativeApplication.nativeApplication.applicationDescriptor.toString();
		var versionNumber:String = applicationDescriptor.substring(applicationDescriptor.indexOf("versionNumber>") + 14, applicationDescriptor.lastIndexOf("</versionNumber"));

		strTitle 			= DBTranslations.getText("IDS_MSG_COPYRIGHT") + versionNumber;

		title.addChild(textTitle);
		this.addChild(title);

		var gfx = this.graphics;
		gfx.lineStyle(1, ASColor.PETER_RIVER.getRGB());

		gfx.moveTo(14, 20);	// Top Line Start
		gfx.lineTo(714, 20);

		gfx.moveTo(808, 20); // Top Line End
		gfx.lineTo(830, 20);

		gfx.lineStyle(3, ASColor.MIDNIGHT_BLUE.getRGB());

		gfx.moveTo(700, 60); // Vertical Line
		gfx.lineTo(700, 360);

		gfx.moveTo(14, 400); // Bottom Line
		gfx.lineTo(830, 400);

		onTimer();
	}

	/**
	 * 
	 */
	function onTimer() 
	{
		if (Model.demoMode || DefaultParameters.simulationMode)
		{
			strAlternateText = "";
			if(Model.demoMode ) strAlternateText 	= DBTranslations.getText("IDS_DEMO_MODE");
			if(DefaultParameters.simulationMode ) strAlternateText 	+= DBTranslations.getText("IDS_SIMULATION_MODE");
			bAlternate = !bAlternate;
			Timer.delay(onTimer, 2000);
		}

		textTitle.setTextolor(bAlternate ? ASColor.ALIZARIN.getRGB() : ASColor.MXT_BLUE.getRGB());
		textTitle.setHtmlTextAndSize(bAlternate ? strAlternateText : strTitle);
	}
}