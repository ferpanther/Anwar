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

	public class FichePresenceForm extends MovieClip
	{
		public static const FILE_SAVED:String = "file_saved";

		private var baseUrl:String = "http://www.flash-experts.com/";
		private var amfphp_path:String = baseUrl + "amfphp/gateway.php";
		private var gw:NetConnection = new NetConnection();

		var ficheEmploi:FicheEmploi = new FicheEmploi();

		public var datePanel:DatePanel;
		public var php_load:String;
		public var php_save:String;
		private var cadres:Array = new Array();
		private var cadres_actifs:Array = new Array();
		public var presence:Array = new Array();
		private var rows:Array = new Array();

		private var counter:int;
		private var nupdates:int;
		private var session:int = 0;
		private var entree0_txt:String = "08";
		private var entree1_txt:String = "10";
		private var entree2_txt:String = "13";
		private var entree3_txt:String = "15";

		private var sortie0_txt:String = "10";
		private var sortie1_txt:String = "12";
		private var sortie2_txt:String = "15";
		private var sortie3_txt:String = "17";

		private var pages:Array = new Array();
		private var entrees_txt:Array = new Array();
		private var sorties_txt:Array = new Array();
		private var seances_btn:Array = new Array();
		public var seances_opt:int = 0;

		private var max_lines:int = 22;
		private var curr_line:int = 0;
		private var nbr_pages:int = 0;
		private var emploi_xml:XML;
		private var fiche_xml:XML;
		private var new_fiche:XML;

		private var jours:Array = new Array();
		private var mois:Array = new Array();
		private var heures:Array = new Array();
		private var day_counter:int = 0;

		private var curr_row:int = 0;
		private var next_row:int = 0;
		private var prev_row:int = 0;

		var date:Date = new Date();
		var dd:int = date.getDay();
		var jj:int = date.getDate();
		var mm:int = date.getMonth();
		var yyyy:int = date.getFullYear();
		var ms:Number = new Date(yyyy,mm,jj,0,0,0,0).valueOf();

		var curr_date:Date = new Date();
		var curr_day:int = curr_date.getDay();
		var curr_jj:int = curr_date.getDate();
		var curr_mm:int = curr_date.getMonth();
		var curr_yyyy:int = curr_date.getFullYear();
		var daily_sessions:int = 5;
		var tw:TweenLite;
		var isToday:Boolean = true;
		var isPast:Boolean = false;
		var isFuture:Boolean = false;

		//---------------------------------------------------
		public function FichePresenceForm()
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
			trace("FichePresenceForm init");
			if (e != null)
			{
				this.removeEventListener(Event.ADDED_TO_STAGE, init);
			}

			gw.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			gw.connect(amfphp_path);

			showPanel();
		}
		public function setEmploi(emploi_xml:XML):void
		{
			trace("setEmploi");
			this.emploi_xml = emploi_xml;
		}
		//-----------------------------------------------------------------------------------------
		public function setPresence(arr:Array):void
		{
			trace("setPresence");
			this.presence = arr;
		}
		//-------------------------------------------------
		public function setJours(arr:Array):void
		{
			trace("setJours");
			this.jours = arr;
		}
		//-------------------------------------------------
		public function setMois(arr:Array):void
		{
			trace("setMois");
			this.mois = arr;
		}
		//-------------------------------------------------
		public function setHeures(arr:Array):void
		{
			trace("setHeures");
			this.heures = arr;
		}
		//-------------------------------------------------
		public function setDailySessions(sessions:int):void
		{
			trace("setDailySessions");
			this.daily_sessions = sessions;
		}
		//-------------------------------------------------
		public function setCadres(arr:Array):void
		{
			trace("setCadres");
			this.cadres = arr;
		}
		//-------------------------------------------------
		private function resetCadresActifs():void
		{
			trace("resetCadresActifs");
			for (var s:int = 0; s < daily_sessions; s++)
			{
				cadres_actifs[s] = new Array();
			}
		}
		//-------------------------------------------------
		private function enableSeancesBtns():void
		{
			for (var n:int = 0; n < seances_btn.length; n++)
			{
				seances_btn[n].enabled = true;
			}
			option_0.enabled = true;
			option_1.enabled = true;
		}
		//-------------------------------------------------
		private function disableSeancesBtns():void
		{
			for (var n:int = 0; n < seances_btn.length; n++)
			{
				seances_btn[n].enabled = false;
			}
			option_0.enabled = false;
			option_1.enabled = false;
		}
		//-------------------------------------------------
		public function showPanel():void
		{
			trace("showPanel");
			option_0.alpha = 1;
			option_1.alpha = .5;
			option_0.addEventListener(MouseEvent.CLICK, option_btnClicked);
			option_1.addEventListener(MouseEvent.CLICK, option_btnClicked);

			seances_btn.splice(0);
			seances_btn.push(this.seance_0);
			seances_btn.push(this.seance_1);
			seances_btn.push(this.seance_2);
			seances_btn.push(this.seance_3);
			seances_btn.push(this.seance_4);
			for (var n:int = 0; n < seances_btn.length; n++)
			{
				seances_btn[n].alpha = .5;
				if (n != 2)
				{
					seances_btn[n].enabled = true;
					seances_btn[n].addEventListener(MouseEvent.CLICK, seances_btnClicked);
				}
			}
			seances_btn[0].alpha = 1;

			entrees_txt.splice(0);
			entrees_txt.push("08:00");
			entrees_txt.push("10:00");
			entrees_txt.push("");
			entrees_txt.push("13:00");
			entrees_txt.push("15:00");

			sorties_txt.splice(0);
			sorties_txt.push("10:00");
			sorties_txt.push("12:00");
			sorties_txt.push("");
			sorties_txt.push("15:00");
			sorties_txt.push("17:00");

			this.seance1.border = true;
			this.seance2.border = true;

			this.header.x = (this.bg.width - this.header.width)/2;

			this.cat.htmlText = "<b>Cadres Pédagogiques</b>";
			this.seance1.htmlText = entrees_txt[session];
			this.seance2.htmlText = sorties_txt[session];

			this.print_btn.addEventListener(MouseEvent.CLICK, imprimer);
			this.view_btn.addEventListener(MouseEvent.CLICK, viewFile);

			this.txtbg.alpha = .5;
		}
		//-------------------------------------------------
		public function updatePresence():void
		{
			trace("updatePresence isToday", isToday, isPast, isFuture);
			restoreMsg();
			if (isPast)
			{
				trace("isPast", isPast);
				/*cadres_actifs[0].splice(0);
				cadres_actifs[1].splice(0);
				getSavedFile();*/
				getTodayPresence();
			}
			if (isToday)
			{
				getTodayPresence();
			}
			if (isFuture)
			{
				getFuturePresence();
			}
			enableBtns();
		}
		//-------------------------------------------------
		public function getTodayPresence():void
		{
			trace("getTodayPresence");
			resetCadresActifs();
			getCadresActifs();
			//getSavedFile();
			updateRows();
		}
		//-------------------------------------------------
		public function getFuturePresence():void
		{
			trace("getFuturePresence");
			resetCadresActifs();
			getCadresActifs();
			updateRows();
			enableSeancesBtns();
		}
		//-------------------------------------------------
		public function getSession():void
		{
			trace("getSession", curr_day, jours[curr_day-1], curr_jj, curr_mm, curr_yyyy);

			this.today.text = getToday();
			enableSeancesBtns();
			getCadresActifs();
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
		//-------------------------------------------------
		public function getCadresActifs():void
		{
			trace("getCadresActifs, curr_day-1= ", curr_day-1);

			cadres_actifs[session].splice(0);
			if (emploi_xml.children().length() == 0)
			{
				return;
			}

			var xml_list_tous:XMLList = emploi_xml.children();

			for (var t:int = 0; t < xml_list_tous.length(); t++)
			{
				var xml:XML = new XML(xml_list_tous[t]);
				var xml_list:XMLList = xml.children();
				var curr_uid = xml. @ uid;

				var n:int = 0;
				for (var j:int = 0; j < jours.length; j++)
				{
					for (var h:int = 0; h < heures.length; h++)
					{
						for (var c:int = 0; c < cadres.length; c++)
						{
							var isTarget:Boolean = false;
							switch (seances_opt)
							{
								case 0 :
									isTarget = ((j == curr_day-1) && ((session == 0 && h == 0) || (session == 1 && h == 1) || (session == 3 && h == 3) || (session == 4 && h == 4)));
									break;
								case 1 :
									isTarget = ((j == curr_day-1) && ((session == 0 && h < 2) || (session == 1 && h > 2)));
									break;
							}
							//var isTarget:Boolean = ((j == curr_day-1) && ((session == 0 && h < 2) || (session == 1 && h > 2)));
							//var isTarget:Boolean = ((j == curr_day-1) && ((session == 0 && h == 0) || (session == 1 && h == 1) || (session == 2 && h == 3) || (session == 3 && h == 4)));
							if ((isTarget) && (curr_uid == cadres[c]["uid"]) && (xml_list[n]. @ uid == cadres[c]["uid"] && xml_list[n]. @ formateur != ""))
							{
								if (! isListed(cadres[c]["uid"],cadres_actifs[session]))
								{
									cadres_actifs[session].push({"nom":cadres[c]["nom"], "prenom":cadres[c]["prenom"], "uid":cadres[c]["uid"], "entree":"", "sortie":"", "obs":""});
								}
							}
						}
						n++;
					}
				}
			}
			cadres_actifs[session].sortOn("nom", Array.CASEINSENSITIVE);
			updateInfo();
		}
		//-------------------------------------------------;
		public function updateInfo():void
		{
			for (var c:int = 0; c < cadres_actifs[session].length; c++)
			{
				for (var p:int = 0; p<presence.length; p++)
				{
					if (presence[p][curr_mm][curr_jj - 1][session]["uid"] == cadres_actifs[session][c]["uid"])
					{
						cadres_actifs[session][c]["entree"] = presence[p][curr_mm][curr_jj - 1][session]["entree"];
						cadres_actifs[session][c]["sortie"] = presence[p][curr_mm][curr_jj - 1][session]["sortie"];
						cadres_actifs[session][c]["obs"] = presence[p][curr_mm][curr_jj - 1][session]["obs"];
						break;
					}
				}
			}
		}
		//-------------------------------------------------;
		private function option_btnClicked(e:MouseEvent):void
		{
			session = 0;

			var st:String = e.currentTarget.name;
			st = st.substr(st.indexOf("_") + 1);
			seances_opt = int(st);

			trace("seances_opt", seances_opt);

			switch (seances_opt)
			{
				case 0 :
					option_0.alpha = 1;
					option_1.alpha = .5;

					seances_btn[0].label = "Matinée 1";
					seances_btn[1].label = "Matinée 2";

					seances_btn[3].visible = true;
					seances_btn[4].visible = true;

					for (var n:int = 0; n < seances_btn.length; n++)
					{
						seances_btn[n].visible = true;
						seances_btn[n].alpha = .5;
					}







					seances_btn[2].visible = false;
					seances_btn[session].alpha = 1;
					break;

				case 1 :
					option_0.alpha = .5;
					option_1.alpha = 1;

					seances_btn[0].label = "Matinée";
					seances_btn[1].label = "Après Midi";

					seances_btn[3].visible = false;
					seances_btn[4].visible = false;
					break;
			}
			seances_btn[session].alpha = 1;
			trace("session", session);
			updateSeance();
		}
		//-------------------------------------------------;
		private function seances_btnClicked(e:MouseEvent):void
		{
			var st:String = e.currentTarget.name;
			st = st.substr(st.indexOf("_") + 1);
			session = int(st);
			trace("session", session);

			updateSeance();
		}
		//-------------------------------------------------;
		private function updateSeance():void
		{
			trace("updateSeance: seances_opt, session", seances_opt, session);

			for (var n:int = 0; n < seances_btn.length; n++)
			{
				seances_btn[n].alpha = .5;
			}
			seances_btn[session].alpha = 1;
			seances_btn[2].visible = false;

			if (seances_opt == 1 && session == 1)
			{
				seances_btn[3].alpha = 1;
			}

			switch (seances_opt)
			{
				case 0 :
					this.seance1.htmlText = entrees_txt[session];
					this.seance2.htmlText = sorties_txt[session];
					break;

				case 1 :
					switch (session)
					{
						case 0 :
							this.seance1.htmlText = entrees_txt[session] + " - " + sorties_txt[session];
							this.seance2.htmlText = entrees_txt[session + 1] + " - " + sorties_txt[session + 1];
							break;
						case 1 :
							this.seance1.htmlText = entrees_txt[session + 2] + " - " + sorties_txt[session + 2];
							this.seance2.htmlText = entrees_txt[session + 3] + " - " + sorties_txt[session + 3];
							break;
					}
					break;
			}

			getSession();
		}
		//-------------------------------------------------
		private function updateRows():void
		{
			trace("updateRows", cadres_actifs[session].length);
			clearHolder();
			var xx:int = 0;
			var yy:int = 0;

			this.today.text = getToday();

			rows.splice(0);
			for (var f:int = 0; f < cadres_actifs[session].length; f++)
			{
				rows[f] = new RowF();
				rows[f].name = String(f);
				rows[f].nbr.text = String(f + 1);
				rows[f].nom.text = cadres_actifs[session][f]["nom"] + " " + cadres_actifs[session][f]["prenom"];
				rows[f].uid.text = cadres_actifs[session][f]["uid"];
				rows[f].entree.text = cadres_actifs[session][f]["entree"];
				rows[f].sortie.text = cadres_actifs[session][f]["sortie"];
				rows[f].obs.text = cadres_actifs[session][f]["obs"];

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

				rows[f].entree.addEventListener(Event.CHANGE , onChange);
				rows[f].sortie.addEventListener(Event.CHANGE , onChange);
				rows[f].obs.addEventListener(Event.CHANGE , onChange);

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
		private function onChange(e:Event):void
		{
			switch (e.currentTarget.name)
			{
				case "entree" :
					cadres_actifs[session][curr_row]["entree"] = e.currentTarget.text;
					break;
				case "sortie" :
					cadres_actifs[session][curr_row]["sortie"] = e.currentTarget.text;
					break;
				case "obs" :
					cadres_actifs[session][curr_row]["obs"] = e.currentTarget.text;
					break;
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
							cadres_actifs[session][curr_row]["entree"] = e.currentTarget.text;
							break;
						case "sortie" :
							rows[curr_row].sortie.text = new DateTime().getTime();
							cadres_actifs[session][curr_row]["sortie"] = e.currentTarget.text;
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
		//-------------------------------------------------
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
			this.view_btn.enabled = true;
			this.save_btn.enabled = true;
			this.print_btn.enabled = true;
			this.exit_btn.enabled = true;
			this.option_0.enabled = true;
			this.option_1.enabled = true;
			for (var n:int = 0; n < seances_btn.length; n++)
			{
				if (n != 2)
				{
					seances_btn[n].enabled = true;
				}
			}
		}
		//-----------------------------------
		public function disableBtns():void
		{
			this.view_btn.enabled = false;
			this.save_btn.enabled = false;
			this.print_btn.enabled = false;
			this.exit_btn.enabled = false;
			this.option_0.enabled = false;
			this.option_1.enabled = false;
			for (var n:int = 0; n < seances_btn.length; n++)
			{
				seances_btn[n].enabled = false;
			}
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

				updatePresence();
			}
			else
			{
				enableBtns();
			}
		}
		//------------------------------------------------
		function getSavedFile():void
		{
			getFile(curr_jj, curr_mm, curr_yyyy);
		}
		//------------------------------------------------
		function getFile(jj:int, mm:int, yy:int):void
		{
			trace("getFile", jj,mm,yyyy);
			restoreMsg();
			this.msg.text = "Consultation en cours...";

			var get_responder:Responder = new Responder(onGetResult,onGetFault);
			gw.call("Anwar.getFichePresenceF", get_responder, jj, mm, yy);
		}
		//------------------------------------------------
		function onGetResult(reponse:Object):void
		{
			if (reponse != "" && reponse != null)
			{
				fiche_xml = new XML(unescape(reponse.toString()));

				this.msg.text = "Consultation terminée";
				this.msg.autoSize = TextFieldAutoSize.LEFT;
				tw = new TweenLite(this.msg,15,{alpha:0,onComplete:restoreMsg});
				enableBtns();
			}
			else
			{
				fiche_xml = new XML(<fiche />);
			}
			trace("parseFile");
			parseFile();
		}
		//------------------------------------------------
		function onGetFault(reponse:Object):void
		{
			fiche_xml = new XML(<fiche />);

			this.msg.text = "Échec de la Consultation.";
			tw = new TweenLite(this.msg,15,{alpha:0,onComplete:restoreMsg});
			enableBtns();
		}
		//-------------------------------------------------
		private function parseFile():void
		{
			trace("parseFile", fiche_xml);
			var xml_list1:XMLList = fiche_xml.children();
			var xml:XML;

			trace("xml_list1.length()", xml_list1.length());

			if (xml_list1.length() == 0)
			{
				if (isPast)
				{
					tw.kill();
					restoreMsg();
					this.msg.text = "Fiche vide.";
					disableSeancesBtns();
					this.save_btn.enabled = false;
				}
				else
				{
					restoreMsg();
					enableSeancesBtns();
					this.save_btn.enabled = true;
					getSession();
				}
			}
			else
			{
				enableSeancesBtns();
			}
			clearHolder();

			for (var s:int = 0; s < xml_list1.length(); s++)
			{
				xml = new XML(xml_list1[s]);
				var xml_list:XMLList = xml.children();
				var sess:int = xml. @ session;

				for (var f:int = 0; f < xml_list.length(); f++)
				{
					if (isPast)
					{
						for (var c:int = 0; c < cadres.length; c++)
						{
							if (xml_list[f]. @ uid == cadres[c]["uid"])
							{
								cadres_actifs[sess].push({"nom":cadres[c]["nom"], "prenom":cadres[c]["prenom"], "uid":cadres[c]["uid"], "entree":xml_list[f]. @ entree, "sortie":xml_list[f]. @ sortie, "obs":xml_list[f]. @ obs});
								break;
							}
						}
					}

					if (isToday)
					{
						for (c = 0; c < cadres_actifs[sess].length; c++)
						{
							if (xml_list[f]. @ uid == cadres_actifs[sess]["uid"])
							{
								cadres_actifs[sess][c]["entree"] = xml_list[f]. @ entree;
								cadres_actifs[sess][c]["sortie"] = xml_list[f]. @ sortie;
								cadres_actifs[sess][c]["obs"] = xml_list[f]. @ obs;
								break;
							}
						}
					}
				}
			}
			updateRows();
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
			trace(curr_jj, curr_mm, curr_yyyy, session);
			trace(" rows.length",  rows.length);
			trace("this.today.text", this.today.text);

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

			this.save_btn.enabled = false;
			restoreMsg();
			this.msg.text = "Enregistrement en cours...";

			var save_responder:Responder = new Responder(onSaveResult,onSaveFault);
			gw.call("Anwar.addFichePresenceF", save_responder, curr_jj, curr_mm, curr_yyyy, session, escape(new_fiche));
		}
		//------------------------------------------------
		function onSaveResult(reponse:Object):void
		{
			trace("onSaveResult", reponse);

			dispatchEvent(new Event(FichePresenceForm.FILE_SAVED));
		}
		//------------------------------------------------
		function onSaveFault(reponse:Object):void
		{
			trace(reponse);
			this.msg.text = "Échec de l'Enregistrement.";
			tw = new TweenLite(this.msg,15,{alpha:0,onComplete:restoreMsg});
			this.save_btn.enabled = true;
		}
		//------------------------------------------------;
		public function restoreMsg():void
		{
			this.msg.text = "";
			this.msg.alpha = 1;
		}
		//---------------------------------------------------
		private function imprimer(e:MouseEvent = null):void
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
				To convert point to pixel: pixels = point * 96 / 72 = w: 793, h=1122
				*/
				pages[nbr_pages] = new FichePresenceFormPr();
				pages[nbr_pages].cat.htmlText = this.cat.htmlText;

				pages[nbr_pages].seance1.htmlText = this.seance1.htmlText;
				pages[nbr_pages].seance2.htmlText = this.seance2.htmlText;
				pages[nbr_pages].today.text = this.today.text;

				var xx:int = 0;
				var yy:int = 0;

				while (curr_line < max_lines)
				{
					var row:RowFCP = new RowFCP();

					if (counter < rows.length)
					{
						row.nbr.text = String(counter + 1);
						row.nom.text = rows[counter].nom.text;
						row.uid.text = rows[counter].uid.text;
						row.entree.text = rows[counter].entree.text;
						row.sortie.text = rows[counter].sortie.text;

						row.obs.text = rows[counter].obs.text;
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