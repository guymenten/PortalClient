package tabssettings ;

import Array;
import comp.JAdjuster1;
import comp.JButton2;
import data.DataObject;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.events.Event;
import org.aswing.ASColor;
import org.aswing.AbstractButton;
import org.aswing.AsWingConstants;
import org.aswing.BorderLayout;
import org.aswing.ButtonGroup;
import org.aswing.JCheckBox;
import org.aswing.JRadioButton;
import org.aswing.event.AWEvent;
import org.aswing.event.InteractiveEvent;
import org.aswing.geom.IntDimension;
import org.aswing.geom.IntRectangle;
import org.aswing.util.CompUtils;
import util.Images;

/**
 * ...
 * @author GM
 */
class SetDetectionLevels extends SetBase
{
	public var parametersModified:Bool;
	var tftThresholdArray		:Array<JAdjuster1>;
	var tftSigmaArray			:Array<JAdjuster1>;
	var tftSquareRootArray		:Array<JAdjuster1>;
	var chkHighNoise			:JCheckBox;

	var butOK					:JButton2;
	var group					:ButtonGroup;
	var rbSigma					:JRadioButton;
	var rbSquareRoot			:JRadioButton;
	var rbConstants				:JRadioButton;
	var previousThresholdMode	:Int;
	
	var restartBKG				:Bool;

	/**
	 * 
	 * @param	name
	 */
	public function new() 
	{
		super(new BorderLayout(0, 0));
	}

	/**
	 * 
	 */
	private override function init():Void
	{
		chkHighNoise		= new JCheckBox(DBTranslations.getText("IDS_CHK_HIGH_TRIGGER_DURING_FREE"));
		chkHighNoise.setForeground(ASColor.CLOUDS);
		chkHighNoise.addEventListener(AWEvent.ACT, onchkNoise);
		chkHighNoise.setComBounds(new IntRectangle(SetBase.x5, SetBase.y1, 300, 24));
		chkHighNoise.setHorizontalAlignment(AbstractButton.LEFT);
		addChild(chkHighNoise);
		butOK = new JButton2(SetBase.x5, SetBase.y5, 120, 32, "IDS_APPLY", onOK);
		butOK.setBackground(ASColor.EMERALD);
		butOK.setEnabled (false);
		addChild(butOK);

		tftThresholdArray			= new Array<JAdjuster1>();
		tftSigmaArray				= new Array<JAdjuster1>();
		tftSquareRootArray			= new Array<JAdjuster1>();

		var strSigma 	= DBTranslations.getText("IDS_BKG_SIGMA");
		var strConstant = DBTranslations.getText("IDS_TRIGGER");

		createMethodsRadioButtons();

		var index:Int 	= 0;
		var xPos:Int 	= SetBase.x2;
		var dX:Int 		= 100;

		for (channel in Model.channelsArray)
		{
			// Sigma
			//
			var tfSigma:JAdjuster1 = CompUtils.addAdjuster(this, channel.label, Images.loadEmpty(), xPos, SetBase.y1, Parameters.paramSigma, onAdjusterAdjusted, dX);
			tftSigmaArray.push(tfSigma);

			// Threshold
			//
			var tfThreshold:JAdjuster1 = CompUtils.addAdjuster(this, channel.label, Images.loadEmpty(), xPos, SetBase.y3, Parameters.paramThreshold, translatorToCPS, onAdjusterAdjusted, dX);
			tftThresholdArray.push(tfThreshold);

			// Square Root
			//
			var tfSquareRoot:JAdjuster1 = CompUtils.addAdjuster(this, channel.label, Images.loadEmpty(), xPos, SetBase.y5, Parameters.paramSquareRoot, onAdjusterAdjusted, dX);
			tftSquareRootArray.push(tfSquareRoot);

			xPos += cast SetBase.dX * 1.4;

			index ++;
		}

		super.init();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkNoise(e:AWEvent):Void 
	{
		Model.dbDefaults.setIntParam(Parameters.paramHighThresholdDuringPortalFree, cast chkHighNoise.isSelected(), true);		
		update(false);
	}

	/**
	 * 
	 */
	function createMethodsRadioButtons()
	{
		rbSigma					= new JRadioButton(DBTranslations.getText("IDS_BKG_SIGMA"));
		rbConstants				= new JRadioButton(DBTranslations.getText("IDS_BKG_CONSTANTS"));
		rbSquareRoot			= new JRadioButton(DBTranslations.getText("IDS_BKG_ROOT"));
		
		rbSigma.setForeground(ASColor.CLOUDS);
		rbConstants.setForeground(ASColor.CLOUDS);
		rbSquareRoot.setForeground(ASColor.CLOUDS);
		
		rbSigma.setComBoundsXYWH		(SetBase.x1, SetBase.y1 + 20, 80, 20);
		rbConstants.setComBoundsXYWH	(SetBase.x1, SetBase.y2 + 20, 80, 20);
		rbSquareRoot.setComBoundsXYWH	(SetBase.x1, SetBase.y3 + 20, 80, 20);

		rbSigma.setHorizontalAlignment(AbstractButton.LEFT);
		rbSquareRoot.setHorizontalAlignment(AbstractButton.LEFT);
		rbConstants.setHorizontalAlignment(AbstractButton.LEFT);

		addChild(rbSigma);
		addChild(rbSquareRoot);
		addChild(rbConstants);

		var sizeRB:IntDimension = new IntDimension(120, H);
		rbSigma.setPreferredSize(sizeRB);
		rbSquareRoot.setPreferredSize(sizeRB);
		rbConstants.setPreferredSize(sizeRB);

		group = new ButtonGroup();
		group.append(rbSigma);
		group.append(rbSquareRoot);
		group.append(rbConstants);

		doListen(rbSigma);
		doListen(rbSquareRoot);
		doListen(rbConstants);
	}

	/**
	 * 
	 * @param	radio
	 */
	private function doListen(radio:JRadioButton):Void
	{
		radio.addSelectionListener(rbSelectionChanged);
		radio.setHorizontalAlignment(AsWingConstants.LEFT); 
	}

	private function rbSelectionChanged(e:InteractiveEvent):Void
	{
		var target:JRadioButton = cast(e.target, JRadioButton);

		if(visible) setModified();
	
		if(!target.isSelected()){
			return;
		}

		sigmaAdjusted = target == rbSigma;
	}
	
	function onAdjusterAdjusted(inVar:Dynamic) : Void
	{
		update();
	}

	override function setModified() 
	{
		update();
	}

	/**
	 *  
	 * @param	e
	 */
	private function onSigmaAdjusted(e:AWEvent):Void 
	{
		sigmaAdjusted = true;
		setModified();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onEditChange(e:InteractiveEvent):Void 
	{
		trace("onEditChange");
	}

	/**
	 * 
	 */
	function selectThresholdMode(dao:DataObject):Void 
	{
		var rb:JRadioButton;

		switch(dao.thresholdMode)
		{
			case 0: rb = rbSigma; dao.thresholdCalculated = dao.thresholdMeasured;
			case 1: rb = rbSquareRoot;
			case 2: rb = rbConstants; dao.thresholdCalculated = dao.thresholdFixed;
			default:rb = rbSigma;
		}

		group.setSelected(rb.getModel(), true);		
	}

	/**
	 * 
	 */
	override function refresh(): Void
	{
		var index:Int = 0;
		var dao:DataObject;

		super.refresh();
		chkHighNoise.setSelected(cast DBDefaults.getIntParam(Parameters.paramHighThresholdDuringPortalFree));

		for (channel in Model.channelsArray)
		{
			tftThresholdArray[index].adjuster.setValue(channel.thresholdFixed);
			tftSquareRootArray[index].adjuster.setValue(channel.squareRoot);
			tftSigmaArray[index ++].adjuster.setValue(channel.sigma);
		}

		for (channel in Model.channelsArray)
		{
			selectThresholdMode(channel);
		}
	}

	/**
	 * 
	 */
	function onOK(e:Dynamic)
	{
		if (restartBKG)
		{
			Main.model.resetBKGMeasurement = true;
		}
		
		var index:Int = 0;

		for (channel in Model.channelsArray)
		{
			channel.thresholdMode	= group.getSelectedIndex();
			channel.sigma			= tftSigmaArray[index].adjuster.getValue();
			channel.thresholdFixed	= tftThresholdArray[index].adjuster.getValue();
			channel.squareRoot		= tftSquareRootArray[index].adjuster.getValue();
			channel.isComparingHighWhenPortalFree = chkHighNoise.isSelected();
			channel.refreshMeasureMode();

			Model.dbChannelsDefaults.updateConfigChannelTable(channel); // save in the Database
			
			index ++;
		}
		super.update();
	}

	/**
	 * 
	 */
	override function update(restartBKG:Bool = true): Void
	{
		var dao:DataObject;
		var changesMade:Int = 0;
		var index:Int = 0;

		for (channel in Model.channelsArray)
		{
			changesMade += cast (channel.thresholdMode != group.getSelectedIndex());
			changesMade += cast (channel.thresholdMode	!= group.getSelectedIndex());
			changesMade += cast (channel.sigma			!= tftSigmaArray[index].adjuster.getValue());
			changesMade += cast (channel.thresholdFixed	!= tftThresholdArray[index].adjuster.getValue());
			changesMade += cast (channel.squareRoot		!= tftSquareRootArray[index].adjuster.getValue());
			changesMade += cast (channel.isComparingHighWhenPortalFree != chkHighNoise.isSelected());
			
			index ++;
		}
			
		trace("changesMade : " + changesMade);
		butOK.setEnabled (cast changesMade);

		this.restartBKG = restartBKG;	
	}
}