package panesmain ;

import db.DBDefaults;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.Sprite;
import haxe.Timer;
import flash.display.Bitmap;
import util.Fading;
import util.Images;

/**
 * ...
 * @author GM
 */
class MainWindow extends Sprite
{
	public var startPane:StartPane;
	public var licensePane:LicensePane;
	public var mainPane:MainPane;

	var bmLogo:Bitmap;

	public function new() 
	{
		super();

		bmLogo = Images.resize(Images.loadMXT(), 300, 400, 120, 100);
		addChild(bmLogo);

		trace("MainWindow()");
		
		licensePane = new LicensePane(this, onLicenseOKCallback);
		addChild(licensePane);
		//Main.logConsole.setComBoundsXYWH(20, 20, 400, 300);

		//Main.logConsole.log("Creating MainWindow");

	}

	/**
	 * 
	 * @param	e
	 */
	private function onLicenseOKCallback():Void 
	{
		if (!DefaultParameters.paramEULA)
		{
			startPane 		= new StartPane();
			addChild(startPane);
			startPane.setVisible(true);
		}
		else		
			createMainWindow();


		if (DBDefaults.getIntParam(Parameters.paramAutoLogon) == 1)
			createMainWindow();
	}

	/**
	 * 
	 */
	public function createMainWindow():Void 
	{
		Main.createMain();
	
		if (cast startPane)
			startPane.setVisible(false);

		mainPane 			= new MainPane();
		addChild(mainPane);
		mainPane.setVisible(true);
		Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_USER_LOGGING, Model.getCurrentUserName()));
		//Fading.fadeOut(bmLogo, 0, 2);
		bmLogo.visible = false;
		//Fading.fadeOut(Main.logConsole, 0, 2);
		
		
		///////////////////////
		Main.controller.init();
		///////////////////////
	}
}