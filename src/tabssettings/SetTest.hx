package tabssettings;

//import away3d.containers.View3D;
//import away3d.entities.Mesh;
//import away3d.materials.MaterialBase;
//import away3d.primitives.SphereGeometry;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import org.aswing.BorderLayout;
import org.aswing.event.AWEvent;
import org.aswing.JCheckBox;
import org.aswing.util.CompUtils;
//import sprites.SpriteFire;
import com.quetwo.ser.ArduinoConnector;

/**
 * ...
 * @author ...
 */

class SetTest extends SetBase
{
	var chkAutoLogon:JCheckBox;
	var ac:ArduinoConnector;
	//var fire:SpriteFire;

	public function new() 
	{
		super(new BorderLayout(0, 0));
		
		 ac = new ArduinoConnector();
		
	}

	/**
	 * 
	 */
	private override function init():Void
	{
		super.init();

		chkAutoLogon 	= CompUtils.addCheckBox(this, "IDS_CHK_AUTOLOGON",		SetBase.x1 + 40, SetBase.y1, onchkAutoLogon);
		//fire = new SpriteFire();
		//Main.stageMain.stage.addChild(fire);
	}
	
	function onchkAutoLogon(e:AWEvent) 
	{
		
	}

}