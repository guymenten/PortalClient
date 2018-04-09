package tabssettings ;

import comp.JComboBox1;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.events.Event;
import flash.printing.PrintJob;
import org.aswing.BorderLayout;
import org.aswing.event.AWEvent;
import org.aswing.geom.IntRectangle;
import org.aswing.JCheckBox;
import org.aswing.JLabel;
import org.aswing.LayoutManager;
import org.aswing.util.CompUtils;
import org.aswing.VectorListModel;
import util.Images;

/**
 * ...
 * @author GM
 */
class SetPrinters extends SetBase
{
	var chkAutoPrt1Pos	:JCheckBox;
	var chkAutoPrt1Neg	:JCheckBox;
	var chkAutoPrt2Pos	:JCheckBox;
	var chkAutoPrt2Neg	:JCheckBox;
	var cbPrinters1		:JComboBox1;
	var cbPrinters2		:JComboBox1;
	var chkSavePDF		:JCheckBox;
	var vecComName		:VectorListModel;
	var bValuesModified	:Bool;
	var txtDefPrinter	:JLabel;

	/**
	 * 
	 * @param	layout
	 */
	public function new(?layout:LayoutManager=null) 
	{
		super(new BorderLayout(0, 0));
	}

	/**
	 * 
	 */
	private override function init():Void
	{
		super.init();

		Main.root1.addEventListener(PanelEvents.EVT_PANE_MONITOR, OnUpdateValues);

		txtDefPrinter 		= new JLabel();
		txtDefPrinter.setComBounds(new IntRectangle(SetBase.x1, SetBase.y1,  200, 16));
		txtDefPrinter.setText(DBTranslations.getText("IDS_DEFAULT_PRINTER"));
		addChild(txtDefPrinter);

		chkAutoPrt1Pos 	= CompUtils.addCheckBox(this, "IDS_CHK_AUTOPRINT_POS_REPORT", SetBase.x1, SetBase.y3 - 10, onchkAutoPrt1Pos);
		chkAutoPrt1Neg 	= CompUtils.addCheckBox(this, "IDS_CHK_AUTOPRINT_NEG_REPORT", SetBase.x1, SetBase.y4 - 10, 320, onchkAutoPrt1Neg);
		chkAutoPrt2Pos 	= CompUtils.addCheckBox(this, "IDS_CHK_AUTOPRINT_POS_REPORT", SetBase.x4, SetBase.y3 - 10, 320, onchkAutoPrt1Neg);
		chkAutoPrt2Neg 	= CompUtils.addCheckBox(this, "IDS_CHK_AUTOPRINT_NEG_REPORT", SetBase.x4, SetBase.y4 - 10, 320, onchkAutoPrt2Pos);

		cbPrinters1 	= CompUtils.addComboBox(this, "", Images.loadPrinter(false), SetBase.x1 + 32, SetBase.y2 - 10, 260, onPrinterName1Change);
		cbPrinters2 	= CompUtils.addComboBox(this, "", Images.loadPrinter(false), SetBase.x4 + 32, SetBase.y2 - 10, 260, onPrinterName2Change);
	
		chkSavePDF 		= CompUtils.addCheckBox(this, "IDS_SAVE_PDF_REPORT", SetBase.x1 + 32, SetBase.y5 - 10, 260, onSavePDF);

		fillPrintersNameCB();
	}

	/**
	 * 
	 * @param	e
	 */
	function onSavePDF(e:Dynamic) 
	{
		Model.dbDefaults.setIntParam(Parameters.paramAutoPDFReport, cast chkSavePDF.isSelected(), true);				
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnUpdateValues(e:Event):Void 
	{
		if (bValuesModified)
		{
			bValuesModified = false;
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkAutoPrt1Pos(e:AWEvent):Void 
	{
		Model.dbDefaults.setIntParam(Parameters.paramAutoPrintReportPosPrt1, cast chkAutoPrt1Pos.isSelected(), true);				
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkAutoPrt1Neg(e:AWEvent):Void 
	{
		Model.dbDefaults.setIntParam(Parameters.paramAutoPrintReportNegPrt1, cast chkAutoPrt1Neg.isSelected(), true);				
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkAutoPrt2Pos(e:AWEvent):Void 
	{
		Model.dbDefaults.setIntParam(Parameters.paramAutoPrintReportPosPrt2, cast chkAutoPrt2Pos.isSelected(), true);				
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkAutoPrt2Neg(e:AWEvent):Void 
	{
		Model.dbDefaults.setIntParam(Parameters.paramAutoPrintReportNegPrt2, cast chkAutoPrt2Neg.isSelected(), true);				
	}

	/**
	 * 
	 */
	function fillPrintersNameCB() 
	{
		vecComName = new VectorListModel([]);

		for (dao in PrintJob.printers)
		{
			vecComName.append(dao);
		}

		cbPrinters1.combobox.setModel(vecComName);
		cbPrinters2.combobox.setModel(vecComName);

		var strPrinter:String = DBDefaults.getStringParam(Parameters.paramPrinterName1);
		cbPrinters1.combobox.setSelectedItem(strPrinter);

		strPrinter = DBDefaults.getStringParam(Parameters.paramPrinterName2);
		cbPrinters2.combobox.setSelectedItem(strPrinter);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPrinterName1Change(e:String):Void 
	{
		var strCom:String = cbPrinters1.combobox.getSelectedItem();
		Model.dbDefaults.setStringParam(Parameters.paramPrinterName1, strCom);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPrinterName2Change(e:String):Void 
	{
		var strCom:String = cbPrinters2.combobox.getSelectedItem();
		Model.dbDefaults.setStringParam(Parameters.paramPrinterName2, strCom);
	}

	/**
	 * 
	 */
	override function refresh(): Void
	{
		chkAutoPrt1Pos.setSelected(cast DBDefaults.getIntParam(Parameters.paramAutoPrintReportPosPrt1));
		chkAutoPrt2Pos.setSelected(cast DBDefaults.getIntParam(Parameters.paramAutoPrintReportPosPrt2));
		chkAutoPrt1Neg.setSelected(cast DBDefaults.getIntParam(Parameters.paramAutoPrintReportNegPrt1));
		chkAutoPrt2Neg.setSelected(cast DBDefaults.getIntParam(Parameters.paramAutoPrintReportNegPrt2));
		chkSavePDF.setSelected(cast DBDefaults.getIntParam(Parameters.paramAutoPDFReport));
	}
}