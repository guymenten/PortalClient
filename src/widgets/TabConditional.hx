package widgets;
import db.DBTranslations;
import events.PanelEvents;
import flash.display.Bitmap;
import flash.events.Event;
import icon.TabIcon;
import org.aswing.ASColor;
import org.aswing.JTabbedPane;
import widgets.ItfCondTab;
import org.aswing.plaf.basic.tabbedpane.TabBackground;

/**
 * ...
 * @author GM
 */
class TabConditional extends WBase implements ItfCondTab
{
	var tabbedPane				:JTabbedPane;
	var privilegeSuperUser:Int 	= -1;
	var priviledgeAdmin:Int 	= -1;

	public function new(nameIn:String) 
	{
		super(nameIn);

		visible = false;
	}

	/**
	 * 
	 * @param	e
	 */
	private override function onAddedToStage(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		createTabbedPane();
	}

	/**
	 * 
	 * @param	e
	 */
	private function createTabbedPane():Void
	{
		Main.root1.addEventListener(PanelEvents.EVT_USER_LOGGING, onUserLogging);
		tabbedPane = new JTabbedPane();
		//tabbedPane.setBorder(new LineBorder(null, new ASColor( ASColor.MIDNIGHT_BLUE.getRGB(), 0.6)));

		addChild(tabbedPane);
		onUserLogging();
		tabbedPane.setWidth(840);
		tabbedPane.setHeight(420);
		tabbedPane.setIconTextGap(0);
	}

	/**
	 * 
	 */
	function appendTab(tab:Dynamic, title:String, bm:Bitmap):Void 
	{
		tabbedPane.appendTab(tab,  DBTranslations.getText(title), new TabIcon(bm));
	}

	/**
	 *
	 * @param	e
	 */
	private function onUserLogging(e:Event = null):Void 
	{
		if ((privilegeSuperUser != cast Model.privilegeSuperUser) || (priviledgeAdmin != cast Model.priviledgeAdmin))
		{
			privilegeSuperUser 	= cast Model.privilegeSuperUser;
			priviledgeAdmin 	= cast Model.priviledgeAdmin;
			tabbedPane.removeAll();
	
			createUserTabs();
			if (Model.privilegeSuperUser) { createSuperUserTabs(); }
			if (Model.priviledgeAdmin) { createAdminTabs(); }
			tabbedPane.setSelectedIndex(0);
		}
	}
	
	function createAdminTabs() 
	{
		
	}
	
	function createSuperUserTabs() 
	{
		
	}
	
	function createUserTabs() 
	{
		
	}
}