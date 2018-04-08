package widgets;

import comp.JTextTitleArea;
import db.DBDefaults;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import org.aswing.ASColor;
import org.aswing.AWKeyboard;

enum UserMode
{
	LOGIN;
	UPDATE;
	CREATE;
}

/**
 * ...
 * @author GM
 */
class WUsersDlg extends WDialog
{
	var taUp			:JTextTitleArea;
	var taDown			:JTextTitleArea;
	var passwordChange	:Bool;
	var userMode		:UserMode;
	var userName		:String;

	public function new(comp:Sprite, parent:Sprite) 
	{
		super(comp, parent);

		taUp 	= new JTextTitleArea();
		taDown 	= new JTextTitleArea();

		taUp.setComBoundsXYWHTopAlign	(80, 70, 180);
		taDown.setComBoundsXYWHTopAlign	(80, 130, 180);
		
		taUp.tfTitle.setForeground(ASColor.BLACK);
		taDown.tfTitle.setForeground(ASColor.BLACK);
		
		addChild(taUp);
		taUp.textArea.setText(DBDefaults.getStringParam(Parameters.paramLastUser));

		addChild(taDown);
		addEventListener(KeyboardEvent.KEY_DOWN, changeFocus);
		Main.root1.addEventListener(PanelEvents.EVT_LANGUAGE_CHANGE, onLanguageChange);

		onLanguageChange();
	}

	/**
	 * 
	 */
	public function setUserLoggingDialog():Void 
	{
		userMode = UserMode.LOGIN;

		if (cast taUp)
		{
			taUp.setTitle( "IDS_BUT_USER");
			taDown.setTitle( "IDS_BUT_PASSWORD");
			taUp.textArea.getTextField().displayAsPassword 		= false;
			taDown.textArea.getTextField().displayAsPassword 	= true;
		}
	}

	/**
	 * 
	 */
	public function setPasswordChangeDialog(userName:String):Void 
	{
		this.userName = userName;
		userMode = UserMode.UPDATE;

		if (cast taUp)
		{
			taUp.setTitle( "IDS_BUT_OLD_PASSWORD");
			taDown.setTitle( "IDS_BUT_NEW_PASSWORD");
			taUp.textArea.getTextField().displayAsPassword 		= true;
			taDown.textArea.getTextField().displayAsPassword 	= true;
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private override function onLanguageChange(e:Event = null):Void 
	{
		super.onLanguageChange(e);
	
		if (cast taUp)
		{
			taUp.setTitle("IDS_BUT_USER");
			taDown.setTitle("IDS_BUT_PASSWORD");
			taUp.textArea.getTextField().displayAsPassword 		= true;
			taDown.textArea.getTextField().displayAsPassword 	= true;
		}
	}

	/**
	 * 
	 * @param	onUserError
	 */
	public function setOKOnError(onUserError:Void->Void) 
	{
		onOkOnError = onUserError;
	}

	/**
	 * 
	 * @param	key
	 */
	private function changeFocus(key:KeyboardEvent):Void 
	{
		if(key.charCode == cast AWKeyboard.TAB)
			taDown.textArea.isFocusOwner() ? taUp.textArea.makeFocus() : taDown.textArea.makeFocus();

		if (key.charCode == cast AWKeyboard.ENTER)
			onButRight();
	}

	/**
	 * 
	 */
	function setErrorMessage(msg:String):Void
	{
		taUp.visible = taDown.visible = false;
		labelMessage.visible = true;
		setOKDialog(onOK, msg);
	}

	/**
	 * 
	 */
	public function resetText():Void
	{
		taUp.textArea.setText("");
		taDown.textArea.setText("");
		taUp.textArea.makeFocus();
	}

	/**
	 * 
	 */
	function onOK() 
	{
		labelMessage.visible = false;
		taUp.visible = taDown.visible = true;

		if (cast onOkOnError)
			onOkOnError();
		else
			setVisible(false);
	}

	/**
	 * 
	 * @param	e
	 */
	override function onButRight(e:Event = null) 
	{
		switch(userMode)
		{
			case UserMode.LOGIN:

				if (!Model.tableUsers.checkNamePasswordOK(taUp.textArea.getText(), taDown.textArea.getText()))
					setErrorMessage(Model.tableUsers.getErrorMessage());
				else
				{
					Model.dbDefaults.setStringParam(Parameters.paramLastUser, taUp.textArea.getText());
					onRightButPnt();
				}

			case UserMode.UPDATE:

				if (!Model.tableUsers.checkNamePasswordOK(userName, taUp.textArea.getText()))
				{
					setErrorMessage(Model.tableUsers.getErrorMessage());
				}
				else{
					Model.tableUsers.updatePassword(userName, taDown.textArea.getText());
					onClose();
				}

			case UserMode.CREATE:
		}
	}
}