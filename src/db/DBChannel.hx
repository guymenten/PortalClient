package db;

import data.DataObject;
import db.DBBase.DBCommand;
import db.DBConfigChannels.ChannelData;
import flash.data.SQLResult;

/**
 * ...
 * @author GM
 */

class ChannelArray
{
	public var index:			Int;
	public var channelArray:	Array<ChannelData>;
	var datareportObject:		DataObject;

	public function new(indexIn:Int)
	{
		index 			= indexIn;
		channelArray 	= new Array <ChannelData> ();
	}
}

/**
 * 
 */
class DBChannels extends DBRPMData
{
	public static var arrayGetChannelData 	= new Array<ChannelData>();
	public static var DBChannelDataArray 	= new Array <ChannelArray> ();
	var channelData:ChannelData;

	public function new():Void 
	{
		tableName 	= "Channel";

		super();

		for (chan in Model.channelsArray)
		{
			var chanArray = new ChannelArray(chan.channelIndex);
			DBChannels.DBChannelDataArray.push(chanArray);
		}		
	}

	/**
	 * 
	 * @return
	 */
	public override function getRPMCommand():DBCommand
	{
		return DBCommand.COMMAND_CHANNEL;
	}

	/**
	 * 
	 * @param	channel
	 * @param	date
	 */
	public static function getChannelDataFromDate (channel:Int, date:Date):Void
	{
		DBChannelDataArray.splice(0, DBChannelDataArray.length); // Erase the Array
	}

	/**
	 * 
	 * @param	channel
	 * @param	reportNumber
	 */
	public function getChannelData (channel:Int, reportNumber:Int, ?func:Dynamic->Void):DataObject
	{
		#if sqlite
		dbStatement.text 		= "SELECT * FROM " + tableName + channel + " WHERE ReportNumber = '" + reportNumber + "'";
		dbStatement.execute();
		var sqlResult:SQLResult = dbStatement.getResult();
		arrayGetChannelData.splice(0, arrayGetChannelData.length); // Erase the Data Array

		var dataReportObject 							= new DataObject();

		if (sqlResult.data != null)
		{
			//trace("Lenght : " + sqlResult.data.length);

			var deviation:Int = 0;

			for (data in sqlResult.data)
			{
				channelData 							= new ChannelData();

				channelData.counter 					= data.Data;
				channelData.status 						= data.Status;
				channelData.reportNumber 				= data.ReportNumber;
				channelData.noise 						= data.Noise;
				channelData.threshold 					= data.Threshold;
				channelData.thresholdCalculated 		= data.Threshold;
				channelData.radioActivity 				= data.Radioactivity;
				channelData.time 						= data.Time;
				deviation								= data.Deviation;

				arrayGetChannelData.push(channelData); // Slow
				dataReportObject.pushCurrentData(channelData);
			}

			dataReportObject.calculateAverageAndVariance(0, true);
			dataReportObject.counter				= channelData.counterF ;
			dataReportObject.noise					= channelData.noise;
			dataReportObject.threshold				= channelData.threshold;
			dataReportObject.thresholdCalculated	= channelData.thresholdCalculated;
			dataReportObject.channelIndex 			= channelData.channelIndex;
			dataReportObject.deviation 				= deviation;
			dataReportObject.onElapsedBKGMeasurement(true);

		}
		
		return dataReportObject;
		
		#else
		cnx.dbTranslations.getChannelData.call([channel, reportNumber], func);
		#end
		
		return null;
 	}
	
	/**
	 * 
	 */
	function onGetChannelData(channelData:ChannelData) 
	{
		
	}

	/**
	 * 
	 * @param	dataArray
	 * @param	channelIndex
	 * @param	start
	 * @return
	 */
	public function saveReportData(dataArray:Array<ChannelData>, channelIndex:Int, start:Int):Bool
	{
		var ra:Bool = false;

		trace("saveReportData, start  : " + start);
		trace("saveReportData, end    : " + dataArray.length);

		for (index in start ... dataArray.length)
		{
			updateChannelData(channelIndex, dataArray[index]);

			if (cast dataArray[index].radioActivity)
				ra = true;
		}

		return ra;
	}

	/**
	 * 
	 * @param	channel
	 * @param	channelData
	 */
	public function updateChannelData(channel:Int, channelData:ChannelData):Void
	{
		var deviation:Int = cast channelData.deviation;

		var stat:String = "INSERT INTO " + tableName + channel  + "(Time, Data, Status, ReportNumber, Noise, Threshold, Radioactivity, Deviation) VALUES ('"
			+ channelData.time + "',"
			+ channelData.counter + ","
			+ channelData.status + ","
			+ channelData.reportNumber + ","
			+ channelData.noise + ","
			+ channelData.thresholdCalculated + ","
			+ channelData.radioActivity + ","
			+ deviation + ")";

		pushSQL(stat, null, null);
		//dbStatement.execute();
	}
}