package tabssettings ;
import comp.JButtonFramed;
import comp.JComboBox1;
import comp.JTextTitleArea;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.media.Camera;
import org.aswing.ASColor;
import org.aswing.AWKeyboard;
import org.aswing.BorderLayout;
import org.aswing.Component;
import org.aswing.event.AWEvent;
import org.aswing.event.InteractiveEvent;
import org.aswing.JCheckBox;
import org.aswing.JColorChooser;
import org.aswing.JFrame;
import org.aswing.util.CompUtils;
import org.aswing.VectorListModel;
import util.Images;

/**
 * ...
 * @author GM
 */
class SetDefaults extends SetBase
{
	var chkCamera		:JCheckBox;
	var taLeftChannel	:JTextTitleArea;
	var taRightChannel	:JTextTitleArea;
	var bValuesModified	:Bool;
	public var butColor	:JButtonFramed;
	var chooserDialog	:JFrame;
	var cbCamera		:JComboBox1;
	var vecComName		:VectorListModel;

	/**
	 * 
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
		super.init();

		Main.root1.addEventListener(PanelEvents.EVT_PANE_MONITOR, OnUpdateValues);

		chkCamera		= CompUtils.addCheckBox(this, "IDS_CAMERA", SetBase.x2, SetBase.y2, onchkCamera);
		cbCamera 		= CompUtils.addComboBox(this, "", Images.loadCamera(), SetBase.x3 + 32, SetBase.y2, 200, onCBCamera);

		butColor 		= new JButtonFramed("IDS_COLOR_BACK", 260, 294, 140, 32, "IDS_COLOR_BACK", null, onbutBkgCol);
		butColor.setBackground(new ASColor(DBDefaults.getIntParam(Parameters.paramBackgroundColor)));
		addChild(butColor);

		taLeftChannel 	= CompUtils.addTextTitleArea(this, "IDS_LEFT_CHANNEL_NAME",		SetBase.x2, SetBase.y1, leftLabelListener);
		taRightChannel 	= CompUtils.addTextTitleArea(this, "IDS_RIGHT_CHANNEL_NAME",	SetBase.x4, SetBase.y1, rightLabelListener);
		
		fillCamList();
	}

	/**
	 * 
	 */
	function fillCamList() 
	{
		vecComName = new VectorListModel([]);

		for (name in Camera.names)
		{
			vecComName.append(name);
		}

		cbCamera.combobox.setModel(vecComName);

		var strCamera:String = DBDefaults.getStringParam(Parameters.paramCameraIndex);
		cbCamera.combobox.setSelectedItem(strCamera);

		chkCamera.setSelected(cast DBDefaults.getBoolParam(Parameters.paramCameraIndex));
	}

	/**
	 * 
	 * @param	e
	 */
	function onCBCamera(e:String)
	{
		var strCom:String = cbCamera.combobox.getSelectedItem();
		Model.dbDefaults.setStringParam(Parameters.paramCameraIndex, strCom);		
	}

	/**
	 * 
	 * @param	e
	 */
	function onbutBkgCol(e:MouseEvent)
	{
		var jColorChooser 	= new JColorChooser();
		var frame:JFrame	= new JFrame(this, "");

		frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);		
		frame.getContentPane().setLayout(new BorderLayout());	
		chooserDialog = JColorChooser.createDialog(jColorChooser, frame, DBTranslations.getText("IDS_CHOOSE_A_COLOR"), 
		false, __colorSelected, 
			__colorCanceled);
		jColorChooser.addEventListener(InteractiveEvent.STATE_CHANGED, onColorSelected);
		frame.show();
		chooserDialog.show();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onColorSelected(e:InteractiveEvent):Void 
	{
		__colorSelected(e.currentTarget.getSelectedColor());
	}

	function __colorSelected(color:ASColor):Void
	{
		butColor.setBackground(color);
		if (color.getRGB() == 0)
			color = new ASColor(0x34495e);

		Model.dbDefaults.setIntParam(Parameters.paramBackgroundColor, color.getRGB());
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_BACK_COLOR_CHANGED));
	}

	function __colorCanceled(e:Dynamic):Void
	{
		//infoText.appendText("Selecting canceled!\n");
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
			Model.dbChannelsDefaults.updateConfigChannelLabel(1, taLeftChannel.textArea.getText());
			Model.dbChannelsDefaults.updateConfigChannelLabel(2, taRightChannel.textArea.getText());

			for (channel in Model.channelsArray)
			{
				if (channel.channelIndex == 1)
					channel.label = taLeftChannel.textArea.getText();
					else if(channel.channelIndex == 2)
						channel.label = taRightChannel.textArea.getText();
			}
			update();
		}
	}

	/**
	 * 
	 * @param	key
	 */
	function leftLabelListener(key:KeyboardEvent) :Void
	{
		if (key.charCode == cast AWKeyboard.TAB) taRightChannel.textArea.makeFocus();
		if (key.charCode == cast AWKeyboard.ENTER) { key.preventDefault(); taRightChannel.textArea.makeFocus(); }
		bValuesModified = true;
	}

	/**
	 * 
	 * @param	input
	 */
	function rightLabelListener(key:KeyboardEvent) :Void
	{
		if (key.charCode == cast AWKeyboard.TAB) taLeftChannel.textArea.makeFocus();
		if (key.charCode == cast AWKeyboard.ENTER) { key.preventDefault(); taLeftChannel.textArea.makeFocus(); }
		bValuesModified = true;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onchkCamera(e:AWEvent):Void 
	{
		Model.portalCameraEnabled = chkCamera.isSelected();
		Model.dbDefaults.setIntParam(Parameters.paramCameraIndex, cast Model.portalCameraEnabled, true);		
	}

	/**
	 * 
	 */
	override function refresh(): Void
	{
		chkCamera.setSelected(cast DBDefaults.getIntParam(Parameters.paramCameraIndex));

		for (channel in Model.channelsArray)
		{
			if (channel.channelIndex == 1) taLeftChannel.textArea.setText(channel.label);
			else if (channel.channelIndex == 2) taRightChannel.textArea.setText(channel.label);
		}
	}

}