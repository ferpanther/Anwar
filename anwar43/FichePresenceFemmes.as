package 
{
	import com.greensock.TweenLite;
	import com.greensock.*;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.easing.*;

	import flash.display.Shape;
	import flash.net.URLLoader;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.net.FileReference;
	import flash.display.Loader;
	import flash.events.FocusEvent;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import fl.controls.Button;
	import flash.display.Sprite;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.net.Responder;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class FichePresenceFemmes extends MovieClip
	{
		public static const FICHESPW_SAVED:String = "fichespw_saved";
		public static const FICHESPW_NOTSAVED:String = "fichespw_notsaved";

		private var baseUrl:String = "http://www.flash-experts.com/";
		private var amfphp_path:String = baseUrl + "amfphp/gateway.php";
		private var gw:NetConnection = new NetConnection();

		public var datePanel:DatePanel;
		public var php_load:String;
		public var php_save:String;
		private var femmes:Array = new Array();
		public var presenceW:Array = new Array();
		private var prev_femmes:Array = new Array();

		private var rows:Array = new Array();
		private var pages:Array = new Array();
		private var counter:int;
		private var nupdates:int;
		private var session:int = 0;
		private var session_txt:String = "07:00 - 15:00";
		private var max_lines:int = 22;
		private var curr_line:int = 0;
		private var nbr_pages:int = 0;

		private var curr_row:int = 0;
		private var next_row:int = 0;
		private var prev_row:int = 0;
		var fiche_xml:XML;
		private var new_fiche:XML;

		var jours:Array = new Array();
		var mois:Array = new Array();

		var date:Date = new Date();
		var dd:int = date.getDay();
		var jj:int = date.getDate();
		var mm:int = date.getMonth();
		var yyyy:int = date.getFullYear();

		var curr_date:Date = new Date();
		var curr_day:int = curr_date.getDay();
		var curr_jj:int = curr_date.getDate();
		var curr_mm:int = curr_date.getMonth();
		var curr_yyyy:int = curr_date.getFullYear();
		var ms:Number = new Date(yyyy,mm,jj,0,0,0,0).valueOf();

		var tw:TweenLite;
		var isToday:Boolean = true;
		var isPast:Boolean = false;
		var isFuture:Boolean = false;

		//---------------------------------------------------
		public function FichePresenceFemmes()
		{
			if (this.stage)
			{
				init();
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		//-------------------------------------------------
		private function init(e:Event = null):void
		{
			if (e != null)
			{
				this.removeEventListener(Event.ADDED_TO_STAGE, init);
			}

			gw.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			gw.connect(amfphp_path);

			showPanel();
		}
		//-------------------------------------------------
		public function setFemmes(arr:Array):void
		{
			this.femmes = arr;
		}
		//-------------------------------------------------
		public function setPresence(arr:Array):void
		{
			this.presenceW = arr;
		}
		//-------------------------------------------------
		public function setJours(arr:Array):void
		{
			this.jours = arr;
		}
		//-------------------------------------------------
		public function setMois(arr:Array):void
		{
			this.mois = arr;
		}
		//-------------------------------------------------
		public function showPanel():void
		{
			this.seance.border = true;

			this.header.x = (this.bg.width - this.header.width)/2;

			this.cat.htmlText = "<b>Femmes de Ménage</b>";
			this.seance.htmlText = session_txt;

			this.matin_btn.visible = false;
			this.matin_btn.enabled = false;
			this.soir_btn.visible = false;
			this.soir_btn.enabled = false;

			//this.matin_btn.addEventListener(MouseEvent.CLICK, matinClicked);
			//this.soir_btn.addEventListener(MouseEvent.CLICK, soirClicked);

			this.print_btn.addEventListener(MouseEvent.CLICK, imprimer);
			this.view_btn.addEventListener(MouseEvent.CLICK, viewFile);

			this.txtbg.alpha = .5;
		}
		//-------------------------------------------------
		public function getSession():void
		{
			this.today.text = getToday();
			this.matin_btn.enabled = true;
			//this.soir_btn.enabled = true;
			updateRows();
		}
		//-------------------------------------------------
		private function getToday():String
		{
			var auj:String = jours[curr_day - 1];
			if (curr_day == 0)
			{
				auj = "Dimanche";
			}
			var dat:String = (curr_jj > 9) ? String(curr_jj) : "0" + String(curr_jj);
			var st:String = auj + " " + dat + " " + mois[curr_mm] + " " + String(curr_yyyy);
			return st;
		}
		//-------------------------------------------------;
		private function matinClicked(e:MouseEvent):void
		{
			this.matin_btn.alpha = 1;
			//this.soir_btn.alpha = .5;
			session = 0;
			session_txt = "07:00 - 15:00";
			this.seance.htmlText = session_txt;
			getSession();
		}
		/*
		//-------------------------------------------------
		private function soirClicked(e:MouseEvent):void
		{
		this.matin_btn.alpha = .5;
		this.soir_btn.alpha = 1;
		session = 1;
		session_txt = "13 - 17";
		this.seance.htmlText = session_txt;
		getSession();
		}
		*/
		//-------------------------------------------------
		public function updatePresence():void
		{
			if (isToday)
			{
				getSession();
			}
		}
		//-------------------------------------------------
		private function updateRows():void
		{
			clearHolder();
			var xx:int = 0;
			var yy:int = 0;

			this.today.text = getToday();

			rows.splice(0);
			for (var f:int = 0; f < femmes.length; f++)
			{
				rows[f] = new RowW();
				rows[f].name = String(f);
				rows[f].nbr.text = String(f + 1);
				rows[f].nom.text = femmes[f]["nom"] + " " + femmes[f]["prenom"];
				rows[f].uid.text = femmes[f]["uid"];
				rows[f].entree.text = presenceW[f][curr_mm][curr_jj - 1][session]["entree"];
				rows[f].sortie.text = presenceW[f][curr_mm][curr_jj - 1][session]["sortie"];
				rows[f].obs.text = presenceW[f][curr_mm][curr_jj - 1][session]["obs"];

				rows[f].bg.alpha = .2;
				if (f % 2 != 0)
				{
					rows[f].bg.alpha = .4;
				}

				rows[f].x = xx;
				rows[f].y = yy;
				yy +=  rows[f].height;

				rows[f].nbr.border = true;
				rows[f].nom.border = true;
				rows[f].uid.border = true;
				rows[f].entree.border = true;
				rows[f].sortie.border = true;
				rows[f].obs.border = true;

				rows[f].addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				rows[f].addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

				rows[f].entree.addEventListener(KeyboardEvent.KEY_DOWN,onKEY_DOWN);
				rows[f].sortie.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
				rows[f].obs.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);

				rows[f].entree.addEventListener(FocusEvent.FOCUS_IN, onFocus);
				rows[f].sortie.addEventListener(FocusEvent.FOCUS_IN, onFocus);
				rows[f].obs.addEventListener(FocusEvent.FOCUS_IN, onFocus);

				this.holder.addChild(rows[f]);
			}
			this.sp.source = this.holder;
		}
		//-----------------------------------
		private function onMouseOver(e:MouseEvent):void
		{
			e.currentTarget.bg.alpha = 0;
		}
		//-----------------------------------
		private function onMouseOut(e:MouseEvent):void
		{
			e.currentTarget.bg.alpha = .2;
			if (int(e.currentTarget.name) % 2 != 0)
			{
				e.currentTarget.bg.alpha = .4;
			}
		}
		//-----------------------------------
		private function updateTabs():void
		{
			next_row = curr_row + 1;
			if (next_row >= rows.length)
			{
				next_row = 0;
			}

			prev_row = curr_row - 1;
			if (prev_row < 0)
			{
				prev_row = rows.length - 1;
			}
		}
		//-----------------------------------
		private function onFocus(e:FocusEvent):void
		{
			curr_row = int(e.currentTarget.parent.name);
			updateTabs();
		}
		//-----------------------------------
		private function onKEY_DOWN(e : KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case 13 :
					switch (e.currentTarget.name)
					{
						case "entree" :
							rows[curr_row].entree.text = new DateTime().getTime();
							break;
						case "sortie" :
							rows[curr_row].sortie.text = new DateTime().getTime();
							break;
						case "obs" :
							stage.focus = rows[next_row].entree;
							break;
					}
					e.currentTarget.setSelection(0, e.currentTarget.length);
					break;

				case 39 :
					//right
					switch (e.currentTarget.name)
					{
						case "entree" :
							stage.focus = rows[curr_row].sortie;
							break;
						case "sortie" :
							stage.focus = rows[curr_row].obs;
							break;
						case "obs" :
							stage.focus = rows[next_row].entree;
							break;
					}
					break;

				case 37 :
					//left
					switch (e.currentTarget.name)
					{
						case "entree" :
							stage.focus = rows[prev_row].obs;
							break;
						case "sortie" :
							stage.focus = rows[curr_row].entree;
							break;
						case "obs" :
							stage.focus = rows[curr_row].sortie;
							break;
					}
					break;
				case 40 :
					//down
					switch (e.currentTarget.name)
					{
						case "entree" :
							stage.focus = rows[next_row].entree;
							break;
						case "sortie" :
							stage.focus = rows[next_row].sortie;
							break;
						case "obs" :
							stage.focus = rows[next_row].obs;
							break;
					}
					break;

				case 38 :
					//up
					switch (e.currentTarget.name)
					{
						case "entree" :
							stage.focus = rows[prev_row].entree;
							break;
						case "sortie" :
							stage.focus = rows[prev_row].sortie;
							break;
						case "obs" :
							stage.focus = rows[prev_row].obs;
							break;
					}
					break;
			}
		}
		//--------------------------------------
		private function clearHolder():void
		{
			for (var c:int = this.holder.numChildren-1; c>=0; c--)
			{
				this.holder.removeChildAt(c);
			}
			this.sp.source = this.holder;
		}
		//-----------------------------------
		function viewFile(e:MouseEvent):void
		{
			disableBtns();

			datePanel = new DatePanel();
			datePanel.addEventListener(Event.COMPLETE, onDateSet);
			datePanel.x = this.view_btn.x;
			datePanel.y = this.view_btn.y - datePanel.bg.height - 10;
			this.addChild(datePanel);
		}
		//-----------------------------------
		public function enableBtns():void
		{
			this.exit_btn.enabled = true;
			this.matin_btn.enabled = true;
			this.view_btn.enabled = true;
			this.save_btn.enabled = true;
			this.print_btn.enabled = true;
		}
		//-----------------------------------
		public function disableBtns():void
		{
			this.exit_btn.enabled = false;
			this.matin_btn.enabled = false;
			this.view_btn.enabled = false;
			this.save_btn.enabled = false;
			this.print_btn.enabled = false;
		}
		//-----------------------------------
		function onDateSet(e:Event):void
		{
			if (datePanel.ret == 1)
			{
				curr_day = datePanel.dd;
				curr_jj = datePanel.jj;
				curr_mm = datePanel.mm;
				curr_yyyy = datePanel.yy;

				isToday = (datePanel.ms == ms);
				isPast = (datePanel.ms < ms);
				isFuture = (datePanel.ms > ms);

				getSession();
			}
			enableBtns();
		}
		//------------------------------------------------
		private function isListed(uid:String, arr:Array):Boolean
		{
			if (arr == null || arr.length == 0)
			{
				return false;
			}
			var listed:Boolean = false;
			for (var a:int = 0; a < arr.length; a++)
			{
				if (uid == arr[a]["uid"])
				{
					return true;
				}
			}
			return false;
		}
		//------------------------------------------------
		public function save():void
		{
			trace("save", curr_jj, curr_mm, curr_yyyy, session);
			new_fiche = new XML( <fiche /> );
			new_fiche. @ jj = curr_jj;
			new_fiche. @ mm = curr_mm;
			new_fiche. @ yy = curr_yyyy;
			new_fiche. @ session = session;
			new_fiche. @ today = this.today.text;

			for (var r:int = 0; r < rows.length; r++)
			{
				var row_node:XML = new XML (<row />);
				row_node. @ nom = rows[r].nom.text;
				row_node. @ uid = rows[r].uid.text;
				row_node. @ entree = rows[r].entree.text;
				row_node. @ sortie = rows[r].sortie.text;
				row_node. @ obs = rows[r].obs.text;
				new_fiche.appendChild(row_node);
			}

			restoreMsg();
			this.msg.text = "Enregistrement en cours...";

			var save_responder:Responder = new Responder(onSaveResult,onSaveFault);
			gw.call("Anwar.addFichePresenceW", save_responder, curr_jj, curr_mm, curr_yyyy, session, escape(new_fiche));
		}
		//------------------------------------------------
		function onSaveResult(reponse:Object):void
		{
			trace("addFichePresenceW res", reponse);
			dispatchEvent(new Event(FichePresenceFemmes.FICHESPW_SAVED));
		}
		//------------------------------------------------
		function onSaveFault(reponse:Object):void
		{
			trace("addFichePresenceW err", reponse);
			dispatchEvent(new Event(FichePresenceFemmes.FICHESPW_NOTSAVED));
		}
		//------------------------------------------------
		public function restoreMsg():void
		{
			this.msg.text = "";
			this.msg.alpha = 1;
		}
		//---------------------------------------------------
		private function imprimer(e:MouseEvent):void
		{
			curr_line = 0;
			counter = 0;
			nbr_pages = 0;
			pages.splice(0);
			printPage();
		}
		//---------------------------------------------------
		private function printPage():void
		{
			while (counter < rows.length)
			{
				/*
				To convert pixel to point: points = pixel * 72 / 96
				To convert point to pixel: pixels = point * 96 / 72
				*/
				pages[nbr_pages] = new FichePresencePr();
				pages[nbr_pages].cat.htmlText = this.cat.htmlText;

				pages[nbr_pages].seance.htmlText = this.seance.htmlText;
				pages[nbr_pages].today.text = this.today.text;

				var xx:int = 0;
				var yy:int = 0;

				while (curr_line < max_lines)
				{
					var row:RowFPresence = new RowFPresence();

					if (counter < rows.length)
					{
						row.nbr.text = String(counter + 1);
						row.nom.text = rows[curr_line].nom.text;
						row.uid.text = rows[curr_line].uid.text;
						row.entree.text = rows[curr_line].entree.text;
						row.sortie.text = rows[curr_line].sortie.text;
						row.obs.text = rows[curr_line].obs.text;
					}
					else
					{
						row.nbr.text = "";
						row.nom.text = "";
						row.uid.text = "";
						row.entree.text = "";
						row.sortie.text = "";
						row.obs.text = "";
					}

					row.x = xx;
					row.y = yy;
					yy +=  row.height;

					pages[nbr_pages].holder.addChild(row);

					curr_line++;
					counter++;
				}

				pages[nbr_pages].footer.x = xx;
				pages[nbr_pages].footer.y = yy + 10;
				pages[nbr_pages].holder.addChild(pages[nbr_pages].footer);

				if (counter < rows.length)
				{
					curr_line = 0;
					nbr_pages++;
					printPage();
				}
				else
				{
					var ferPrinter:PrintingP = new PrintingP();
					ferPrinter.printPortrait(pages);
				}
			}
		}
		//------------------------------------------------
		public function netStatusHandler(event:NetStatusEvent):void
		{
			trace("=======", event.info.code);

			switch (event.info.code)
			{
				case "NetConnection.Call.BadVersion" :
					trace(event.info.code);
					break;
				case "NetConnection.Call.Failed" :
					trace(event.info.code);
					break;
				case "NetConnection.Call.Prohibited" :
					trace(event.info.code);
					break;
				case "NetConnection.Connect.AppShutdown" :
					trace(event.info.code);
					break;
				case "NetConnection.Connect.Closed" :
					trace(event.info.code);
					break;
				case "NetConnection.Connect.Failed" :
					trace(event.info.code);
					break;
				case "NetConnection.Connect.IdleTimeout" :
					trace(event.info.code);
					break;
				case "NetConnection.Connect.InvalidApp" :
					trace(event.info.code);
					break;
				default :
					trace("default ERROR");
			}
		}
		//---------------------------------------------------

	}

}