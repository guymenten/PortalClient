package db;


import flash.data.SQLResult;
import org.aswing.util.HashMap;
import sys.db.Types;
import flash.filesystem.File;
import flash.utils.Object;
import util.DateUtil;

/**
 * ...
 * @author GM
 */
class ReportFormat
{
	public var ID:Int;
	public var name:String;
	public var label:String;
	public var X:Int;
	public var Y:Int;
	public var align:String;
	public var scale:Float;
	public var alpha:Float;
	public var width:Int;
	public var height:Int;
	public var size:Int;
	public var bold:Bool;
	public var italic:Bool;
	public var underline:Bool;
	public var color:Int;

	public function new(

		ID 				= 1,
		name:String 	= " ",
		label:String 	= " ",
		X:Int 			= 0,
		Y:Int 			= 0,
		align:String 	= "Left",
		scale:Float		= 0,
		alpha:Float		= 1,
		width:Int 		= 0,
		height:Int 		= 0,
		size:Int 		= 12,
		bold:Bool		= false,
		italic:Bool		= false,
		underline:Bool	= false,
		color:Int		= 0)

	{
		this.ID 		= ID;
		this.name 		= name;
		this.label 		= label;
		this.X 			= X;
		this.Y 			= Y;
		this.align		= align;
		this.scale 		= scale;
		this.alpha 		= alpha;
		this.height 	= height;
		this.width 		= width;
		this.italic 	= italic;
		this.size 		= size;
		this.bold 		= bold;
		this.italic 	= italic;
		this.underline 	= underline;
		this.color 		= color;
	}
}

/**
 * 
 */
class DBReportFormat extends DBBase
{
	public var reportFormatArray:Map<String, ReportFormat>;

	public function new():Void 
	{
		fName 		= DBBase.getConfigDataName();
		tableName	= "ReportFormat";

		super(true);
 	}

	/**
	 *
	 * @param	lang
	 */
	public override function getFilteredData(?conditions:String = "", ?getResult:SQLResult->Void, ?fromTime:Bool = false):Int
	{
		reportFormatArray 		= new Map <String, ReportFormat> ();

		//dbStatement.itemClass 	= ReportFormat;
		super.getFilteredData(conditions);

		if(super.getFilteredData(conditions) > 0){
		
			for (data in sqlResult.data)
			{
				reportFormatArray.set(data.name, new ReportFormat(data.ID, data.name, data.label, data.X, data.Y,
				data.align, data.scale, data.alpha, data.width, data.height, data.size, data.bold, data.italic, data.color));
			}
		}
		return sqlResult.data.length;
 	}
}
