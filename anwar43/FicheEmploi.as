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
	import fl.controls.Button;
	import flash.display.Sprite;
	import flash.net.NetConnection;
	import flash.events.NetStatusEvent;
	import flash.net.Responder;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import fl.controls.*;

	public class FicheEmploi extends MovieClip
	{
		private var baseUrl:String = "http://www.flash-experts.com/";
		private var amfphp_path:String = baseUrl + "amfphp/gateway.php";
		private var gw:NetConnection = new NetConnection();

		public var isEmploiTous:Boolean = false;
		public var php_load:String;
		public var php_save:String;
		public var cadres:Array = new Array();
		public var cadres_actifs:Array = new Array();
		private var rows:Array = new Array();
		private var counter:int;
		private var nupdates:int;
		private var curr_row:int;
		private var session:String = "M";
		private var max_lines:int = 30;
		private var curr_line:int = 0;
		private var nbr_page:int = 0;

		private var pop:Pop = new Pop();
		private var mois:Array = new Array();
		private var joursParMois:Array = new Array();
		private var jours:Array = new Array();
		private var jours_lb:Array = new Array();

		private var salles_lb:Array = new Array();
		private var salles_tf:Array = new Array();
		private var salles:Array = new Array();

		private var groupes_lb:Array = new Array();
		private var groupes_tf:Array = new Array();
		private var groupes:Array = new Array();

		private var modules:Array = new Array();
		private var modules_lb:Array = new Array();
		private var modules_tf:Array = new Array();

		private var agents_rows:Array = new Array();
		private var formateurs:Array = new Array();
		private var formateurs_rows:Array = new Array();
		private var formateurs_lb:Array = new Array();
		private var formateurs_tf:Array = new Array();

		private var header_Tous:MovieClip = new MovieClip();
		private var formateurs_tous:Array = new Array();
		public var case_tous:Array = new Array();
		public var absence:Array = new Array();

		private var heures:Array = new Array();
		private var heures_lb:Array = new Array();
		private var selected_item:String = "";
		private var selected_obj:MovieClip;

		private var date:Date = new Date();
		private var dd:int = date.getDay();
		private var jj:int = date.getDate();
		private var mm:int = date.getMonth();
		private var yyyy:int = date.getFullYear();

		private var jj1:int = date.getDate();
		private var mm1:int = date.getMonth();
		private var yy1:int = date.getFullYear();

		private var jj2:int = date.getDate();
		private var mm2:int = date.getMonth();
		private var yy2:int = date.getFullYear();

		private var selected_formateur:String = "Tous";
		private var selected_uid:String = "0";
		private var emploi:XML;

		private var orig_periode:String = "";
		private var emploi_xml:XML;
		private var isReady:Boolean = false;
		var daily_sessions:int = 5;

		private var tw:TweenLite;

		//-------------------------------------------------------------------------------------------
		public function FicheEmploi()
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
		//-----------------------------------------------------------------------------------------
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
		public function setDailySessions(sessions:int):void
		{
			this.daily_sessions = sessions;
		}
		//-----------------------------------------------------------------------------------------
		public function setCadres(arr:Array):void
		{
			this.cadres = arr;
			this.cadres.sortOn("nom", Array.CASEINSENSITIVE);
			initFormateurs_cb();
		}
		//-----------------------------------------------------------------------------------------
		public function getCadresActif():Array
		{
			var arr:Array = new Array();
			if (emploi_xml.children().length() == 0)
			{
				return arr;
			}
			var xml_list:XMLList = emploi_xml.children();
			var n:int = 0;

			for (var j:int = 0; j < jours.length; j++)
			{
				for (var h:int = 0; h < heures.length; h++)
				{
					for (var c:int = 0; c < cadres.length; c++)
					{
						if (xml_list[n]. @ formateur == cadres[c]["nom"] + " " + cadres[c]["prenom"])
						{
							var listed:Boolean = false;
							for (var l:int = 0; l < arr.length; l++)
							{
								if (arr[l]["uid"] == cadres[c]["uid"])
								{
									listed = true;
									break;
								}
							}
							if (! listed)
							{
								arr.push({"nom":cadres[c]["nom"], "prenom":cadres[c]["prenom"], "uid":cadres[c]["uid"]});
							}

							break;
						}
					}
					n++;
				}
			}
			arr.sortOn("nom", Array.CASEINSENSITIVE);
			return arr;
		}
		//-----------------------------------------------------------------------------------------
		public function setGroupes(arr:Array):void
		{
			this.groupes = arr;
			this.groupes.sortOn("nom", Array.CASEINSENSITIVE);
		}
		//-----------------------------------------------------------------------------------------;
		public function setSalles(arr:Array):void
		{
			this.salles = arr;
		}
		//-----------------------------------------------------------------------------------------
		public function setModules(arr:Array):void
		{
			this.modules = arr;
		}
		//-----------------------------------------------------------------------------------------
		public function setMois(arr:Array):void
		{
			this.mois = arr;
		}
		//-----------------------------------------------------------------------------------------
		public function setJours(arr:Array):void
		{
			this.jours = arr;
		}
		//-----------------------------------------------------------------------------------------
		public function setJoursParMois(arr:Array):void
		{
			this.joursParMois = arr;
		}
		//-----------------------------------------------------------------------------------------
		public function setHeures(arr:Array):void
		{
			this.heures = arr;
		}
		//-----------------------------------------------------------------------------------------
		public function setAbs(arr:Array):void
		{
			this.absence = arr;
			if (isReady)
			{
				updateEmploiTous();
			}
		}
		//-----------------------------------------------------------------------------------------
		public function setEmploi(emploi_xml:XML):void
		{
			if (emploi_xml == null)
			{
				return;
			}

			this.emploi_xml = emploi_xml;
			orig_periode = emploi_xml. @ semaine;
			orig_periode = orig_periode.substr(orig_periode.indexOf("Du"));

			jj1 = emploi_xml. @ jj1;
			mm1 = emploi_xml. @ mm1;
			yy1 = emploi_xml. @ yy1;

			jj2 = emploi_xml. @ jj2;
			mm2 = emploi_xml. @ mm2;
			yy2 = emploi_xml. @ yy2;
		}
		//-----------------------------------------------------------------------------------------
		public function showPanel():void
		{
			this.one.clear_btn.addEventListener(MouseEvent.CLICK, ClearGrid);
			this.one.new_btn.addEventListener(MouseEvent.CLICK, creerEmploi);
			this.one.print_btn.addEventListener(MouseEvent.CLICK, Imprimer);

			updateListStyle(pop.list, 0x000000);
			updateComboStyle(this.one.jj1_cb);
			updateComboStyle(this.one.jj2_cb);
			updateComboStyle(this.one.mm1_cb);
			updateComboStyle(this.one.mm2_cb);
			updateComboStyle(this.one.yy1_cb);
			updateComboStyle(this.one.yy2_cb);
			updateComboStyle(this.formateurs_cb);

			this.one.jj1_cb.buttonMode = true;
			this.one.jj2_cb.buttonMode = true;

			this.one.mm1_cb.buttonMode = true;
			this.one.mm2_cb.buttonMode = true;

			this.one.yy1_cb.buttonMode = true;
			this.one.yy2_cb.buttonMode = true;

			this.formateurs_cb.buttonMode = true;

			this.one.jj1_cb.addEventListener(Event.CHANGE, onDay1Change);
			this.one.jj2_cb.addEventListener(Event.CHANGE, onDay2Change);

			this.one.mm1_cb.addEventListener(Event.CHANGE, onMonth1Change);
			this.one.mm2_cb.addEventListener(Event.CHANGE, onMonth2Change);

			this.one.yy1_cb.addEventListener(Event.CHANGE, onYear1Change);
			this.one.yy2_cb.addEventListener(Event.CHANGE, onYear2Change);

			this.formateurs_cb.addEventListener(Event.CHANGE, onFormateurChange);

			pop.list.addEventListener(Event.CHANGE, showData);
			pop.close_btn.addEventListener(MouseEvent.CLICK, hidePop);

			this.bg.visible = false;
			this.one.visible = false;
			this.all.visible = true;

			initModules();
			initFormateurs();
			initSalles();
			initGroupes();
			initCombos();
			showEmploi();

			selected_formateur = "Tous";
			selected_uid = "0";
			isEmploiTous = true;

			disableAll();
			showEmploiTous();
		}
		//-----------------------------------------------------------------------------------------
		public function initFormateurs_cb():void
		{
			this.formateurs_cb.removeAll();
			this.formateurs_cb.addItem({data:0, label:"Tous"});
			for (var f:int = 0; f < cadres.length; f++)
			{
				this.formateurs_cb.addItem({data:f+1, label:cadres[f]["nom"] +" "+ cadres[f]["prenom"]});
			}
			this.formateurs_cb.selectedItem = this.formateurs_cb.prompt;
		}
		//-----------------------------------------------------------------------------------------
		public function initCombos():void
		{
			this.one.periode_txt.text = "";

			initFormateurs_cb();

			this.one.mm1_cb.removeAll();
			for (var m:int = 0; m < mois.length; m++)
			{
				this.one.mm1_cb.addItem({data:m, label:mois[m]});
				if (m == mm)
				{
					mm1 = m;
					this.one.mm1_cb.selectedIndex = mm1;
				}
			}

			this.one.mm2_cb.removeAll();
			for (m = 0; m < mois.length; m++)
			{
				this.one.mm2_cb.addItem({data:m, label:mois[m]});
				if (m == mm)
				{
					mm2 = m;
					this.one.mm2_cb.selectedIndex = mm2;
				}
			}

			this.one.jj1_cb.removeAll();
			for (var j:int = 0; j<joursParMois[mm]; j++)
			{
				this.one.jj1_cb.addItem({data:j, label:String(j+1)});
				if (j == jj)
				{
					jj1 = j;
					this.one.jj1_cb.selectedIndex = jj1 - 1;
				}
			}

			this.one.jj2_cb.removeAll();
			for (j = 0; j<joursParMois[mm2]; j++)
			{
				this.one.jj2_cb.addItem({data:j, label:String(j+1)});
				if (j == jj)
				{
					jj2 = j;
					this.one.jj2_cb.selectedIndex = jj2 - 1;
				}
			}

			this.one.yy1_cb.removeAll();
			var nbr_y:int = 0;
			for (var y:int = 2014; y <= yyyy; y++)
			{
				this.one.yy1_cb.addItem({data:nbr_y, label:String(y)});
				this.one.yy2_cb.addItem({data:nbr_y, label:String(y)});
				if (y == yyyy)
				{
					yy1 = y;
					this.one.yy1_cb.selectedIndex = nbr_y;
					yy2 = y;
					this.one.yy2_cb.selectedIndex = nbr_y;
				}
				nbr_y++;
			}
		}
		//-----------------------------------------------------------------------------------------
		function creerEmploi(e:MouseEvent):void
		{
			newGrid();
			initModules();
			initFormateurs();
			initSalles();
			initGroupes();
			showEmploi();
		}
		//-----------------------------------------------------------------------------------------
		function fillEmploi():void
		{
			newGrid();
			this.one.charges_txt.text = "0";
			if (emploi_xml.children().length() == 0)
			{
				return;
			}

			var xml_list_tous:XMLList = emploi_xml.children();
			for (var t:int = 0; t < xml_list_tous.length(); t++)
			{
				var xml:XML = new XML(xml_list_tous[t]);
				var xml_list:XMLList = xml.children();
				var n:int = 0;
				var curr_uid:String = xml. @ uid;
				if (curr_uid == selected_uid)
				{
					for (var j:int = 0; j < jours.length; j++)
					{
						for (var h:int = 0; h < heures.length; h++)
						{
							modules_tf[j][h].txt.htmlText = xml_list[n]. @ module;
							formateurs_tf[j][h].txt.htmlText = xml_list[n]. @ formateur;
							salles_tf[j][h].txt.htmlText = xml_list[n]. @ salle;
							groupes_tf[j][h].txt.htmlText = xml_list[n]. @ groupe;
							n++;
						}
					}

					this.one.periode_txt.htmlText = xml. @ periode;
					this.one.periode_txt.autoSize = TextFieldAutoSize.LEFT;
					this.one.charges_txt.text = String(getNbrHous());
					break;
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		function showEmploi():void
		{
			this.all.visible = false;
			this.one.visible = true;
			initGrid();

			this.one.charges_txt.text = String(getNbrHous());

			placeModules();
			placeFormateurs();
			placeSalles();
			placeGroupes();
		}
		//-----------------------------------------------------------------------------------------
		function onYear1Change(e:Event):void
		{
			yy1 = int(e.target.selectedItem.label);
			updatePeriode();
		}
		//-----------------------------------------------------------------------------------------
		function onMonth1Change(e:Event):void
		{
			mm1 = int(e.target.selectedItem.data);
			this.one.jj1_cb.removeAll();
			for (var j:int = 0; j<joursParMois[mm1]; j++)
			{
				this.one.jj1_cb.addItem({data:j, label:String(j+1)});
			}
			if (joursParMois[mm1] < jj1)
			{
				jj1 = joursParMois[mm1];
			}
			this.one.jj1_cb.selectedIndex = jj1 - 1;

			updatePeriode();
		}
		//-----------------------------------------------------------------------------------------
		function onMonth2Change(e:Event):void
		{
			mm2 = int(e.target.selectedItem.data);
			this.one.jj2_cb.removeAll();
			for (var j:int = 0; j<joursParMois[mm2]; j++)
			{
				this.one.jj2_cb.addItem({data:j, label:String(j+1)});
			}
			if (joursParMois[mm2] < jj2)
			{
				jj2 = joursParMois[mm2];
			}
			this.one.jj2_cb.selectedIndex = jj2 - 1;

			updatePeriode();
		}
		//-----------------------------------------------------------------------------------------
		function onDay1Change(e:Event):void
		{
			jj1 = int(e.target.selectedItem.label);
			updatePeriode();
		}
		//-----------------------------------------------------------------------------------------
		function onYear2Change(e:Event):void
		{
			yy2 = int(e.target.selectedItem.label);
			updatePeriode();
		}
		//-----------------------------------------------------------------------------------------
		function onFormateurChange(e:Event):void
		{
			if (e.target.selectedIndex == 0)
			{
				selected_formateur = "Tous";
				selected_uid = "0";
				isEmploiTous = true;
				disableAll();
				showEmploiTous();
			}
			else
			{
				this.all.visible = false;
				this.one.visible = true;
				isEmploiTous = false;

				this.exit_btn.x = this.one.x + this.one.clear_btn.x;
				this.exit_btn.y = 450;

				this.formateurs_cb.x = this.one.du.x - this.formateurs_cb.width;
				this.formateurs_cb.y = this.one.jj2_cb.y;

				this.formateur.x = this.formateurs_cb.x - this.formateur.width;
				this.formateur.y = this.formateurs_cb.y;

				enableAll();

				selected_formateur = cadres[e.target.selectedIndex - 1]["nom"] + " " + cadres[e.target.selectedIndex - 1]["prenom"];
				selected_uid = cadres[e.target.selectedIndex - 1]["uid"];
				fillEmploi();
			}

			this.one.formateur_txt.htmlText = "De: <b>" + selected_formateur + "</b>";
			this.one.formateur_txt.autoSize = TextFieldAutoSize.LEFT;
		}
		//-----------------------------------------------------------------------------------------
		function onDay2Change(e:Event):void
		{
			jj2 = int(e.target.selectedItem.label);
			updatePeriode();
		}
		//-----------------------------------------------------------------------------------------
		function updatePeriode():void
		{
			var from:Date = new Date(yy1,mm1,jj1);
			var to:Date = new Date(yy2,mm2,jj2);

			var dd1:int = from.getDay();
			jj1 = from.getDate();
			mm1 = from.getMonth();
			yy1 = from.getFullYear();

			var jour1:String = jours[dd1 - 1];
			if (dd1 == 0)
			{
				jour1 = "Dimanche";
			}

			var dd2:int = to.getDay();
			jj2 = to.getDate();
			mm2 = to.getMonth();
			yy2 = to.getFullYear();

			var jour2:String = jours[dd2 - 1];
			if (dd2 == 0)
			{
				jour2 = "Dimanche";
			}

			var dat1:String = (jj1 > 9) ? String(jj1) : "0" + String(jj1);
			var dat2:String = (jj2 > 9) ? String(jj2) : "0" + String(jj2);

			var st1:String = "Du " + dat1 + " " + mois[mm1];
			if (yy1 != yy2)
			{
				st1 = "Du " + dat1 + " " + mois[mm1] + " " + String(yy1);
			}
			var st2:String = " Au " + dat2 + " " + mois[mm2] + " " + String(yy2);

			this.one.periode_txt.htmlText = st1 + st2;
			this.one.periode_txt.autoSize = TextFieldAutoSize.LEFT;
		}
		//-----------------------------------------------------------------------------------------
		function updateHeader():void
		{
			jj1 = int(this.one.jj1_cb.selectedItem.label);
			mm1 = int(this.one.mm1_cb.selectedItem.label);
			yy1 = int(this.one.yy1_cb.selectedItem.label);

			jj2 = int(this.one.jj2_cb.selectedItem.label);
			mm2 = int(this.one.mm2_cb.selectedItem.label);
			yy2 = int(this.one.yy2_cb.selectedItem.label);

			var dat1:String = (jj1 > 9) ? String(jj1) : "0" + String(jj1);
			var dat2:String = (jj2 > 9) ? String(jj2) : "0" + String(jj2);

			var st1:String = "Du " + dat1 + " " + mois[mm1];
			if (yy1 != yy2)
			{
				st1 = "Du " + dat1 + " " + mois[mm1] + " " + String(yy1);
			}
			var st2:String = " Au " + dat2 + " " + mois[mm2] + " " + String(yy2);

			if (selected_uid == "0")
			{
				this.one.periode_txt.htmlText = st1 + st2;
			}
			else
			{
				this.one.periode_txt.htmlText = "De: <b>" + selected_formateur + "</b>\t\t" + st1 + st2;
			}
			this.one.formateur_txt.htmlText = "De: <b>" + selected_formateur + "</b>";
			this.one.formateur_txt.autoSize = TextFieldAutoSize.LEFT;

			this.one.periode_txt.htmlText = st1 + st2;
			this.one.periode_txt.autoSize = TextFieldAutoSize.LEFT;


		}
		//-----------------------------------------------------------------------------------------
		public function showEmploiTous():void
		{
			this.exit_btn.x = this.all.bg.x + this.all.bg.width - this.exit_btn.width - 20;
			this.exit_btn.y = this.all.resize_btn.y;
			this.exit_btn.enabled = true;

			this.formateurs_cb.x = this.all.bg.x + this.formateur.width + (this.all.bg.width - this.formateurs_cb.width)/2;
			this.formateurs_cb.y = this.exit_btn.y;

			this.formateur.x = this.formateurs_cb.x - this.formateur.width;
			this.formateur.y = this.formateurs_cb.y;

			this.one.visible = false;
			this.all.visible = true;
		}
		//-----------------------------------------------------------------------------------------
		public function restoreEmploiTous():void
		{
			this.all.holder.scaleY = 1;
			this.all.sp.source = this.all.holder;
		}
		//-----------------------------------------------------------------------------------------
		public function scaleEmploiTous():void
		{
			while (this.all.holder.height > this.all.sp.height)
			{
				this.all.holder.scaleY -=  .01;
			}
			this.all.sp.source = this.all.holder;
		}
		//-----------------------------------------------------------------------------------------
		public function updateEmploiTous():void
		{
			for (var c:int = 0; c < cadres.length; c++)
			{
				for (var j:int = 0; j<joursParMois[mm]; j++)
				{
					for (var s:int = 0; s<daily_sessions; s++)
					{
						var cause:String = absence[c][mm][j][s]["obs"].toString().toLowerCase();
						cause = cause.substr(0,2);
						cause = trim(cause);
						cause = cause.toUpperCase();
						if (cause != "")
						{
							trace(cadres[c]["nom"], c,mm,j, cause);
							case_tous[c][j].txt.textColor = 0xffffff;
							case_tous[c][j].txt.text = cause;
							case_tous[c][j].txt.background = true;
							switch (cause)
							{
								case "MA" :
									case_tous[c][j].txt.textColor = 0x333333;
									case_tous[c][j].txt.backgroundColor = 0xCCCCCC;
									break;
								case "AB" :
									case_tous[c][j].txt.backgroundColor = 0xFF0000;
									break;
								case "CA" :
									case_tous[c][j].txt.backgroundColor = 0xFF6699;
									break;
								case "CE" :
									case_tous[c][j].txt.backgroundColor = 0x9900CC;
									break;
								case "CS" :
									case_tous[c][j].txt.backgroundColor = 0x000099;
									break;
								default :
									case_tous[c][j].txt.background = false;
									case_tous[c][j].txt.text = cause;
									break;
							}
						}
					}
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		private function trim(st:String):String
		{
			while (st.charAt(0) == ' ')
			{
				st = st.substr(1);
			}
			return st;
		}
		//-----------------------------------------------------------------------------------------
		public function initEmploiTous():void
		{
			for (var e:int = this.all.holder.numChildren-1; e>= 0; e--)
			{
				this.all.holder.removeChildAt(e);
			}
			var xx:int = this.all.sp.x;
			var yy:int = 40;

			var formateurs_header:NformateurTous = new NformateurTous();
			formateurs_header.txt.text = "Jours";
			formateurs_header.txt.autoSize = TextFieldAutoSize.RIGHT;
			formateurs_header.x = xx;
			formateurs_header.y = yy;
			formateurs_header.txt.border = true;
			this.all.addChild(formateurs_header);

			var formateurs_header2:NformateurTous = new NformateurTous();
			formateurs_header2.txt.text = "Formateurs";
			formateurs_header2.x = xx;
			formateurs_header2.y = yy + formateurs_header.height;
			formateurs_header2.txt.border = true;
			this.all.addChild(formateurs_header2);

			xx +=  formateurs_header2.width;
			for (var j:int = 0; j<joursParMois[mm]; j++)
			{
				var case_header:CaseTous = new CaseTous();
				var case_header2:CaseTous = new CaseTous();
				case_header.txt.text = String(j + 1);
				case_header.x = xx;
				case_header.y = yy;
				case_header.txt.border = true;
				this.all.addChild(case_header);

				var date:Date = new Date(yyyy,mm,j + 1);
				var day:int = date.getDay();
				var jst:String = "";
				if (day == 0)
				{
					jst = "Dimanche";
				}
				else
				{
					jst = this.jours[day - 1];
				}
				case_header2.txt.text = jst.substr(0,2);
				case_header2.x = xx;
				case_header2.y = yy + case_header.height;
				case_header2.txt.border = true;
				this.all.addChild(case_header2);

				xx +=  case_header.width;
			}

			xx = 0;
			yy = 0;
			for (var c:int = 0; c < cadres.length; c++)
			{
				xx = 0;
				var case_nbr:CaseTous = new CaseTous();
				case_nbr.txt.text = String(c + 1);
				case_nbr.txt.border = true;
				case_nbr.x = xx;
				case_nbr.y = yy;

				formateurs_tous[c] = new NformateurTous();
				formateurs_tous[c].name = String(c);
				formateurs_tous[c].txt.text = cadres[c]["nom"] + " " + cadres[c]["prenom"];
				formateurs_tous[c].x = xx + case_nbr.width;
				formateurs_tous[c].y = yy;
				formateurs_tous[c].txt.border = true;
				this.all.holder.addChild(case_nbr);
				this.all.holder.addChild(formateurs_tous[c]);

				xx = formateurs_tous[0].width;
				case_tous[c] = new Array();
				for (j = 0; j<joursParMois[mm]; j++)
				{
					date = new Date(yyyy,mm,j + 1);
					day = date.getDay() - 1;

					case_tous[c][j] = new CaseTous();
					case_tous[c][j].name = String(c) + " " + String(j);
					case_tous[c][j].txt.text = "";
					case_tous[c][j].x = xx;
					case_tous[c][j].y = yy;
					case_tous[c][j].txt.border = true;
					if (day == -1)
					{
						case_tous[c][j].txt.background = true;
						case_tous[c][j].txt.backgroundColor = formateurs_header.txt.textColor;
						case_tous[c][j].txt.textColor = this.one.header.textColor;
						case_tous[c][j].txt.text = "D";
					}
					if (Acour(c,day))
					{
						case_tous[c][j].txt.background = true;
						case_tous[c][j].txt.backgroundColor = this.one.header.textColor;
						case_tous[c][j].txt.textColor = formateurs_header.txt;
						case_tous[c][j].txt.text = "T";
					}

					var cause:String = absence[c][mm][j][0]["obs"].toString().toLowerCase();
					if (cause == "")
					{
						cause = absence[c][mm][j][1]["obs"].toString().toLowerCase();
					}
					if (cause == "")
					{
						cause = absence[c][mm][j][2]["obs"].toString().toLowerCase();
					}
					if (cause == "")
					{
						cause = absence[c][mm][j][3]["obs"].toString().toLowerCase();
					}
					//if (absence[c][mm][j] != "")
					if (cause != "")
					{

						//var cause:String = absence[c][mm][j].toString().toLowerCase();
						cause = cause.substr(0,2);
						cause = cause.toUpperCase();
						trace(cadres[c]["nom"], c,mm,j, cause);
						case_tous[c][j].txt.textColor = 0xffffff;
						case_tous[c][j].txt.text = cause;
						case_tous[c][j].txt.background = true;
						switch (cause)
						{
							case "MA" :
								case_tous[c][j].txt.textColor = 0xffffff;
								case_tous[c][j].txt.backgroundColor = 0x000000;
								break;
							case "AB" :
								case_tous[c][j].txt.backgroundColor = 0xFF0000;
								break;
							case "CA" :
								case_tous[c][j].txt.backgroundColor = 0xFF6699;
								break;
							case "CE" :
								case_tous[c][j].txt.backgroundColor = 0xFF0099;
								break;
							default :
								case_tous[c][j].txt.background = false;
								case_tous[c][j].txt.text = "";
								break;
						}
					}
					this.all.holder.addChild(case_tous[c][j]);
					xx +=  case_tous[c][j].width;
				}
				yy +=  formateurs_tous[c].trans.height;
			}
			this.all.sp.source = this.all.holder;
			isReady = true;
		}
		//-------------------------------------------------
		public function Acour(c:int, day:int):Boolean
		{
			if (emploi_xml.children().length() == 0)
			{
				return false;
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
						//if ((j == day) && (xml_list[n]. @ formateur == cadres[c]["nom"] + " " + cadres[c]["prenom"]))
						if ((j == day) && (xml_list[n]. @ uid == cadres[c]["uid"] && xml_list[n]. @ formateur !=""))
						{
							return true;
						}
						n++;
					}
				}
			}

			return false;
		}
		//-----------------------------------------------------------------------------------------
		function placeModules():void
		{
			var xx:int;
			for (var j:int = 0; j < jours.length; j++)
			{
				xx = heures_lb[0].x;
				for (var h:int = 0; h < heures.length; h++)
				{
					modules_tf[j][h].x = xx;
					modules_tf[j][h].y = modules_lb[j].y - 5;
					xx +=  heures_lb[h].width;
					this.one.addChild(modules_tf[j][h]);
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		function placeFormateurs():void
		{
			var xx:int;
			for (var j:int = 0; j < jours.length; j++)
			{
				xx = heures_lb[0].x;
				for (var h:int = 0; h < heures.length; h++)
				{
					formateurs_tf[j][h].visible = false;
					formateurs_tf[j][h].x = xx;
					formateurs_tf[j][h].y = formateurs_lb[j].y - 20;
					xx +=  heures_lb[h].width;
					this.one.addChild(formateurs_tf[j][h]);
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		function placeSalles():void
		{
			var xx:int;
			for (var j:int = 0; j < jours.length; j++)
			{
				xx = heures_lb[0].x;
				for (var h:int = 0; h < heures.length; h++)
				{
					salles_tf[j][h].x = xx;
					salles_tf[j][h].y = salles_lb[j].y;
					xx +=  heures_lb[h].width;
					this.one.addChild(salles_tf[j][h]);
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		function placeGroupes():void
		{
			var xx:int;
			for (var j:int = 0; j < jours.length; j++)
			{
				xx = heures_lb[0].x;
				for (var h:int = 0; h < heures.length; h++)
				{
					groupes_tf[j][h].x = xx;
					groupes_tf[j][h].y = groupes_lb[j].y;
					xx +=  heures_lb[h].width;
					this.one.addChild(groupes_tf[j][h]);
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		function clearBg():void
		{
			for (var c:int = this.one.numChildren -1; c>0; c--)
			{
				var n1:int = this.one.getChildAt(c).name.indexOf("Module_");
				var n2:int = this.one.getChildAt(c).name.indexOf("Formateur_");
				var n3:int = this.one.getChildAt(c).name.indexOf("Groupe_");
				if (n1 != -1 || n2 != -1 || n3 != -1)
				{
					this.one.removeChildAt(c);
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		function initGrid():void
		{
			clearBg();

			//add hours
			var xx:int = new Hjour().width + new Hmodule().width -25;
			var yy:int = this.one.charges_txt.y + this.one.charges_txt.height + 10;
			for (n = 0; n < heures.length; n++)
			{
				heures_lb[n] = new Hheure();
				heures_lb[n].txt.text = heures[n];
				heures_lb[n].x = xx;
				heures_lb[n].y = yy;
				if (n == 2)
				{
					heures_lb[n].width = 50;
				}
				xx +=  heures_lb[n].width;
				this.one.addChild(heures_lb[n]);
			}

			//add days
			xx = 0;
			yy = heures_lb[0].y + heures_lb[0].height;
			for (var n:int = 0; n < jours.length; n++)
			{
				modules_lb[n] = new Hmodule();
				formateurs_lb[n] = new Hformateur();
				salles_lb[n] = new Hsalle();
				groupes_lb[n] = new Hgroupe();

				jours_lb[n] = new Hjour();
				jours_lb[n].txt.text = jours[n];
				jours_lb[n].x = xx;
				jours_lb[n].y = yy;

				modules_lb[n].x = jours_lb[n].x + jours_lb[n].width - 30;
				modules_lb[n].y = jours_lb[n].y + 5;

				formateurs_lb[n].visible = false;
				formateurs_lb[n].x = modules_lb[n].x;
				formateurs_lb[n].y = modules_lb[n].y + modules_lb[n].height * 2;

				groupes_lb[n].x = modules_lb[n].x;
				groupes_lb[n].y = modules_lb[n].y + modules_lb[n].height * 2 - 2;

				salles_lb[n].x = modules_lb[n].x;
				salles_lb[n].y = groupes_lb[n].y + groupes_lb[n].height - 2;

				yy +=  jours_lb[n].height;
				this.one.addChild(jours_lb[n]);
				this.one.addChild(modules_lb[n]);
				this.one.addChild(formateurs_lb[n]);
				this.one.addChild(salles_lb[n]);
				this.one.addChild(groupes_lb[n]);

			}

			//add grid

			for (n = 0; n < heures.length; n++)
			{
				var y1:int = jours_lb[0].y;
				var x1:int = heures_lb[n].x;
				var ww:int = .5;
				var hh:int = jours_lb[2].height * jours.length;

				var vline:Shape = new Shape();
				vline.graphics.lineStyle(2, 0x000000, .3);
				vline.graphics.drawRect(x1, y1, ww, hh);
				this.one.addChild(vline);

				if (n == heures.length - 1)
				{
					x1 = heures_lb[n].x + heures_lb[n].width;
					vline = new Shape();
					vline.graphics.lineStyle(2, 0x000000, .3);
					vline.graphics.drawRect(x1, y1, ww, hh);
					this.one.addChild(vline);
				}
			}

			for (n = 0; n < jours.length; n++)
			{
				x1 = heures_lb[0].x;
				y1 = jours_lb[n].y;
				ww = heures_lb[0].width * 4 + heures_lb[2].width;
				hh = .5;

				var hline:Shape = new Shape();
				hline.graphics.lineStyle(2, 0x000000, .3);
				hline.graphics.drawRect(x1, y1, ww, hh);
				this.one.addChild(hline);

				if (n == jours.length - 1)
				{
					y1 = jours_lb[n].y + jours_lb[n].height;
					hline = new Shape();
					hline.graphics.lineStyle(2, 0x000000, .3);
					hline.graphics.drawRect(x1, y1, ww, hh);
					this.one.addChild(hline);
				}
			}

			this.one.yy1_cb.x = this.one.bg.x + this.one.bg.width - this.one.yy1_cb.width - 10;
			this.one.mm1_cb.x = this.one.yy1_cb.x - (this.one.mm1_cb.width + 10);
			this.one.jj1_cb.x = this.one.mm1_cb.x - (this.one.jj1_cb.width + 10);

			this.one.jj1_cb.y = 10;
			this.one.mm1_cb.y = 10;
			this.one.yy1_cb.y = 10;

			this.one.jj2_cb.y = this.one.jj1_cb.y + this.one.jj1_cb.height + 5;
			this.one.mm2_cb.y = this.one.jj2_cb.y;
			this.one.yy2_cb.y = this.one.jj2_cb.y;

			this.one.jj2_cb.x = this.one.jj1_cb.x;
			this.one.mm2_cb.x = this.one.mm1_cb.x;
			this.one.yy2_cb.x = this.one.yy1_cb.x;

			this.one.addChild(this.one.mm1_cb);
			this.one.addChild(this.one.mm2_cb);

			this.one.du.x = this.one.jj1_cb.x - this.one.du.width;
			this.one.du.y = this.one.jj1_cb.y + 3;
			this.one.au.x = this.one.du.x;
			this.one.au.y = this.one.jj2_cb.y + 3;

			this.one.clear_btn.x = heures_lb[heures.length - 1].x + heures_lb[heures.length - 1].width + 10;
			this.one.save_btn.x = this.one.clear_btn.x;
			this.one.new_btn.x = this.one.clear_btn.x;
			this.one.print_btn.x = this.one.clear_btn.x;

			this.one.msg.x = this.one.print_btn.x;
			this.one.msg.y = this.one.bg.y + this.one.bg.height - this.one.msg.height;

		}
		//-----------------------------------------------------------------------------------------
		function initModules():void
		{
			for (var j:int = 0; j < jours.length; j++)
			{
				modules_tf[j] = new Array();
				for (var h:int = 0; h < heures.length; h++)
				{
					modules_tf[j][h] = new Nmodule();
					modules_tf[j][h].name = "Module_" + String(j) + " " + String(h);
					modules_tf[j][h].txt.text = "Module";
					if (h == 2)
					{
						modules_tf[j][h].txt.text = "";
					}

					modules_tf[j][h].trans.addEventListener(MouseEvent.CLICK, onModuleClicked);
					modules_tf[j][h].trans.addEventListener(MouseEvent.MOUSE_OVER, overModule);
					modules_tf[j][h].trans.addEventListener(MouseEvent.MOUSE_OUT, outModule);
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		function onModuleClicked(e:MouseEvent):void
		{
			pop.list.removeAll();
			pop.list.addItem({label:"", data:m});
			for (var m:int = 0; m < modules.length; m++)
			{
				pop.list.addItem({label:modules[m]["nom"], data:m});
			}
			updateListStyle(pop.list, modules_tf[0][0].txt.textColor);
			showPopup(e.currentTarget.parent);
		}
		//-----------------------------------------------------------------------------------------
		function overModule(e:MouseEvent):void
		{
			e.currentTarget.parent.txt.htmlText = "<b>" + e.currentTarget.parent.txt.text + "</b>";
		}
		//-----------------------------------------------------------------------------------------
		function outModule(e:MouseEvent):void
		{
			e.currentTarget.parent.txt.htmlText = e.currentTarget.parent.txt.text;
		}
		//-----------------------------------------------------------------------------------------
		function initFormateurs():void
		{
			for (var j:int = 0; j < jours.length; j++)
			{
				formateurs_tf[j] = new Array();
				for (var h:int = 0; h < heures.length; h++)
				{
					formateurs_tf[j][h] = new Nformateur();
					formateurs_tf[j][h].name = "Formateur_" + String(j) + " " + String(h);
					formateurs_tf[j][h].txt.text = "Formateur";
					if (h == 2)
					{
						formateurs_tf[j][h].txt.text = "";
					}
					formateurs_tf[j][h].trans.addEventListener(MouseEvent.CLICK, onFormateurClicked);
					formateurs_tf[j][h].trans.addEventListener(MouseEvent.MOUSE_OVER, overFormateur);
					formateurs_tf[j][h].trans.addEventListener(MouseEvent.MOUSE_OUT, outFormateur);
				}
			}
		}
		//-----------------------------------------------------------------------------------------;
		function onFormateurClicked(e:MouseEvent):void
		{
			pop.list.removeAll();
			pop.list.addItem({label:"", data:m});
			for (var m:int = 0; m < cadres.length; m++)
			{
				pop.list.addItem({label:cadres[m]["nom"] +" "+ cadres[m]["prenom"], data:m});
			}
			updateListStyle(pop.list, formateurs_tf[0][0].txt.textColor);
			showPopup(e.currentTarget.parent);
		}
		//-----------------------------------------------------------------------------------------
		function overFormateur(e:MouseEvent):void
		{
			e.currentTarget.parent.txt.htmlText = "<b>" + e.currentTarget.parent.txt.text + "</b>";
		}
		//-----------------------------------------------------------------------------------------
		function outFormateur(e:MouseEvent):void
		{
			e.currentTarget.parent.txt.htmlText = e.currentTarget.parent.txt.text;
		}
		//-----------------------------------------------------------------------------------------
		function initSalles():void
		{
			for (var j:int = 0; j < jours.length; j++)
			{
				salles_tf[j] = new Array();
				for (var h:int = 0; h < heures.length; h++)
				{
					salles_tf[j][h] = new Nsalle();
					salles_tf[j][h].name = "Salle_" + String(j) + " " + String(h);
					salles_tf[j][h].txt.text = "Salle";
					if (h == 2)
					{
						salles_tf[j][h].txt.text = "";
					}
					salles_tf[j][h].trans.addEventListener(MouseEvent.CLICK, onSalleClicked);
					salles_tf[j][h].trans.addEventListener(MouseEvent.MOUSE_OVER, overSalle);
					salles_tf[j][h].trans.addEventListener(MouseEvent.MOUSE_OUT, outSalle);
				}
			}
		}
		//-----------------------------------------------------------------------------------------;
		function onSalleClicked(e:MouseEvent):void
		{
			pop.list.removeAll();
			pop.list.addItem({label:"", data:m});
			for (var m:int = 0; m < salles.length; m++)
			{
				if (isAvailable("Salle",salles[m]["nom"],e.currentTarget.parent.name))
				{
					pop.list.addItem({label:salles[m]["nom"], data:m});
				}
			}
			updateListStyle(pop.list, salles_tf[0][0].txt.textColor);
			showPopup(e.currentTarget.parent);
		}
		//-----------------------------------------------------------------------------------------
		function overSalle(e:MouseEvent):void
		{
			e.currentTarget.parent.txt.htmlText = "<b>" + e.currentTarget.parent.txt.text + "</b>";
		}
		//-----------------------------------------------------------------------------------------
		function outSalle(e:MouseEvent):void
		{
			e.currentTarget.parent.txt.htmlText = e.currentTarget.parent.txt.text;
		}
		//-----------------------------------------------------------------------------------------
		function initGroupes():void
		{
			for (var j:int = 0; j < jours.length; j++)
			{
				groupes_tf[j] = new Array();
				for (var h:int = 0; h < heures.length; h++)
				{
					groupes_tf[j][h] = new Ngroupe();
					groupes_tf[j][h].name = "Groupe_" + String(j) + " " + String(h);
					groupes_tf[j][h].txt.text = "Groupe";
					if (h == 2)
					{
						groupes_tf[j][h].txt.text = "";
					}
					groupes_tf[j][h].trans.addEventListener(MouseEvent.CLICK, onGroupeClicked);
					groupes_tf[j][h].trans.addEventListener(MouseEvent.MOUSE_OVER, overGroupe);
					groupes_tf[j][h].trans.addEventListener(MouseEvent.MOUSE_OUT, outGroupe);
				}
			}
		}
		//-----------------------------------------------------------------------------------------;
		function onGroupeClicked(e:MouseEvent):void
		{
			pop.list.removeAll();
			pop.list.addItem({label:"", data:m});
			for (var m:int = 0; m < groupes.length; m++)
			{
				if (isAvailable("Groupe",groupes[m]["nom"],e.currentTarget.parent.name))
				{
					pop.list.addItem({label:groupes[m]["nom"], data:m});
				}
			}
			updateListStyle(pop.list, groupes_tf[0][0].txt.textColor);
			showPopup(e.currentTarget.parent);
		}
		//-----------------------------------------------------------------------------------------
		function overGroupe(e:MouseEvent):void
		{
			e.currentTarget.parent.txt.htmlText = "<b>" + e.currentTarget.parent.txt.text + "</b>";
		}
		//-----------------------------------------------------------------------------------------
		function outGroupe(e:MouseEvent):void
		{
			e.currentTarget.parent.txt.htmlText = e.currentTarget.parent.txt.text;
		}
		//-----------------------------------------------------------------------------------------;
		function showPopup(obj:MovieClip):void
		{
			pop.visible = true;
			selected_obj = obj;

			var st:String = obj.name;
			st = st.substr(st.indexOf("_") + 1);

			var n1:int = int(st.substr(0,1));
			var n2:int = int(st.substr(2,1));

			var xx = salles_tf[n1][n2].x;
			var yy = salles_tf[n1][n2].y + salles_tf[n1][n2].height;

			if (n1 >= 4)
			{
				yy = modules_tf[n1][n2].y - pop.height;
			}

			pop.x = xx;
			pop.y = yy;
			this.one.addChild(pop);
		}

		//----------------------------------------------------------------
		function isAvailable(target:String, _nom:String, _jourHeure:String):Boolean
		{
			_jourHeure = _jourHeure.substr(_jourHeure.indexOf("_") + 1);
			var nrow:int = int(_jourHeure.substr(0,_jourHeure.indexOf(" ")));
			var ncol:int = int(_jourHeure.substr(_jourHeure.indexOf(" ") + 1,_jourHeure.length));

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
						if ((j == nrow) && (h == ncol))
						{
							/*if (xml_list[n]. @ formateur == selected_formateur)
							{
							return false;
							}*/
							if (target == "Groupe" && xml_list[n]. @ groupe == _nom)
							{
								return false;
							}
							if (target == "Salle" && xml_list[n]. @ salle == _nom)
							{
								return false;
							}
						}
						n++;
					}
				}
			}

			return true;
		}
		//----------------------------------------------------------------
		function getNbrHous():int
		{
			var nh:int = 0;
			for (var j:int = 0; j < jours.length; j++)
			{
				for (var h:int = 0; h < heures.length; h++)
				{
					if (formateurs_tf[j][h].txt.text != "Formateur" && formateurs_tf[j][h].txt.text != "")
					{
						nh++;
					}
				}
			}

			return nh*2;
		}
		//-----------------------------------------------------------------------------------------
		function showData(e:Event):void
		{
			var st:String = selected_obj.name;
			st = st.substr(st.indexOf("_") + 1);
			var nrow:int = int(st.substr(0,st.indexOf(" ")));
			var ncol:int = int(st.substr(st.indexOf(" ") + 1,st.length));
			formateurs_tf[nrow][ncol].txt.text = selected_formateur;
			selected_item = e.target.selectedItem.label;
			selected_obj.txt.text = e.target.selectedItem.label;
			this.one.charges_txt.text = String(getNbrHous());

			if (selected_obj.name.indexOf("Groupe_") != -1 && selected_obj.txt.text == "")
			{
				formateurs_tf[nrow][ncol].txt.text = "";
				modules_tf[nrow][ncol].txt.text = "";
				salles_tf[nrow][ncol].txt.text = "";
			}
		}
		//-----------------------------------------------------------------------------------------
		public function hidePop(e:MouseEvent=null):void
		{
			pop.visible = false;
		}
		//-----------------------------------------------------------------------------------------
		function newGrid(e:MouseEvent=null):void
		{
			pop.visible = false;
			for (var j:int = 0; j < jours.length; j++)
			{
				for (var h:int = 0; h < heures.length; h++)
				{
					modules_tf[j][h].txt.text = "";
					formateurs_tf[j][h].txt.text = "";
					salles_tf[j][h].txt.text = "";
					groupes_tf[j][h].txt.text = "";
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		function ClearGrid(e:MouseEvent=null):void
		{
			pop.visible = false;
			for (var j:int = 0; j < jours.length; j++)
			{
				for (var h:int = 0; h < heures.length; h++)
				{
					if (modules_tf[j][h].txt.text == "Module")
					{
						modules_tf[j][h].txt.text = "";
					}
					if (formateurs_tf[j][h].txt.text == "Formateur")
					{
						formateurs_tf[j][h].txt.text = "";
					}
					if (salles_tf[j][h].txt.text == "Salle")
					{
						salles_tf[j][h].txt.text = "";
					}
					if (groupes_tf[j][h].txt.text == "Groupe")
					{
						groupes_tf[j][h].txt.text = "";
					}
				}
			}
		}
		//-----------------------------------------------------------------------------------------
		function updateButtonStyle(btn:Button):void
		{
			var tf:TextFormat = new TextFormat();
			tf.size = 18;
			tf.color = 0x000000;
			tf.font = "Times New Roman";
			btn.setStyle("textFormat", tf);
			btn.setSize(btn.width, 35);
			btn.useHandCursor = true;
		}
		//----------------------------------------------------------------------------
		function updateListStyle(list:List, color:uint):void
		{
			var tf:TextFormat = new TextFormat();
			//tf.size = 16;
			tf.color = color;
			//tf.font = "Times New Roman";

			list.setRendererStyle("textFormat", tf);
		}
		//----------------------------------------------------------------------------
		function updateComboStyle(obj:Object):void
		{

			var tf:TextFormat = new TextFormat();
			/*tf.size = 16;
			tf.color = 0x000000;
			tf.font = "Times New Roman";*/
			tf.bold = true;

			//Increase the main TextField's font size of your ComboBox
			obj.textField.setStyle("textFormat", tf);

			//Increase the font size of dropDownList items;
			obj.dropdown.setRendererStyle("textFormat", tf);

		}
		//----------------------------------------------------------------------------;
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
		//-----------------------------------------------------------------------------------------
		public function enregistrer_emploi():void
		{
			disableAll();
			pop.visible = false;
			ClearGrid();

			emploi = new XML( <emploi /> );
			emploi. @ uid = selected_uid;
			emploi. @ periode = this.one.periode_txt.text;
			emploi. @ jj1 = jj1;
			emploi. @ mm1 = mm1;
			emploi. @ yy1 = yy1;
			emploi. @ jj2 = jj2;
			emploi. @ mm2 = mm2;
			emploi. @ yy2 = yy2;

			for (var j:int = 0; j < jours.length; j++)
			{
				for (var h:int = 0; h < heures.length; h++)
				{
					var session_node:XML = new XML (<session />);
					session_node. @ module = modules_tf[j][h].txt.text;
					session_node. @ formateur = formateurs_tf[j][h].txt.text;
					session_node. @ uid = (formateurs_tf[j][h].txt.text != "") ? selected_uid:"";
					session_node. @ salle = salles_tf[j][h].txt.text;
					session_node. @ groupe = groupes_tf[j][h].txt.text;
					emploi.appendChild(session_node);
				}
			}

			restoreMsg();
			this.one.msg.textColor = 0xffffff;
			this.one.msg.text = "Enregistrement en cours...";
			var save_responder:Responder = new Responder(onSaveEmploiResult,onSaveEmploiFault);
			gw.call("Anwar.addEmploi", save_responder, selected_uid, escape(emploi));
		}
		//----------------------------------------------------------------------------------------
		function onSaveEmploiResult(reponse:Object):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		//----------------------------------------------------------------------------------------
		function onSaveEmploiFault(reponse:Object):void
		{
			this.one.msg.text = "Échec de l'Enregistrement.";
			tw = new TweenLite(this.one.msg,15,{alpha:0,onComplete:restoreMsg});

			enableAll();
		}
		//----------------------------------------------------------------------------------------
		public function enableJours():void
		{
			this.one.jj1_cb.enabled = true;
			this.one.jj2_cb.enabled = true;
		}
		//----------------------------------------------------------------------------------------
		public function disableJours():void
		{
			this.one.jj1_cb.enabled = false;
			this.one.jj2_cb.enabled = false;
		}
		//----------------------------------------------------------------------------------------
		public function enableAll():void
		{
			if (isEmploiTous)
			{
				return;
			}
			restoreMsg();
			this.one.save_btn.enabled = true;
			this.one.print_btn.enabled = true;
			this.one.clear_btn.enabled = true;
			this.one.new_btn.enabled = true;
			this.exit_btn.enabled = true;

			enableJours();
			this.one.mm1_cb.enabled = true;
			this.one.mm2_cb.enabled = true;
			this.one.yy1_cb.enabled = true;
			this.one.yy2_cb.enabled = true;
			this.formateurs_cb.enabled = true;
		}
		//----------------------------------------------------------------------------------------
		public function disableAll():void
		{
			this.one.save_btn.enabled = false;
			this.one.print_btn.enabled = false;
			this.one.clear_btn.enabled = false;
			this.one.new_btn.enabled = false;
			this.exit_btn.enabled = false;

			disableJours();
		}
		//----------------------------------------------------------------------------------------
		public function restoreMsg():void
		{
			if (tw != null)
			{
				tw.kill();
			}
			this.one.msg.textColor = 0xffffff;
			this.one.msg.text = "";
			this.one.msg.alpha = 1;
		}
		//---------------------------------------------------
		private function Imprimer(e:MouseEvent):void
		{
			/*
			To convert pixel to point: points = pixel * 72 / 96
			To convert point to pixel: pixels = point * 96 / 72
			w = 595 * 96/72 = 761.6
			h = 842 * 96/72 = 1122.8
			*/
			var page:EmploiPr = new EmploiPr();
			page.formateur.htmlText = "De: <b>" + selected_formateur + "</b>";
			page.periode.text = this.one.periode_txt.text;

			var xx:int = 0;
			var yy:int = 0;

			for (var j:int = 0; j < jours.length; j++)
			{
				var row:RowEmploiPr = new RowEmploiPr();

				row.x = xx;
				row.y = yy;

				row.j0.htmlText = "<b>" + jours[j] + "</b>";
				row.m_0.text = modules_tf[j][0].txt.text;
				row.m_1.text = modules_tf[j][1].txt.text;
				row.m_2.text = modules_tf[j][3].txt.text;
				row.m_3.text = modules_tf[j][4].txt.text;

				row.g_0.text = groupes_tf[j][0].txt.text;
				row.g_1.text = groupes_tf[j][1].txt.text;
				row.g_2.text = groupes_tf[j][3].txt.text;
				row.g_3.text = groupes_tf[j][4].txt.text;

				row.s_0.text = salles_tf[j][0].txt.text;
				row.s_1.text = salles_tf[j][1].txt.text;
				row.s_2.text = salles_tf[j][3].txt.text;
				row.s_3.text = salles_tf[j][4].txt.text;

				yy +=  row.height;

				page.holder.addChild(row);
			}
			page.footer.x = xx + 20;
			page.footer.y = yy + 10;
			page.holder.addChild(page.footer);


			var ferPrinter:Printing = new Printing();
			ferPrinter.printLandscape(page);

		}
		//-------------------------------------------------------------------------------------------

	}

}