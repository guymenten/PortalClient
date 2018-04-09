package tabsdb ;

import comp.JTextTitleArea;
import db.DBContacts.Contact;
import flash.data.SQLResult;
import flash.events.KeyboardEvent;
import org.aswing.util.CompUtils;
import tables.TableContacts;
import tabssettings.SetBase;
import tools.ToolSQL;
import tools.ToolSQLContacts;

/**
 * ...
 * @author GM
 */
class TabContacts extends TabSQL
{
	var contactsTable		:TableContacts;
	var taName:JTextTitleArea;
	var taOrg:JTextTitleArea;
	var taAddress:JTextTitleArea;
	var taPhone:JTextTitleArea;
	var bValuesModified:Bool;
	var toolSQLContacts:ToolSQL;

	public function new() 
	{
		super();

		contactsTable = new TableContacts("ID_CONTACTS_TABLE", 540, 362, null);
		addChild(contactsTable);

		toolSQL = new ToolSQLContacts("ID_SQL_CONTACT", onApplyFilters);
		toolSQL.setTable(contactsTable);
		toolSQL.init();
		addChild(toolSQL);

		taName 		= CompUtils.addTextTitleArea(this, "IDS_NAME",			SetBase.x5, SetBase.y1, taNameListener);
		taOrg 		= CompUtils.addTextTitleArea(this, "IDS_ORGANIZATION",	SetBase.x5, SetBase.y2, taOrgListener);
		taAddress 	= CompUtils.addTextTitleArea(this, "IDS_ADDRESS",		SetBase.x5, SetBase.y3, taAddressListener);
		taPhone 	= CompUtils.addTextTitleArea(this, "IDS_PHONE_NUMBER",	SetBase.x5, SetBase.y4, taPhoneListener);

		taName.setPreviousNextControl(taPhone, taOrg);
		taOrg.setPreviousNextControl(taName, taAddress);
		taAddress.setPreviousNextControl(taOrg, taPhone);
		taPhone.setPreviousNextControl(taAddress, taName);

		contactsTable.selectionFunc = onTableSelection;
	}

	function onTableSelection(c:Contact) :Void
	{
		taName.textArea.setText(c.name);
		taOrg.textArea.setText(c.org);
		taAddress.textArea.setText(c.address);
		taPhone.textArea.setText(c.phone);
	}

	function taPhoneListener(key:KeyboardEvent) :Void
	{
		contactsTable.bFieldModified = true;
	}
	
	function taAddressListener(key:KeyboardEvent) :Void
	{
		contactsTable.bFieldModified = true;
	}
	
	function taOrgListener(key:KeyboardEvent) :Void
	{
		contactsTable.bFieldModified = true;

	}
	
	function taNameListener(key:KeyboardEvent) :Void
	{
		contactsTable.bFieldModified = true;

	}

	/**
	 * 
	 * @param	vis
	 */
	public override function setVisible(vis:Bool)
	{
		super.setVisible(vis);

		if (vis)
		{
			if (!initialized)
			{
				Model.dbContacts.getRecordsCount();
				initialized = true;
			}

		}
	}

	/**
	 * 
	 */
	function onApplyFilters(res:SQLResult):Void
	{
		if (res == null)
		{
			contactsTable.dbTable.getFilteredData(onGetResult);
		}
		//contactsTable.refreshList(res, toolSQL.getTextSQL(), toolSQL.getIconSQL());
	}

	/**
	 * 
	 * @param	res
	 */
	function onGetResult(res:SQLResult) :Void
	{
		contactsTable.refreshList(res);
	}

}