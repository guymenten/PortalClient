package tables;

import db.DBTranslations;
import org.aswing.table.PropertyTableModel;

/**
 * ...
 * @author GM
 */

class TableContacts extends Table
{
	public function new(name:String, wIn:Int, hIn:Int, func:Dynamic->Void)
	{
		super(name, 560, hIn, func);

		setDBTable(Model.dbContacts);

		model = new PropertyTableModel(
			listData,
			["V", DBTranslations.getText("IDS_NAME") , DBTranslations.getText("IDS_ORGANIZATION"), DBTranslations.getText("IDS_ADDRESS"), DBTranslations.getText("IDS_PHONE_NUMBER")],
			["select", "name", "org", "address","phone"],
			[null, null, null, null, null]); // no translators

		sortingColumn = 1;
		init();

		setColWidth(0, 20);	// Select
		setColWidth(1, 140);	// Name
		setColWidth(2, 100);	// Org
		setColWidth(3, 200);	// Address
		setColWidth(4, 100);	// Phone

		table.setSelectionMode(0); // One line selected
	}
}