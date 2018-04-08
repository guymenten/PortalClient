package panesmain ;

import comp.JButton2;
import comp.JComboBox1;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.NativeWindowInitOptions;
import flash.html.HTMLLoader;
import haxe.Timer;
import flash.display.NativeWindowSystemChrome;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import org.aswing.AWKeyboard;
import org.aswing.VectorListModel;
import org.aswing.event.SelectionEvent;
import util.Fading;
import widgets.WUsersDlg;
//import workers.WaitWorker;

/**
 * ...
 * @author GM
 */
class StartPane extends SplashScreen
{
	var aboutActive:Bool;
	var butDemoMode:JButton2;
	var butAck:JButton2;
	var butCancel:JButton2;
	var cbLanguage:JComboBox1;
	public static var vecLanguages:VectorListModel = new VectorListModel([]);
	//var spriteWait:WaitWorker;
	var W:Int = 120;
	var H:Int = 32;
	var X:Int = 0;
	var Y:Int = 374;

	/**
	 * 
	 */
	public function new() 
	{
		super();

		x = y = 0;
		createHTMLViewer();

		butDemoMode = new JButton2(260, Y,W, H, "IDS_BUT_DEMO", onDemoMode);
		addChild(butDemoMode);

		butCancel = new JButton2(500, Y, W, H, "IDS_BUT_LICENSE_CANCEL", onLicenceCancel);
		addChild(butCancel);

		butAck = new JButton2(640, Y, W, H, "IDS_BUT_LICENSE_ACK", onLicenceAck);
		addChild(butAck);

		cbLanguage = new JComboBox1("IDS_LANGUAGE");
		cbLanguage.setComBoundsXYWHTopAlign(20, Y, 120, 34);
		cbLanguage.combobox.addEventListener(SelectionEvent.LIST_SELECTION_CHANGED, onLanguageChange);
		addChild(cbLanguage);
		fillLanguageCB();

		Main.root1.addEventListener(PanelEvents.EVT_ABOUT, onAbout);
		Main.root1.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
	}

	/**
	 * 
	 * @param	key
	 */
	function onKeyboardEvent(key:KeyboardEvent) 
	{
		if (key.charCode == cast AWKeyboard.ENTER) onLicenceAck();
		else if (key.charCode == cast AWKeyboard.ESCAPE) onLicenceCancel();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onAbout(e:Event):Void 
	{
		if (!aboutActive)
		{
			aboutActive = true;
			parent.setChildIndex(this, parent.numChildren - 1);
			Fading.fadeIn(this, 1, 1);
		}
	}

	/**
	 * 
	 * @param	e
	 */
	function onDemoMode(e:MouseEvent) 
	{
		Model.demoMode = true;
		onLicenceAck();
	}

	/**
	 * 
	 */
	function createHTMLViewer():Void
	{
		var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
		initOptions.systemChrome 	= NativeWindowSystemChrome.NONE;
		var bounds:Rectangle 		= new Rectangle(10, 126, 794 * 1/scaleX , 220 * 1/scaleX); 
		var html2:HTMLLoader 		= HTMLLoader.createRootWindow(false, initOptions, true, bounds);
		html2.scaleX 				= scaleX;
		html2.scaleY 				= html2.scaleX;

		var urlReq2:URLRequest 		= new URLRequest("LicenseEN.html"); 
		html2.load(urlReq2);
		html2.x 					= 4;
		html2.y 					= 134;
		addChild(html2);
		html2.visible 				= true;
	}

	/**
	 * 
	 * @param	e
	 */
	function onLanguageChange(e:Event) 
	{
		DefaultParameters.language = cbLanguage.combobox.getSelectedIndex();
		Model.translations.getTranslations(cast DefaultParameters.language);
		butAck.setText(DBTranslations.getText("IDS_BUT_LICENSE_ACK"));
		butCancel.setText(DBTranslations.getText("IDS_BUT_LICENSE_CANCEL"));
		Model.dbDefaults.setIntParam(Parameters.paramLanguage, DefaultParameters.language);
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_LANGUAGE_CHANGE));		
	}

	/**
	 * 
	 */
	function fillLanguageCB() :Void
	{
		vecLanguages.append(DefaultParameters.getLanguage(0));
		vecLanguages.append(DefaultParameters.getLanguage(1));
		vecLanguages.append(DefaultParameters.getLanguage(2));
		vecLanguages.append(DefaultParameters.getLanguage(3));

		cbLanguage.combobox.setModel(vecLanguages);
		cbLanguage.combobox.setSelectedIndex(DBDefaults.getIntParam(Parameters.paramLanguage));
	}

	/**
	 * 
	 * @param	e
	 */
	private function onLicenceCancel(e:MouseEvent = null):Void
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_APP_EXIT));		
	}

	var userDlg:WUsersDlg;
	/**
	 *
	 * @param	e
	 */
	public function onLicenceAck(e:MouseEvent = null):Void
	{
		if (!aboutActive)
		{
			if (userDlg == null)
			{
				userDlg = new WUsersDlg(this, Main.widgetBig);
			}

			Model.dbDefaults.setIntParam(Parameters.paramEULA, 1);	

			userDlg.resetText();
			enableButtons(false);

			userDlg.setOKCancelDialog(onUserError, onUserOK, false);
			userDlg.setOKOnError( cast onLicenceAck);
			userDlg.setUserLoggingDialog();
			userDlg.setVisible(true);
		}

		aboutActive = false;
	}

	/**
	 * 
	 */
	function onUserError() 
	{
		userDlg.setVisible(false);
		enableButtons(true);
	}

	function enableButtons(e:Bool)
	{
		butDemoMode.setEnabled(e);
		butAck.setEnabled(e);
		butCancel.setEnabled(e);
	}

	/**
	 * 
	 */
	function onUserOK() 
	{
		userDlg.setVisible(false);
		//spriteWait = new WaitWorker();
		//spriteWait.x = x + width / 2;
		//spriteWait.y = y + height / 2;
		//initWorker();
		//addChild(spriteWait);
		Timer.delay(onStartPane, 500);
	}

	/**
	 * 
	 */
	function onStartPane() 
	{
		trace("!!!!!!!!!!!!!!!! onStartPane() !!!!!!!!!!!!!!!");
		Main.widgetBig.mainWindow.createMainWindow();
		//removeChild(spriteWait);
	}
}