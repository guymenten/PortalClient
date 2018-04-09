package tables.renderer;

import icon.IconFromBm;
import org.aswing.Icon;
import org.aswing.table.DefaultTextCell;
import util.Images;

/**
 * 
 */
class SelectionCell extends DefaultTextCell{
	
	var iconsArray:Array<Icon>;

	public function new()
	{
		super();

		iconsArray = new Array<Icon>();
		var dS:Int = 18;
		iconsArray.push(new IconFromBm(Images.loadCheckBoxOff(), dS, dS));
		iconsArray.push(new IconFromBm(Images.loadCheckBoxOn(), dS, dS));
	}

	/**
	 * 
	 * @param	index
	 */
	override public function setCellValue(index:Dynamic) : Void
	{
		//trace(index);
		setIcon(iconsArray[cast index]);
		setComBoundsXYWH(8, 0, 32, 32);
	}
}

/**
 * 
 */
class RAIconCell extends DefaultTextCell{
	
	var iconsArray:Array<Icon>;

	public function new()
	{
		super();
		
		iconsArray = new Array<Icon>();
		var dS:Int = 18;
		iconsArray.push(new IconFromBm(Images.loadLEDRepNonOK(), dS, dS));
		iconsArray.push(new IconFromBm(Images.loadLEDRAOff(), dS, dS));
		iconsArray.push(new IconFromBm(Images.loadLEDRAOn(), dS, dS));
		iconsArray.push(new IconFromBm(Images.loadLEDRAOn(), dS, dS));
	}

	/**
	 * 
	 * @param	index
	 */
	override public function setCellValue(index:Dynamic) : Void
	{
		setIcon(iconsArray[cast index + 1]);
		setComBoundsXYWH(8, 0, 32, 32);
	}
}