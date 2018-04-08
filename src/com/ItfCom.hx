package com;
import error.Errors;
import enums.Enums;

/**
 * ...
 * @author GM
 */
interface ItfCom
{
	private function writeDataString(data:String) : Int;
	private function dataAvailable() : Bool;
	private function initCom() : Bool;
	private function setComError(sent:Int): Void;
	private function isComEnabled(): Bool;
	private function isComOpened(): Bool;
	private function getErrorOrigin(): ErrorOrigin;
	private function isIOAddress(value:Int):Bool;
}