package laf;
import org.aswing.ASColor;

/**
 * ...
 * @author GM
 */
class StateColor
{
	var counterTextcolor:ASColor 		= backColorIdle;
	var statetextColor:ASColor 			= backColorIdle;
	var stateBackgroundColor:ASColor 	= backColorIdle;
	
	public static var backColorIdle:ASColor = ASColor.BLACK;
	public static var backColorInStart:ASColor = ASColor.CLOUDS;
	public static var backColorInInit:ASColor = ASColor.CLOUDS;
	public static var backColorInInitBusy:ASColor = ASColor.MIDNIGHT_BLUE;
	public static var backColorInInUse:ASColor = ASColor.EMERALD;
	public static var backColorInControlling:ASColor = ASColor.ORANGE;
	public static var backColorInTest:ASColor = ASColor.SUN_FLOWER;
	public static var backColorInRAAlarm:ASColor = ASColor.ALIZARIN;
	public static var backColorInBKG:ASColor = ASColor.BELIZE_HOLE;
	public static var backColorInOUT:ASColor = ASColor.ALIZARIN;
	public static var backColorInUnknown:ASColor = ASColor.CLOUDS;
	public static var backColorInSpeed:ASColor = ASColor.AMETHYST;

}