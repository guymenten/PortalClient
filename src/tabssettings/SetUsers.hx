package tabssettings ;

import comp.JComboBox1;
import comp.JTextTitleArea;
import db.DBUsers;
import events.PanelEvents;
import flash.events.Event;
import flash.events.MouseEvent;
import org.aswing.BorderLayout;
import org.aswing.VectorListModel;
import org.aswing.event.InteractiveEvent;
import util.Images;
import widgets.WUsersDlg;

/**
 * ...
 * @author GM
 */
class SetUsers extends SetBase
{
	var taName:JTextTitleArea;
	var taPass:JTextTitleArea;
	var cbUsers	:JComboBox1;
	var strUser:String;
	var vecUsers:VectorListModel;
	var userDlg:WUsersDlg;

	/**
	 * 
	 */
	public function new() 
	{
		super(new BorderLayout(0, 0));
	}

	/**
	 * 
	 */
	private override function init():Void
	{
		super.init();
		var x:Int = 20;
		var y:Int = 60;

		taName = new JTextTitleArea("IDS_NAME");
		taName.setComBoundsXYWHTopAlign(SetBase.x2, SetBase.y2, 180);
		addChild(taName);

		taPass = new JTextTitleArea("IDS_BUT_PASSWORD");
		taPass.setComBoundsXYWHTopAlign(SetBase.x2, SetBase.y3, 180);
		taPass.textArea.setText("**********");
		addChild(taPass);

		cbUsers = new JComboBox1("IDS_BUT_USER", Images.loadUser(true));
		cbUsers.setComBoundsXYWHTopAlign(SetBase.x2, SetBase.y1, 120);
		addChild(cbUsers);
		cbUsers.combobox.addEventListener(InteractiveEvent.SELECTION_CHANGED, onUsercbChange);
		fillUsersCB();

		taName.addEventListener(MouseEvent.CLICK, onAddNewUser);
		taPass.addEventListener(MouseEvent.CLICK, onPasswordChange);
		//addEventListener(KeyboardEvent.KEY_DOWN, changeFocus);
		Main.root1.addEventListener(PanelEvents.EVT_USER_LOGGING, onUserLogging);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onUserLogging(e:Event):Void 
	{
		cbUsers.combobox.setSelectedItem(Model.getCurrentUserName());
		onUsercbChange();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onAddNewUser(e:MouseEvent):Void 
	{
		createUserPasswordDialog(onUserError, onUserdOK, false);
	}

	/**
	 * 
	 */
	function onPasswordChange(e:MouseEvent):Void
	{
		createUserPasswordDialog(onPasswordError, onPasswordOK, true);
	}

	/**
	 * 
	 * @param	passw
	 */
	function createUserPasswordDialog(onLeftIn:Void->Void, onRightIn:Void->Void, passw:Bool) 
	{
		if (userDlg == null)
			userDlg = new WUsersDlg(this, Main.widgetBig);

		userDlg.resetText();

		userDlg.setOKCancelDialog(onLeftIn, onRightIn, false);
		userDlg.setOKOnError( cast onOKOnError);
		passw ? userDlg.setPasswordChangeDialog(taName.textArea.getText()) : userDlg.setUserLoggingDialog();
		userDlg.setVisible(true);			
	}

	/**
	 * 
	 */
	function onUserdOK() 
	{
		
	}
	
	function onUserError() 
	{
		
	}

	/**
	 * 
	 */
	function onPasswordOK() 
	{
		
	}
	
	function onPasswordError() 
	{
		
	}

	function onOKOnError() 
	{
		
	}

	/**
	 * 
	 * @param	e
	 */
	private function onUsercbChange(e:Event = null):Void 
	{
		strUser = cbUsers.combobox.getSelectedItem();
		taName.textArea.setText(strUser);
		//taName.textArea.makeFocus();
	}

	/**
	 * 
	 */
	function fillUsersCB() 
	{
		vecUsers = new VectorListModel([]);
		
		for (dao in DBUsers.UsersMap)
		{
			vecUsers.append(dao.name);
		}

		cbUsers.combobox.setModel(vecUsers);
		cbUsers.combobox.setSelectedItem(Model.getCurrentUserName());
		onUsercbChange();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onbutQuit(e:MouseEvent):Void 
	{
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButOK(e:MouseEvent):Void 
	{
	}
}