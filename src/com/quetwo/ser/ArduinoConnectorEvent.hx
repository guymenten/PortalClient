/*
* Version: MPL 1.1
*
* The contents of this file are subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use this file except in compliance with
* the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is ArduinoConnector.as
*
* The Initial Developer of the Original Code is Nicholas Kwiatkowski.
* Portions created by the Initial Developer are Copyright (C) 2011
* the Initial Developer. All Rights Reserved.
*
*/

package com.quetwo.ser;

import flash.events.ProgressEvent;

class ArduinoConnectorEvent extends ProgressEvent
{
	
	public var SOCKET_DATA:String = "socketData";
	public var PROGRESS:String = "progress";
	
	public function new(type:String, bubbles:Bool=false, cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
	}
}