package com;

import flash.display.Loader;
import flash.events.EventDispatcher;
import flash.net.Socket;
import flash.system.Security;
import flash.events.*;
//import mail.SMTPMailer;
//import mail.URLMail;

/**
 * ...
 * @author GM
 */
class Mailer extends EventDispatcher
{
	//var mailer:SMTPMailer;
	//var mailer:URLMail;

	public function new(?from:String, ?to:String) 
	{
		super();
	
		//mailer = new URLMail();

		//mailer = new SMTPMailer( "smtp.gmail.com", 465 );
		////mailer = new SMTPMailer( "ssl://smtp.gmail.com", 465 );
		//mailer.authenticate("mxt.cloud", "marc52guy59" ); //<<< I had used my username and password here 
		//mailer.sendHTMLMail("mxt.cloud@gmail.com", "guymenten@gmail.com", "hey how", "gogogo" );
		////mailer = new SMTPMailer( "ssl://smtp.gmail.com", from, to, p.get(), 465, "mxt.cloud@gmail.com","marc52guy59" );
	}
}