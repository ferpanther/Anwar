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

	public class FicheEmploiMensuelle extends MovieClip
	{
		public var cadres:Array = new Array();
		private var rows:Array = new Array();
		private var pages:Array = new Array();
		private var lines:Array = new Array();
		private var max_lines:int = 26;
		private var curr_line:int = 0;
		private var curr_cadre:int = 0;
		private var nbr_pages:int = 0;

		private var mois:Array = new Array();
		private var joursParMois:Array = new Array();
		private var jours:Array = new Array();
		private var jours_lb:Array = new Array();

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

		private var orig_periode:String = "";
		private var cat:String = "";
		private var daily_sessions:int = 1;
		private var emploi_xml:XML;

		private var ca:int = 0;
		private var ce:int = 0;
		private var cs:int = 0;
		private var ma:int = 0;
		private var ab:int = 0;
		private var di:int = 0;

		private var tw:TweenLite;

		//-------------------------------------------------------------------------------------------
		public function FicheEmploiMensuelle()
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
		public function setAbs(arr:Array):void
		{
			this.absence = arr;
		}
		//-----------------------------------------------------------------------------------------
		public function setCat(cat:String):void
		{
			this.cat = cat;
		}
		//-----------------------------------------------------------------------------------------
		public function setEmploi(emploi:XML):void
		{
			if (emploi == null)
			{
				return;
			}

			emploi_xml = emploi;
		}
		//-----------------------------------------------------------------------------------------
		public function setHeures(arr:Array):void
		{
			this.heures = arr;
		}
		//-----------------------------------------------------------------------------------------
		public function showPanel():void
		{
			updateComboStyle(mm1_cb);
			updateComboStyle(yy1_cb);

			this.mm1_cb.buttonMode = true;
			this.yy1_cb.buttonMode = true;

			this.mm1_cb.addEventListener(Event.CHANGE, onMonth1Change);
			this.yy1_cb.addEventListener(Event.CHANGE, onYear1Change);

			this.print_btn.addEventListener(MouseEvent.CLICK, Imprimer);
			this.view_btn.addEventListener(MouseEvent.CLICK, updateEmploiTous);

			initCombos();

		}
		//-----------------------------------------------------------------------------------------
		public function enableAll():void
		{
			this.mm1_cb.enabled = true;
			this.yy1_cb.enabled = true;
			this.print_btn.enabled = true;
			this.view_btn.enabled = true;
			this.exit_btn.enabled = true;
		}
		//-----------------------------------------------------------------------------------------
		public function disableAll():void
		{
			this.mm1_cb.enabled = false;
			this.yy1_cb.enabled = false;
			this.print_btn.enabled = false;
			this.view_btn.enabled = false;
			this.exit_btn.enabled = false;
		}
		//-----------------------------------------------------------------------------------------
		public function updateEmploiTous(e:MouseEvent=null):void
		{
			disableAll();
			this.msg.text = "";
			this.periode_txt.htmlText = mois[mm1] + " " + String(yy1);
			initEmploiTous();
			
		}
		//-----------------------------------------------------------------------------------------
		public function initCombos():void
		{
			this.mm1_cb.removeAll();
			for (var m:int = 0; m < 12; m++)
			{
				this.mm1_cb.addItem({data:m, label:mois[m]});
				if (m == mm)
				{
					mm1 = m;
					this.mm1_cb.selectedIndex = mm1;
				}
			}

			this.yy1_cb.removeAll();
			var nbr_y:int = 0;
			for (var y:int = 2014; y <= yyyy; y++)
			{
				this.yy1_cb.addItem({data:nbr_y, label:String(y)});
				if (y == yyyy)
				{
					yy1 = y;
					this.yy1_cb.selectedIndex = nbr_y;
				}
				nbr_y++;
			}
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
			updatePeriode();
		}
		//-----------------------------------------------------------------------------------------
		function updatePeriode():void
		{
			var from:Date = new Date(yy1,mm1,1);

			var dd1:int = from.getDay();
			jj1 = from.getDate();
			mm1 = from.getMonth();
			yy1 = from.getFullYear();

			var jour1:String = jours[dd1 - 1];
			if (dd1 == 0)
			{
				jour1 = "Dimanche";
			}
		}
		//-----------------------------------------------------------------------------------------
		public function restoreEmploiTous():void
		{
			this.holder.scaleY = 1;
			this.sp.source = this.holder;
		}
		//-----------------------------------------------------------------------------------------
		public function scaleEmploiTous():void
		{
			while (this.holder.height > this.sp.height)
			{
				this.holder.scaleY -=  .01;
			}
			this.sp.source = this.holder;
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
			for (var e:int = this.numChildren-1; e>= 0; e--)
			{
				if (this.getChildByName("formateurs_header") != null)
				{
					this.removeChild(this.getChildByName("formateurs_header"));
				}
				if (this.getChildByName("formateurs_header2") != null)
				{
					this.removeChild(this.getChildByName("formateurs_header2"));
				}
				if (this.getChildByName("case_header") != null)
				{
					this.removeChild(this.getChildByName("case_header"));
				}
				if (this.getChildByName("case_header2") != null)
				{
					this.removeChild(this.getChildByName("case_header2"));
				}
			}
			for (e = this.holder.numChildren-1; e>= 0; e--)
			{
				this.holder.removeChildAt(e);
			}
			var xx:int = this.sp.x;
			var yy:int = this.header.y + this.header.height + 20;

			var formateurs_header:NformateurTous = new NformateurTous();
			formateurs_header.name = "formateurs_header";
			formateurs_header.txt.text = "Jours";
			formateurs_header.txt.autoSize = TextFieldAutoSize.RIGHT;
			formateurs_header.x = xx;
			formateurs_header.y = yy;
			formateurs_header.txt.border = true;
			this.addChild(formateurs_header);

			var formateurs_header2:NformateurTous = new NformateurTous();
			formateurs_header2.name = "formateurs_header2";
			formateurs_header2.txt.text = cat;
			formateurs_header2.txt.textColor = this.header.textColor;
			formateurs_header2.x = xx;
			formateurs_header2.y = yy + formateurs_header.height;
			formateurs_header2.txt.border = true;
			this.addChild(formateurs_header2);

			xx +=  formateurs_header2.width;
			for (var j:int = 0; j<joursParMois[mm1]; j++)
			{
				var case_header:CaseTous = new CaseTous();
				var case_header2:CaseTous = new CaseTous();
				case_header.name = "case_header";
				case_header2.name = "case_header2";
				case_header.txt.text = String(j + 1);
				case_header.x = xx;
				case_header.y = yy;
				case_header.txt.border = true;
				this.addChild(case_header);

				var date:Date = new Date(yyyy,mm1,j + 1);
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
				this.addChild(case_header2);

				xx +=  case_header.width;
			}

			this.sp.y = formateurs_header2.y + formateurs_header2.height;
			xx = 0;
			yy = 0;

			ca = 0;
			ce = 0;
			cs = 0;
			ma = 0;
			ab = 0;
			di = 0;

			for (var c:int = 0; c < cadres.length; c++)
			{
				lines[c] = new Array();
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
				this.holder.addChild(case_nbr);
				this.holder.addChild(formateurs_tous[c]);
				lines[c].push(case_nbr.txt.text);
				lines[c].push(formateurs_tous[c].txt.text);

				xx = formateurs_tous[0].width;
				case_tous[c] = new Array();

				for (j = 0; j<joursParMois[mm1]; j++)
				{
					date = new Date(yyyy,mm1,j + 1);
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
						case_tous[c][j].txt.textColor = this.header.textColor;
						case_tous[c][j].txt.text = "D";
					}

					if (work(c,day))
					{
						case_tous[c][j].txt.background = true;
						case_tous[c][j].txt.backgroundColor = this.header.textColor;
						case_tous[c][j].txt.textColor = formateurs_header.txt.textColor;
						case_tous[c][j].txt.text = "T";
					}

					var tmp_ca:int = 0;
					var tmp_ce:int = 0;
					var tmp_cs:int = 0;
					var tmp_ma:int = 0;
					var tmp_ab:int = 0;
					var tmp_di:int = 0;

					for (var s:int = 0; s<daily_sessions; s++)
					{
						var cause:String = absence[c][mm1][j][s]["obs"].toString().toLowerCase();
						cause = cause.substr(0,2);
						cause = trim(cause);
						cause = cause.toUpperCase();
						if (cause != "")
						{
							case_tous[c][j].txt.textColor = 0xffffff;
							case_tous[c][j].txt.text = cause;
							case_tous[c][j].txt.background = true;
							switch (cause)
							{
								case "MA" :
									tmp_ma++;
									case_tous[c][j].txt.textColor = 0x333333;
									case_tous[c][j].txt.backgroundColor = 0xCCCCCC;
									break;
								case "AB" :
									tmp_ab++;
									case_tous[c][j].txt.backgroundColor = 0xFF0000;
									break;
								case "CA" :
									tmp_ca++;
									case_tous[c][j].txt.backgroundColor = 0xFF6699;
									break;
								case "CE" :
									tmp_ce++;
									case_tous[c][j].txt.backgroundColor = 0x9900CC;
									break;
								case "CS" :
									tmp_cs++;
									case_tous[c][j].txt.backgroundColor = 0x000099;
									break;
								default :
									tmp_di++;
									case_tous[c][j].txt.background = false;
									case_tous[c][j].txt.text = cause;
									break;
							}
						}
					}
					if (tmp_ca > 0)
					{
						ca++;
					}
					if (tmp_ce > 0)
					{
						ce++;
					}
					if (tmp_cs > 0)
					{
						cs++;
					}
					if (tmp_ma > 0)
					{
						ma++;
					}
					if (tmp_ab > 0)
					{
						ab++;
					}
					if (tmp_di > 0)
					{
						di++;
					}

					this.holder.addChild(case_tous[c][j]);
					lines[c].push(case_tous[c][j].txt.text);
					xx +=  case_tous[c][j].width;
				}
				yy +=  formateurs_tous[c].trans.height;
			}

			this.sp.source = this.holder;

			this.ab_txt.htmlText = (ab > 0) ? "<b>AB: " + String(ab) + "</b>" : "AB: " + String(ab);
			this.ma_txt.htmlText = (ma > 0) ? "<b>MA: " + String(ma) + "</b>" : "MA: " + String(ma);
			this.ca_txt.htmlText = (ca > 0) ? "<b>CA: " + String(ca) + "</b>" : "CA: " + String(ca);
			this.ce_txt.htmlText = (ce > 0) ? "<b>CE: " + String(ce) + "</b>" : "CE: " + String(ce);
			this.cs_txt.htmlText = (cs > 0) ? "<b>CS: " + String(cs) + "</b>" : "CS: " + String(cs);
			this.di_txt.htmlText = (di > 0) ? "<b>Autres: " + String(di) + "</b>" : "Autres: " + String(di);
			
			enableAll();
		}
		//-------------------------------------------------
		public function work(c:int, day:int):Boolean
		{
			if (day == -1)
			{
				return false;
			}
			if (day == 5 && cat == "Personnel Administratif")
			{
				return false;
			}
			if (cat == "Cadres Pédagogiques")
			{
				return Acour(c, day);
			}

			return true;
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
		//----------------------------------------------------------------------------------------
		public function restoreMsg():void
		{
			if (tw != null)
			{
				tw.kill();
			}
			this.msg.textColor = 0xffffff;
			this.msg.text = "";
			this.msg.alpha = 1;
		}
		//---------------------------------------------------
		private function Imprimer(e:MouseEvent):void
		{
			curr_cadre = 0;
			curr_line = 0;
			nbr_pages = 0;
			pages.splice(0);
			printPage();
		}
		//---------------------------------------------------
		private function printPage():void
		{
			//pages header
			pages[nbr_pages] = new FicheEmploiMensuellePr();
			pages[nbr_pages].periode_txt.htmlText = "<b>" + this.periode_txt.text + "</b>";
			pages[nbr_pages].cat.htmlText = "<b>" + this.cat + "</b>";

			pages[nbr_pages].ab_txt.htmlText = this.ab_txt.htmlText;
			pages[nbr_pages].ma_txt.htmlText = this.ma_txt.htmlText;
			pages[nbr_pages].ca_txt.htmlText = this.ca_txt.htmlText;
			pages[nbr_pages].ce_txt.htmlText = this.ce_txt.htmlText;
			pages[nbr_pages].cs_txt.htmlText = this.cs_txt.htmlText;
			pages[nbr_pages].di_txt.htmlText = this.di_txt.htmlText;

			var xx:int = pages[nbr_pages].header.x;
			var yy:int = pages[nbr_pages].ab_txt.y + pages[nbr_pages].ab_txt.height;

			//pages content
			//clear holder
			for (var c:int = pages[nbr_pages].holder.numChildren -1; c >=0; c--)
			{
				pages[nbr_pages].holder.removeChildAt(c);
			}

			pages[nbr_pages].holder.x = xx;
			pages[nbr_pages].holder.y = yy;
			xx = 0;
			yy = 0;

			var formateurs_header:RowPresenceMensuelPr1 = new RowPresenceMensuelPr1();
			formateurs_header.txt.text = "";
			formateurs_header.txt.autoSize = TextFieldAutoSize.RIGHT;
			formateurs_header.x = xx;
			formateurs_header.y = yy;
			pages[nbr_pages].holder.addChild(formateurs_header);

			var formateurs_header2:RowPresenceMensuelPr1 = new RowPresenceMensuelPr1();
			formateurs_header2.txt.text = "";
			formateurs_header2.txt.autoSize = TextFieldAutoSize.LEFT;
			formateurs_header2.x = xx;
			formateurs_header2.y = yy + formateurs_header.height;
			pages[nbr_pages].holder.addChild(formateurs_header2);

			xx +=  formateurs_header2.width;
			for (var j:int = 0; j<joursParMois[mm1]; j++)
			{
				var case_header:RowPresenceMensuelPr2 = new RowPresenceMensuelPr2();
				case_header.gotoAndStop(1);
				var case_header2:RowPresenceMensuelPr2 = new RowPresenceMensuelPr2();
				case_header.gotoAndStop(1);
				case_header.txt.text = String(j + 1);
				case_header.x = xx;
				case_header.y = yy;
				pages[nbr_pages].holder.addChild(case_header);

				var date:Date = new Date(yyyy,mm1,j + 1);
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
				pages[nbr_pages].holder.addChild(case_header2);

				xx +=  case_header.width;
			}

			xx = 0;
			yy = formateurs_header2.y + formateurs_header2.height;

			while (curr_line < max_lines)
			{

				if (curr_cadre < cadres.length)
				{
					xx = 0;
					var case_nbr:RowPresenceMensuelPr2 = new RowPresenceMensuelPr2();
					case_nbr.gotoAndStop(1);
					case_nbr.txt.text = lines[curr_cadre][0];
					case_nbr.x = xx;
					case_nbr.y = yy;

					formateurs_tous[curr_cadre] = new RowPresenceMensuelPr3();
					formateurs_tous[curr_cadre].txt.text = lines[curr_cadre][1];
					formateurs_tous[curr_cadre].txt.autoSize = TextFieldAutoSize.LEFT;
					formateurs_tous[curr_cadre].x = xx + case_nbr.width;
					formateurs_tous[curr_cadre].y = yy;
					pages[nbr_pages].holder.addChild(case_nbr);
					pages[nbr_pages].holder.addChild(formateurs_tous[curr_cadre]);

					xx = formateurs_tous[0].width;
					case_tous[curr_cadre] = new Array();
					for (j = 0; j<joursParMois[mm1]; j++)
					{
						date = new Date(yyyy,mm1,j + 1);
						day = date.getDay() - 1;

						case_tous[curr_cadre][j] = new RowPresenceMensuelPr2();
						case_tous[curr_cadre][j].gotoAndStop(1);
						case_tous[curr_cadre][j].txt.text = lines[curr_cadre][j + 2];
						case_tous[curr_cadre][j].x = xx;
						case_tous[curr_cadre][j].y = yy;

						switch (case_tous[curr_cadre][j].txt.text)
						{
							case "D" :
								case_tous[curr_cadre][j].gotoAndStop(2);
								case_tous[curr_cadre][j].txt.text = "";
								break;
							case "T" :
								case_tous[curr_cadre][j].txt.background = true;
								case_tous[curr_cadre][j].txt.backgroundColor = 0xffffff;
								case_tous[curr_cadre][j].txt.textColor = 0x666666;
								break;
							default :
								case_tous[curr_cadre][j].txt.textColor = 0x000000;
								break;
						}

						pages[nbr_pages].holder.addChild(case_tous[curr_cadre][j]);
						xx +=  case_tous[curr_cadre][j].width;
					}
					yy +=  formateurs_tous[curr_cadre].height;
					curr_cadre++;
				}
				else
				{
					//print empty row
					xx = 0;
					case_nbr = new RowPresenceMensuelPr2();
					case_nbr.txt.text = "";
					case_nbr.x = xx;
					case_nbr.y = yy;

					formateurs_tous[curr_cadre] = new RowPresenceMensuelPr3();
					formateurs_tous[curr_cadre].txt.text = "";
					formateurs_tous[curr_cadre].x = xx + case_nbr.width;
					formateurs_tous[curr_cadre].y = yy;
					pages[nbr_pages].holder.addChild(case_nbr);
					pages[nbr_pages].holder.addChild(formateurs_tous[curr_cadre]);

					xx = formateurs_tous[0].width;
					case_tous[curr_cadre] = new Array();
					for (j = 0; j<joursParMois[mm1]; j++)
					{
						date = new Date(yyyy,mm1,j + 1);
						day = date.getDay() - 1;

						case_tous[curr_cadre][j] = new RowPresenceMensuelPr2();
						case_tous[curr_cadre][j].txt.text = "";
						case_tous[curr_cadre][j].x = xx;
						case_tous[curr_cadre][j].y = yy;

						pages[nbr_pages].holder.addChild(case_tous[curr_cadre][j]);
						xx +=  case_tous[curr_cadre][j].width;
					}
					yy +=  formateurs_tous[curr_cadre].height;
				}
				curr_line++;
			}
			//pages footer

			pages[nbr_pages].footer.x = (pages[nbr_pages].width - pages[nbr_pages].footer.width)/2;
			pages[nbr_pages].footer.y = yy + 20;
			pages[nbr_pages].holder.addChild(pages[nbr_pages].footer);

			while (pages[nbr_pages].holder.width > pages[nbr_pages].header.width)
			{
				pages[nbr_pages].holder.scaleX -=  .01;
			}

			if (curr_cadre < cadres.length)
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
		//-------------------------------------------------------------------------------------------

	}

}