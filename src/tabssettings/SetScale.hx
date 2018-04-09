package tabssettings;
import db.DBDefaults;
import enums.Enums.Parameters;
import org.aswing.BorderLayout;
import org.aswing.event.AWEvent;
import org.aswing.JCheckBox;
import org.aswing.util.CompUtils;

/**
 * ...
 * @author ...
 */
class SetScale extends SetBase
{
	static var chkScale:JCheckBox;

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

		chkScale		= CompUtils.addCheckBox(this, "IDS_BUT_SCALE", SetBase.x2, SetBase.y2, onchkScale);
	}

	/**
	 * 
	 */
	override function refresh(): Void
	{
		chkScale.setSelected(cast DBDefaults.getIntParam(Parameters.paramScaleEnabled));
	}
 
	/**
	 * 
	 * @param	e
	 */
	function onchkScale(e:AWEvent)
	{
		Model.scaleEnabled = chkScale.isSelected();
		Model.dbDefaults.setIntParam(Parameters.paramScaleEnabled, cast Model.scaleEnabled);
		update();
	}

}