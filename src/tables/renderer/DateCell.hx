package tables.renderer;

import org.aswing.ASFont;
import org.aswing.table.DefaultTextCell;
import util.DateFormat;

/**
 * 
 */
class DateCell extends DefaultTextCell{
	
	public function new()
	{
		super();
	}

	override public function setCellValue(value:Dynamic) : Void
	{
		if (cast value) {
			setText(DateFormat.getDateString(value));
		}
	}
}

/**
 * 
 */
class TimeCell extends DefaultTextCell{
	
	public function new()
	{
		super();
	}

	override public function setCellValue(value:Dynamic) : Void
	{
		setText(DateFormat.getTimeString(value));
	}
}

/**
 * 
 */
class DutyCell extends DefaultTextCell{
	
	public function new()
	{
		super();

	}

	override public function setCellValue(value:Dynamic) : Void
	{
		var val:Int = cast value;
		setText(cast val);
	}
}

/**
 * 
 */
class ReportCell extends DefaultTextCell{
	var gfont:ASFont;
	
	public function new()
	{
		gfont = new ASFont("Arial", 8, true, true, true);
		super();
	}

	override public function setCellValue(value:Dynamic) : Void
	{
		var val:Int = cast value;
		if(val == 5885)
			setFont(gfont);
		setText(cast val);
	}
}