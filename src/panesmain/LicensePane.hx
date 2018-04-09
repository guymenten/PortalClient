package panesmain ;

import comp.JButton2;
import comp.JTextTitleArea;
import data.ComputerIdChecking;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import hxtc.crypto.TEA;
import haxe.crypto.Md5;

/**
 * ...
 * @author GM
 */
class LicensePane extends SplashScreen
{
	public var onOKCallback:Void->Void;
	public var onCancelCallback:Void->Void;
	var taProductID:JTextTitleArea;
	var taComputerKey:JTextTitleArea;
	var taValidationKey:JTextTitleArea;
	var taDutyKey:JTextTitleArea;
	var butOK:JButton2;
	var butQuit:JButton2;
	var productID:String;
	var validityDate:Date;
	var computerKey:String;
	var dutyKey:String;
	var macAddress:String;
	public var computerIdChecking:ComputerIdChecking;
	public var onLicenseOKCallback:Void->Void;
	static public inline var IDSTRING:String = "mxt";

	public function new(parent:Sprite, cb:Void->Void) 
	{
		super();

		onOKCallback  		= cb;
		computerIdChecking 	= new ComputerIdChecking();
		var applicationDescriptor:String = NativeApplication.nativeApplication.applicationDescriptor.toString();
		productID = applicationDescriptor.substring(applicationDescriptor.indexOf("id>") + 3, applicationDescriptor.lastIndexOf("</id"));

		generateActivationkey();

		if (checkLicense())
		{
			onOKCallback();
		}
		else {
			createLicensePane();
		}
	}
//49741063586a50a7dc5094cbc337c4c9
	function generateActivationkey() 
	{
		for (dao in	computerIdChecking.computerMacAddresses)
		{
			macAddress 		= dao;
			computerKey 	= Md5.encode(macAddress);
			break;
		}
	}

	/**
	 * 
	 */
	function createLicensePane() 
	{
		visible 	= true;

		taProductID = new JTextTitleArea("");
		taProductID.setTitle("IDS_PRODUCT_ID");
		taProductID.setComBoundsXYWHTopAlign(60, 180, 180);
		taProductID.textArea.setEnabled(false);
		addChild(taProductID);

		taComputerKey = new JTextTitleArea("");
		taComputerKey.setTitle("IDS_COMPUTER_KEY");
		taComputerKey.setComBoundsXYWHTopAlign(280, 180, 300);
		addChild(taComputerKey);

		taValidationKey = new JTextTitleArea("");
		taValidationKey.setTitle("IDS_VALIDATION_KEY");
		taValidationKey.setComBoundsXYWHTopAlign(280, 240, 300);
		addChild(taValidationKey);

		taDutyKey = new JTextTitleArea("");
		taDutyKey.setTitle("IDS_DUTY_KEY");
		taDutyKey.setComBoundsXYWHTopAlign(280, 300, 120);
		addChild(taDutyKey);

		var y:Int = 370;

		butQuit = new JButton2(280, cast y, 100, 32, "IDS_BUT_QUIT", onButQuit);
		addChild(butQuit);

		butOK = new JButton2(cast Model.HEIGHT, cast y, 100, 32, "IDS_BUT_OK", onUserPaneOK);
		addChild(butOK);

		refresh();
	}

	/**
	 * 
	 */
	function refresh():Void 
	{
		taComputerKey.textArea.setText(computerKey);
		//taValidationKey.textArea.setText(DBDefaults.getStringParam(Parameters.paramProductID));
		taProductID.textArea.setText(productID);
	}

	/**
	 * 
	 * @param	e
	 */
	function onUserPaneOK(e:MouseEvent) 
	{
		var key:String = taValidationKey.textArea.getText();
		Model.dbDefaults.setStringParam(Parameters.paramProductID, key);

		if (checkLicense())
		{
			onOKCallback();
			visible = false;
		}
		else {
			Main.dialogWidget.setOKDialog(onClose, "IDS_MSG_DLG_INVALID_ERROR");
			Main.dialogWidget.setVisible(true);
		}
	}

	/**
	 * 
	 */
	function onClose() {
		Main.dialogWidget.setVisible(false);
	}

	/**
	 * 
	 */
	public function checkLicense() : Bool
	{
		return true;
		var key:String 		= DBDefaults.getStringParam(Parameters.paramProductID);
		var strKey:String 	= Md5.encode(computerKey + productID + IDSTRING);

		if (strKey == key)
			return true;
// 4d073c0f1b10e73af5883370f46d79ec
// 576fad3461da6c73e2415465b8afacbf
		return false;
		//return computerIdChecking.checkAllIDString();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButQuit(e:MouseEvent):Void 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_APP_EXIT));				
	}
}