package com;

import flash.net.URLRequest;

/**
 * ...
 * @author GM
 */
class SMSSend extends EventDispatcher
{
	public function new(number:String, message:String) 
	{
		navigateToURL(new URLRequest("sms:" + number + "?body=Message " + message));
	}
}