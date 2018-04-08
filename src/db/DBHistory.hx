package db;

import data.DataObject;
import db.DBBase.DBCommand;
import flash.data.SQLResult;
import sys.db.Types.SId;
import util.DateUtil;

/**
 * ...
 * @author GM
 */
class HistoryTableData
{
	public var ID 		:SId;
	public var date		:Date;
	public var strDate	:String;
	public var strTime	:String;
	public var channel	:Int;
	public var noise	:Int;
	public var thr		:Int;
	public var min		:Int;
	public var max		:Int;
	public var busy		:Bool;
	public var report	:Bool;

	public function new(?noiseIn:Int, ?thrIn:Int, ?minIn:Int, ?maxIn:Int, ?timeIn:String)
	{
		noise = noiseIn;
		thr = thrIn;
		min = minIn;
		max = maxIn;
	}
}

/**
 * 
 */
class DBHistory extends DBRPMData
{
	public static var historyArray:Array<HistoryTableData> = new Array<HistoryTableData>();

	public function new()
	{
		super();

		tableName		= "History";
		timeFieldName	= "Time";
	}

	/**
	 * 
	 * @return
	 */
	public override function getRPMCommand():DBCommand
	{
		return DBCommand.COMMAND_HISTORY;
	}

	/**
	 * 
	 * @param	res
	 */
	public function fillHistoryTable(res:SQLResult)
	{
		onGetRecordsResult(res);
	}

	/**
	 * 
	 * @param	res
	 */
	override function onGetRecordsResult(res:SQLResult) 
	{
		historyArray.splice(0, historyArray.length); // Erase the Array
		var historyTableData:HistoryTableData;

		trace (res.data.length);
		if ((cast res) && cast (res.data))
		{
			for (dao in res.data)
			{
				historyTableData			= new HistoryTableData();
				historyTableData.channel 	= dao.Channel;
				historyTableData.noise 		= dao.Noise;
				historyTableData.thr 		= dao.Threshold;
				historyTableData.min 		= dao.Minimum;
				historyTableData.max 		= dao.Maximum;
				historyTableData.strDate 	= DateUtil.getStringDate(dao.Time);
				historyTableData.strTime	= DateUtil.getStringTime(dao.Time);
				historyTableData.date 		= DateUtil.getDate(dao.Time);
				historyArray.push(historyTableData);
			}
		}
	}

	/**
	 * 
	 */
	public function onNoiseComputed()
	{
		for (channel in Model.channelsArray) { addHistoryItem(channel); }
	}

	/**
	 * 
	 * @param	logData
	 */
	public function addHistoryItem(data:DataObject):Void
	{
		data.timeData = Date.now();

		var stat:String = "INSERT INTO History (Time, Noise, Threshold, Minimum, Maximum, Channel) VALUES ('"
			+ data.timeData + "',"
			+ data.noise + ","
			+ data.thresholdCalculated + ","
			+ data.minimum + ","
			+ data.maximum + ","
			+ data.channelIndex + ")";

		pushSQL(stat, null, onAddItemDone);
		recordsNumber ++;

		var historyTableData:HistoryTableData = new HistoryTableData(data.noise, data.thresholdCalculated, data.minimum, data.maximum, data.timeData.toString());
		historyTableData.channel = data.channelIndex;
		historyArray.push(historyTableData);
	}
	
	function onAddItemDone(res:SQLResult) 
	{
		trace("onAddIHistorytemDone()");
	}
}