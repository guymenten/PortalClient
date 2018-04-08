package widgets;

import comp.JTextTitleArea;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import org.aswing.ASColor;
import org.aswing.AWKeyboard;

/**
 * ...
 * @author GM
 */
class WSearchDlg extends WDialog
{
	var taUp			:JTextTitleArea;

	public function new(comp:Sprite, parent:Sprite) 
	{
		super(comp, parent);

		taUp 	= new JTextTitleArea();

		taUp.setComBoundsXYWHTopAlign	(80, 70, 180);
		taUp.tfTitle.setForeground(ASColor.BLACK);

		addChild(taUp);

		Main.root1.addEventListener(PanelEvents.EVT_SQL_SEARCH_DLG, onSearch);

		onSearch();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onSearch(e:Event = null):Void 
	{
		taUp.setTitle("IDS_REPORT");
		setOKCancelDialog(onCancel, onOK, "");
		resetText();
		setVisible(true);
	}


	/**
	 * 
	 */
	public function resetText():Void
	{
		taUp.textArea.setText("");
		taUp.textArea.makeFocus();
	}

	/**
	 * 
	 * @param	e
	 */
	function onOK() 
	{
		Main.root1.dispatchEvent(new TextEvent(PanelEvents.EVT_SQL_SEARCH, false, false, taUp.textArea.getText()));
	}
	
	/**
	 * 
	 * @param	e
	 */
	function onCancel() 
	{
	}
}