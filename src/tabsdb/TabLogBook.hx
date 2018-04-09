package tabsdb ;

import db.DBTranslations;
import flash.data.SQLResult;
import tables.TableLogBook;
import tools.ToolSQLog.ToolSQLLog;

/**
 * ...
 * @author GM
 */
class TabLogBook extends TabSQL
{
	var logBookTable		:TableLogBook;

	public function new()
	{
		super();

		logBookTable = new TableLogBook("ID_LOGBOOK_TABLE", 640, 349);

		addChild(logBookTable);

		toolSQL = new ToolSQLLog("ID_PLOT_TOOL_LOG", onApplyFilters);
		toolSQL.setTable(logBookTable);
		addChild(toolSQL);
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
				Model.dbLog.getRecordsCount();
				initialized = true;
			}
			//else
				//plotStatistics.update();
		}
	}

	/**
	 * 
	 */
	function onApplyFilters(res:SQLResult):Void
	{
		logBookTable.refreshList(res, toolSQL.getTextSQL(), toolSQL.getIconSQL());
	}

	/**
	 * 
	 * @return
	 */
	public function getTitleText():String
	{
		return DBTranslations.getText("IDS_BUT_LOGBOOK");
	}
}