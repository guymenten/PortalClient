package tabssettings ;

import Array;
import comp.JAdjuster1;
import comp.JComboBox1;
import db.DBSounds;
import enums.Enums.Parameters;
import flash.display.Bitmap;
import flash.display.StageAlign;
import org.aswing.BorderLayout;
import org.aswing.event.AWEvent;
import org.aswing.event.InteractiveEvent;
import org.aswing.JAdjuster;
import org.aswing.JComboBox;
import org.aswing.util.CompUtils;
import org.aswing.VectorListModel;
import sound.Sounds;
import util.Images;

/**
 * ...
 * @author GM
 */
class SetSounds extends SetBase
{
	var adjSoundsdArray	:Array<JAdjuster1>;
	var cbFileArray		:Array<JComboBox1>;
	var adjSoundsCount	:Int;
	var xPos			:Int;
	var yPos			:Int;

	var test			:JAdjuster;
	var adjAlarmRep		:JAdjuster1;
	var adjErrorRep		:JAdjuster1;
	var vecComName		:VectorListModel;

	/**
	 * 
	 * @param	name
	 */
	public function new() 
	{
		super(new BorderLayout(0, 0));
	}

	private override function init():Void
	{
		super.init();

		vecComName = new VectorListModel([]);

		for (dao in Sounds.soundFiles)
		{
			vecComName.append(dao.name);
		}

		xPos = SetBase.x1 + 20;
		yPos = SetBase.y1;
		adjSoundsdArray	= new Array<JAdjuster1>();
		cbFileArray 	= new Array<JComboBox1>();

		DBSounds.soundsMap.eachValue(createAdjControl);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onAdjChanging(e:AWEvent):Void 
	{
		var adj:JAdjuster = cast(e.target, JAdjuster);
		var data:SoundData = DBSounds.soundsMap.get(adj.getName());
		data.Volume = adj.getValue();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onAdjChanged(e:AWEvent):Void 
	{
		var adj:JAdjuster = cast(e.target, JAdjuster);
		var data:SoundData = DBSounds.soundsMap.get(adj.getName());
		data.Volume = adj.getValue();
		data.soundPlay.play();
  		Model.sounds.updateSoundData(data);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onAdjAlarmRep(e:AWEvent):Void 
	{
		var adj:JAdjuster = cast(e.target, JAdjuster);
		var data:SoundData = DBSounds.soundsMap.get(adj.getName());
		data.RepeatCount = adj.getValue();
		//trace("ata.RepeatCount: " + ata.RepeatCount);
		DefaultParameters.paramAlarmTimeout = data.RepeatCount;
		data.soundPlay.play();
  		Model.sounds.updateSoundData(data);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onAdjErrorRep(e:AWEvent):Void 
	{
		var adj:JAdjuster 					= cast(e.target, JAdjuster);
		var data:SoundData 					= DBSounds.soundsMap.get(adj.getName());
		data.RepeatCount 					= adj.getValue();
		DefaultParameters.paramErrorTimeout = data.RepeatCount;

		data.soundPlay.play();
  		Model.sounds.updateSoundData(data);
	}

	/**
	 * 
	 * @param	data
	 */
	function createAdjControl(data:SoundData) 
	{	
		var dao:SoundData = DBSounds.soundsMap.get(data.Key);
		var dX:Int = 66;

		if (adjSoundsCount == 4)
		{
			xPos 	= SetBase.x4 + 40;
			yPos 	= SetBase.y1;
			adjSoundsCount = 0;

			DefaultParameters.paramErrorTimeout = dao.RepeatCount;

			adjErrorRep = CompUtils.addAdjuster(this, "IDS_SOUND_REPEAT", StageAlign.TOP, xPos + 240, yPos,Parameters.paramErrorTimeout, onAdjErrorRep, dX);
			adjErrorRep.adjuster.setValue(dao.RepeatCount);
			adjErrorRep.adjuster.setName(data.Key);
		}

		else if (adjSoundsCount == 0)
		{
			yPos = SetBase.y1;

			adjAlarmRep = CompUtils.addAdjuster(this, "IDS_SOUND_REPEAT", StageAlign.TOP, xPos + 240, yPos, Parameters.paramAlarmTimeout, onAdjAlarmRep, dX);
			adjAlarmRep.adjuster.setValue(dao.RepeatCount);
			adjAlarmRep.adjuster.setName(data.Key);
		}

		else yPos += (SetBase.y2 - SetBase.y1);

		adjSoundsCount ++;

		var adjSound:JAdjuster1 = CompUtils.addAdjuster(this, data.Key, getImage(data.Key), xPos, yPos, data.Min, data.Max, onAdjChanged, dX);
		adjSound.adjuster.setValue(cast data.Volume);
		adjSound.adjuster.addEventListener(InteractiveEvent.STATE_CHANGED, onAdjChanging);
		var cbName:JComboBox1 	= CompUtils.addComboBox(this, "IDS_SOUND",  xPos + 100, yPos, 120, onNameChanged);
		cbName.combobox.setName(data.Key);
		cbName.combobox.setModel(vecComName);

		cbFileArray.push(cbName);
		adjSoundsdArray.push(adjSound);

		addChild(adjSound);
	}

	/**
	 * 
	 * @param	e
	 */
	function onNameChanged(e:Dynamic) :Void
	{
		var cb:JComboBox = e.target;
		
		trace(cb.getName());
		trace(cb.getSelectedItem());
	}

	/**
	 * 
	 * @param	key
	 * @return
	 */
	function getImage(key:String) :Bitmap
	{
		switch(key)
		{
			case 'IDS_SND_RAALARM' 		: return Images.loadLEDRAOn();
			case 'IDS_SND_PORTAL_FREE' 	: return Images.loadReport();
			case 'IDS_SND_CLICK' 		: return Images.loadtruckBlueIcon();
			case 'IDS_SND_PORTAL_BUSY' 	: return Images.loadtruckYellowIcon();
			case 'IDS_SND_ERROR' 		: return Images.loadLEDRepNonOK();
			case 'IDS_SND_TEST' 		: return Images.loadTest();
			case 'IDS_SND_GEIGER' 		: return Images.loadLEDRAOff();
			case 'IDS_SND_MOTION' 		: return Images.loadMotion();
		}

		return null;
	}
}