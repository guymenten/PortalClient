package callbacks;

import flash.Lib;


/**
 * ...
 * @author GM
 */
class Callbacks
{
	static var cbUpdate : List<Void->Void>;
	static var cbResize : List<Void->Void>;

	public function new() 
	{
		cbUpdate = new List();
		cbResize = new List();
	}

	/**
	 * 
	 * @param	e
	 */
	public static function update() 
	{
		//trace("Callbacks : registerUpdate");
		for(cb in cbUpdate)
			cb();
	}

	/**
	 * 
	 * @param	e
	 */
	public static function resize() 
	{
		for(cb in cbResize)
			cb();
//
		Lib.current.graphics.clear();
	}

	/**
	 * 
	 * @param	cb
	 */
	public static function registerUpdate( cb : Void->Void )
	{
		//trace("Callbacks : registerUpdate");
//
		cbUpdate.add( cb );
	}

	/**
	 * 
	 * @param	cb
	 */
	public static function registerResize( cb : Void->Void )
	{
		cbResize.add( cb );
	}
}