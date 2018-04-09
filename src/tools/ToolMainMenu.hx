package tools;

import events.PanelEvents;
import flash.events.Event;
import flash.events.MouseEvent;
import format.agal.Tools;
import icon.IconFromBm;
import org.aswing.ASColor;
import org.aswing.AsWingConstants;
import org.aswing.AsWingManager;
import org.aswing.BorderLayout;
import org.aswing.JButton;
import org.aswing.JFrame;
import org.aswing.JLabel;
import org.aswing.JToolBar;
import tools.WTools.ToolButton;
import util.Images;
import widgets.WBase;
import widgets.WUsersDlg;

/**
 * ...
 * @author GM
 */

class ToolMainMenu extends WBase
{
	var userDlg			:WUsersDlg;
	var labelUser		:JLabel;
	var butUser			:ToolButton;
	var butTest			:ToolButton;
	var butExit			:ToolButton;
	var toolBar			:JToolBar;
	
	public function new(name:String) 
	{
		super(name);
	
		toolBar = new JToolBar(JToolBar.VERTICAL, gap);

		labelUser 			= new JLabel("Test");
		labelUser.mouseEnabled = false;
		labelUser.setFont(labelUser.getFont().changeSize(9));
		labelUser.set_foreground(ASColor.CLOUDS);
		labelUser.setComBoundsXYWH( -4, 30, 40, 12);
		//
		butUser = new ToolButton("ID_USER", "", "IDS_TT_MENU_USER", Images.loadUser(false), onButUser);
		toolBar.append(butUser);
	
		butTest = new ToolButton("ID_TEST", "", "IDS_TT_MENU_TEST", Images.loadTest(false), onButTestOn);
		butTest.y += toolBar.gap;
		toolBar.append(butTest);
	
		butExit = new ToolButton("ID_EXIT", "", "IDS_TT_MENU_EXIT", Images.loadExit(), onButQuit);
		butExit.y += toolBar.gap*2;
		toolBar.append(butExit);
		
		addChild(toolBar);
		addChild(labelUser);

		Main.root1.addEventListener(PanelEvents.EVT_USER_LOGGING, onUserLogging);
	}

	private function onUserLogging(e:Event):Void 
	{
		labelUser.setText(Model.getCurrentUserName());
		//getButton("ID_USER").setIcon(Images.loadUser());
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButQuit(e:MouseEvent):Void 
	{
		Main.dialogWidget.setYesNoDialog(onClose, onQuitCallback, "IDS_MSG_DLG_EXIT", "IDS_NO", "IDS_YES");
		Main.dialogWidget.setVisible(true);
	}

	/**
	 * 
	 */
	function onQuitCallback() 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_APP_EXIT));				
	}

	/**
	 * 
	 */
	function onClose() 
	{
		Main.dialogWidget.setVisible(false);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButUser(e:MouseEvent):Void 
	{
		if (userDlg == null)
		{
			userDlg = new WUsersDlg(Main.widgetBig.mainWindow, Main.widgetBig);
		}

		userDlg.resetText();
		userDlg.setUserLoggingDialog();
		userDlg.setOKCancelDialog("");
	}

	/**
	 * 
	 * @param	e
	 */
	private function onButTestOn(e:MouseEvent):Void 
	{
		Model.bTestMode = !Model.bTestMode;
		Main.root1.dispatchEvent(new StateMachineEvent()); // 0 for all channels		return true;
		Main.model.testMode = true;
	}
}