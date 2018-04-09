package db;
#if neko
import sys.db.Object;
#end
import sys.db.Types.SId;

/**
 * ...
 * @author GM
 */
class ResObject #if neko extends Object #end

{
	public var ID :SId;
	public var Name	:String;
	public var IDS	:String;
	public var Parent:String;
	public var Number:Int;
	public var Model:String;
	public var Decorator:String;
	public var Template:String;
	public var URL:String;
	public var Link:String;
	public var X:Int;
	public var Y:Int;
	public var W:Int;
	public var H:Int;
	static var TABLE_NAME = "Pages";

	public function new(?ID:Int, ?IDS:String, ?Name:String, ?Parent:String, ?Number:Int, ?Model:String, ?Decorator:String, ?Template:String, ?URL:String, ?Link:String, ?X:Int, ?Y:Int, ?W:Int, ?H:Int) 
	{
		#if neko super(); #end

		this.ID = ID;
		this.IDS = IDS;
		this.Name = Name;
		this.Parent = Parent;
		this.Number = Number;
		this.Model	= Model;
		this.Decorator	= Decorator;
		this.Template	= Template;
		this.URL	= URL;
		this.Link	= Link;
		this.X = X;
		this.Y = Y;
		this.W = W;
		this.H = H;
	}

}