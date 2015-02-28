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
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class FicheCongesForm extends MovieClip
	{
		private var baseUrl:String = "http://www.flash-experts.com/";
		private var amfphp_path:String = baseUrl + "amfphp/gateway.php";
		private var gw:NetConnection = new NetConnection();

		var ficheEmploi:FicheEmploi = new FicheEmploi();

		public var datePanel:DatePanel;
		public var php_load:String;
		public var php_save:String;
		private var cadres:Array = new Array();
		private var cadres_actifs:Array = new Array();
		private var rows:Array = new Array();
		private var suivi_rows:Array = new Array();
		private var paramsF:Array = new Array();

		private var counter:int;
		private var nupdates:int;

		private var max_lines:int = 30;
		private var curr_line:int = 0;
		private var nbr_page:int = 0;
		private var emploi_xml:XML;
		private var fiche_xml:XML;
		private var new_fiche:XML;
		public var presenceF:Array = new Array();
		private var jours:Array = new Array();
		private var joursParMois:Array = new Array();
		private var mois:Array = new Array();
		private var heures:Array = new Array();
		private var day_counter:int = 0;

		private var curr_row:int = 0;
		private var selected_row:int = 0;
		private var next_row:int = 0;
		private var prev_row:int = 0;

		var date:Date = new Date();
		var dd:int = date.getDay();
		var jj:int = date.getDate();
		var mm:int = date.getMonth();
		var yyyy:int = date.getFullYear();
		var ms:Number = new Date(yyyy,mm,jj,0,0,0,0).valueOf();

		public var tca:Number;
		public var tce:Number;
		public var tcs:Number;
		public var tma:Number;
		public var tab:Number;

		public var lca:Number;
		public var lce:Number;
		public var lcs:Number;
		public var lma:Number;
		public var lab:Number;

		var daily_sessions:int = 5;
		var curr_month:int = 0;
		var curr_day:int = 0;

		var ca_arr:Array = new Array();
		var ce_arr:Array = new Array();
		var cs_arr:Array = new Array();
		var ma_arr:Array = new Array();
		var ab_arr:Array = new Array();

		var ca_alarm:Array = new Array();
		var ce_alarm:Array = new Array();
		var cs_alarm:Array = new Array();
		var ma_alarm:Array = new Array();
		var ab_alarm:Array = new Array();

		var tw:TweenLite;
		var myTimer:Timer;
		var alarm_clicks:int = 0;

		//---------------------------------------------------
		public function FicheCongesForm()
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
		//-----------------------------------------------------------------------------------------
		public function setParamsF(arr:Array):void
		{
			this.paramsF = arr;
			tca = Number(paramsF[0]);
			tce = Number(paramsF[1]);
			tcs = Number(paramsF[2]);
			tma = Number(paramsF[3]);
			tab = Number(paramsF[4]);

			lca = Number(paramsF[5]);
			lce = Number(paramsF[6]);
			lcs = Number(paramsF[7]);
			lma = Number(paramsF[8]);
			lab = Number(paramsF[9]);
		}
		//-------------------------------------------------
		public function setDailySessions(sessions:int):void
		{
			this.daily_sessions = sessions;
		}
		//-----------------------------------------------------------------------------------------
		public function setPresenceF(arr:Array):void
		{
			this.presenceF = arr;
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
		//-----------------------------------------------------------------------------------------
		public function setJoursParMois(arr:Array):void
		{
			this.joursParMois = arr;
		}
		//-------------------------------------------------
		public function setHeures(arr:Array):void
		{
			this.heures = arr;
		}
		//-------------------------------------------------
		public function setCadres(arr:Array):void
		{
			this.cadres = arr;
		}
		//-------------------------------------------------
		public function showPanel():void
		{
			this.cat.htmlText = "<b>Cadres Pédagogiques</b>";
			this.nbr.border = true;

			this.suiviCF.ca.border = true;
			this.suiviCF.ma.border = true;
			this.suiviCF.ce.border = true;
			this.suiviCF.cs.border = true;
			this.suiviCF.ab.border = true;

			this.suiviCF.ca_lb.border = true;
			this.suiviCF.ma_lb.border = true;
			this.suiviCF.ce_lb.border = true;
			this.suiviCF.cs_lb.border = true;
			this.suiviCF.ab_lb.border = true;

			this.suiviCF.ca_tf.border = true;
			this.suiviCF.ma_tf.border = true;
			this.suiviCF.ce_tf.border = true;
			this.suiviCF.cs_tf.border = true;
			this.suiviCF.ab_tf.border = true;

			this.alarm_btn.addEventListener(MouseEvent.CLICK, switchView);

			this.txtbg.alpha = .5;
			updatePresence();
		}
		//-------------------------------------------------
		private function switchView(e:MouseEvent):void
		{
			alarm_clicks++;
			if (alarm_clicks > 1)
			{
				alarm_clicks = 0;
			}
			switch (alarm_clicks)
			{
				case 1 :
					getAlarms();
					this.alarm_btn.label = "Détails";
					break;
				case 0 :
					updatePresence();
					this.alarm_btn.label = "Alarmes";
					break;
			}
		}
		//-------------------------------------------------
		public function updatePresence():void
		{
			alarm_clicks = 0;
			this.alarm_btn.label = "Alarmes";
			this.suiviCF.visible = false;
			initCongeFile();
			updateRows();
		}
		//-------------------------------------------------
		private function initCongeFile():void
		{
			this.suiviCF.formateur.htmlText = "";
			this.suiviCF.annee.htmlText = "";
			this.suiviCF.txtbg.alpha = .5;
			this.suiviCF.ft1bg.alpha = .5;
			this.suiviCF.ft2bg.alpha = .5;

			this.suiviCF.ft1bg.visible = true;
			this.suiviCF.ft2bg.visible = true;

			this.suiviCF.ca_lb.visible = true;
			this.suiviCF.ce_lb.visible = true;
			this.suiviCF.cs_lb.visible = true;
			this.suiviCF.ma_lb.visible = true;
			this.suiviCF.ab_lb.visible = true;

			this.suiviCF.ca_tf.visible = true;
			this.suiviCF.ce_tf.visible = true;
			this.suiviCF.cs_tf.visible = true;
			this.suiviCF.ma_tf.visible = true;
			this.suiviCF.ab_tf.visible = true;

			for (var c:int = this.suiviCF.holder.numChildren-1; c >=0; c--)
			{
				this.suiviCF.holder.removeChildAt(c);
			}
			var xx:int = 0;
			var yy:int = 0;
			var f:int = 0;

			this.suiviCF.ab_tf.text = "";
			this.suiviCF.cs_tf.text = "";
			this.suiviCF.ce_tf.text = "";
			this.suiviCF.ma_tf.text = "";
			this.suiviCF.ca_tf.text = "";

			suivi_rows.splice(0);
			var max:int = 14;

			for (var m:int = 0; m < max; m++)
			{
				suivi_rows[m] = new SuiviRowF();
				suivi_rows[m].name = String(m);

				suivi_rows[m].bg.alpha = .2;
				if (m % 2 != 0)
				{
					suivi_rows[m].bg.alpha = .4;
				}

				suivi_rows[m].ca.border = true;
				suivi_rows[m].ma.border = true;
				suivi_rows[m].ce.border = true;
				suivi_rows[m].cs.border = true;
				suivi_rows[m].ab.border = true;

				suivi_rows[m].x = xx;
				suivi_rows[m].y = yy;
				yy +=  suivi_rows[m].height;

				this.suiviCF.holder.addChild(suivi_rows[m]);
			}
			this.suiviCF.sp.source = this.suiviCF.holder;
			this.suiviCF.visible = true;
		}
		//-------------------------------------------------
		private function getAlarms():void
		{
			this.suiviCF.ab_tf.text = "";
			this.suiviCF.cs_tf.text = "";
			this.suiviCF.ce_tf.text = "";
			this.suiviCF.ma_tf.text = "";
			this.suiviCF.ca_tf.text = "";

			this.suiviCF.myCounter.days_txt.text = "";
			this.suiviCF.myCounter.sep_txt.text = "";
			this.suiviCF.myCounter.months_txt.text = "";

			for (var c:int = 0; c < cadres.length; c++)
			{
				ca_alarm[c] = new Array();
				ce_alarm[c] = new Array();
				cs_alarm[c] = new Array();
				ma_alarm[c] = new Array();
				ab_alarm[c] = new Array();
				for (var m:int = 0; m <mois.length; m++)
				{
					for (var j:int = 0; j < joursParMois[m]; j++)
					{
						for (var s:int = 0; s < daily_sessions; s++)
						{
							var obs:String = presenceF[c][m][j][s]["obs"].toString().toLowerCase();
							obs = obs.substr(0,2);
							var date:String = formatNbr(curr_day + 1) + "/" + formatNbr(curr_month + 1);
							if (obs != "")
							{
								switch (obs)
								{
									case "ca" :
										ca_alarm[c].push(date);
										break;
									case "ma" :
										ma_alarm[c].push(date);
										break;
									case "ce" :
										ce_alarm[c].push(date);
										break;
									case "cs" :
										cs_alarm[c].push(date);
										break;
									case "ab" :
										ab_alarm[c].push(date);
										break;
								}
							}
						}
					}
				}
			}


			var xx:int = 0;
			var yy:int = 0;

			var xx1:int = 0;
			var yy1:int = 0;

			this.suiviCF.ft1bg.visible = false;
			this.suiviCF.ft2bg.visible = false;

			this.suiviCF.ca_lb.visible = false;
			this.suiviCF.ce_lb.visible = false;
			this.suiviCF.cs_lb.visible = false;
			this.suiviCF.ma_lb.visible = false;
			this.suiviCF.ab_lb.visible = false;

			this.suiviCF.ca_tf.visible = false;
			this.suiviCF.ce_tf.visible = false;
			this.suiviCF.cs_tf.visible = false;
			this.suiviCF.ma_tf.visible = false;
			this.suiviCF.ab_tf.visible = false;

			clearHolder();
			for (c = this.suiviCF.holder.numChildren-1; c >=0; c--)
			{
				this.suiviCF.holder.removeChildAt(c);
			}

			rows.splice(0);
			suivi_rows.splice(0);

			for (c = 0; c < cadres.length; c++)
			{
				if (ca_alarm[c].length >= lca || (ma_alarm[c].length >= lma) || (ce_alarm[c].length >= lce) || (cs_alarm[c].length >= lcs) || (ab_alarm[c].length >= lab))
				{
					suivi_rows[c] = new SuiviRowF();
					suivi_rows[c].name = String(c);
					rows[c] = new RowCongesF();
					rows[c].name = String(c);
					rows[c].nbr.text = String(c + 1);
					rows[c].nom.text = cadres[c]["nom"] + " " + cadres[c]["prenom"];

					rows[c].bg.alpha = .2;
					if (c % 2 != 0)
					{
						rows[c].bg.alpha = .4;
					}

					rows[c].nbr.border = true;
					rows[c].nom.border = true;

					rows[c].x = xx;
					rows[c].y = yy;
					//yy +=  rows[c].height;

					rows[c].addEventListener(MouseEvent.CLICK, onMouseClick);
					rows[c].addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
					rows[c].addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

					this.holder.addChild(rows[c]);
					//------;
					suivi_rows[c] = new SuiviRowF();
					suivi_rows[c].name = String(c);

					suivi_rows[c].bg.alpha = .2;
					if (c % 2 != 0)
					{
						suivi_rows[c].bg.alpha = .4;
					}

					this.suiviCF.holder.addChild(suivi_rows[c]);

					if (ca_alarm[c].length >= lca)
					{
						highlight_txt(suivi_rows[c].ca, String(ca_alarm[c].length), ca_alarm[c].length, lca);
					}

					if (ma_alarm[c].length >= lma)
					{
						highlight_txt(suivi_rows[c].ma, String(ma_alarm[c].length), ma_alarm[c].length, lma);
					}

					if (ce_alarm[c].length >= lce)
					{
						highlight_txt(suivi_rows[c].ce, String(ce_alarm[c].length), ce_alarm[c].length, lce);
					}

					if (cs_alarm[c].length >= lcs)
					{
						highlight_txt(suivi_rows[c].cs, String(cs_alarm[c].length), cs_alarm[c].length, lcs);
					}

					if (ab_alarm[c].length >= lab)
					{
						highlight_txt(suivi_rows[c].ab, String(ab_alarm[c].length), ab_alarm[c].length, lab);
					}

					suivi_rows[c].bg.alpha = .2;
					if (m % 2 != 0)
					{
						suivi_rows[c].bg.alpha = .4;
					}

					suivi_rows[c].ca.border = true;
					suivi_rows[c].ma.border = true;
					suivi_rows[c].ce.border = true;
					suivi_rows[c].cs.border = true;
					suivi_rows[c].ab.border = true;

					suivi_rows[c].x = xx;
					suivi_rows[c].y = yy;

					//yy +=  suivi_rows[c].height;
					yy +=  rows[c].height;

					this.suiviCF.holder.addChild(suivi_rows[c]);
				}
			}
			this.sp.source = this.holder;
			this.suiviCF.sp.source = this.suiviCF.holder;
		}
		//-------------------------------------------------
		private function updateConge():void
		{
			this.suiviCF.ab_tf.text = "";
			this.suiviCF.cs_tf.text = "";
			this.suiviCF.ce_tf.text = "";
			this.suiviCF.ma_tf.text = "";
			this.suiviCF.ca_tf.text = "";

			this.suiviCF.myCounter.days_txt.text = "";
			this.suiviCF.myCounter.sep_txt.text = "/";
			this.suiviCF.myCounter.months_txt.text = "";

			suivi_rows.splice(0);

			curr_month = 0;
			curr_day = 0;
			ca_arr.splice(0);
			ce_arr.splice(0);
			cs_arr.splice(0);
			ma_arr.splice(0);
			ab_arr.splice(0);

			myTimer = new Timer(10);
			myTimer.addEventListener(TimerEvent.TIMER, timerHandler);
			myTimer.start();
		}
		//-------------------------------------------------
		private function fillRows():void
		{
			var max:int = ca_arr.length;
			if (max < ce_arr.length)
			{
				max = ce_arr.length;
			}
			if (max < cs_arr.length)
			{
				max = cs_arr.length;
			}
			if (max < ma_arr.length)
			{
				max = ma_arr.length;
			}
			if (max < ab_arr.length)
			{
				max = ab_arr.length;
			}
			if (max < 14)
			{
				max = 14;
			}

			var xx:int = 0;
			var yy:int = 0;
			var f:int = 0;

			for (var c:int = this.suiviCF.holder.numChildren-1; c >=0; c--)
			{
				this.suiviCF.holder.removeChildAt(c);
			}

			for (var m:int = 0; m < max; m++)
			{
				suivi_rows[m] = new SuiviRowF();
				suivi_rows[m].name = String(m);
				if (m < ca_arr.length)
				{
					highlight_txt(suivi_rows[m].ca, ca_arr[m], (m + 1), lca);
				}

				if (m < ma_arr.length)
				{
					highlight_txt(suivi_rows[m].ma, ma_arr[m], (m + 1), lma);
				}

				if (m < ce_arr.length)
				{
					highlight_txt(suivi_rows[m].ce, ce_arr[m], (m + 1), lce);
				}

				if (m < cs_arr.length)
				{
					highlight_txt(suivi_rows[m].cs, cs_arr[m], (m + 1), lcs);
				}

				if (m < ab_arr.length)
				{
					highlight_txt(suivi_rows[m].ab, ab_arr[m], (m + 1), lab);
				}

				suivi_rows[m].bg.alpha = .2;
				if (m % 2 != 0)
				{
					suivi_rows[m].bg.alpha = .4;
				}

				suivi_rows[m].ca.border = true;
				suivi_rows[m].ma.border = true;
				suivi_rows[m].ce.border = true;
				suivi_rows[m].cs.border = true;
				suivi_rows[m].ab.border = true;

				suivi_rows[m].x = xx;
				suivi_rows[m].y = yy;
				yy +=  suivi_rows[m].height;

				this.suiviCF.holder.addChild(suivi_rows[m]);
			}
			this.suiviCF.sp.source = this.suiviCF.holder;

			highlight_txt(this.suiviCF.ca_tf, String(tca - ca_arr.length) + " / " + String(lca), ca_arr.length, lca);
			highlight_txt(this.suiviCF.ma_tf, String(ma_arr.length), ma_arr.length, lma);
			highlight_txt(this.suiviCF.ce_tf, String(tce - ce_arr.length) + " / " + String(lce), ce_arr.length, lce);
			highlight_txt(this.suiviCF.cs_tf, String(cs_arr.length), cs_arr.length, lcs);
			highlight_txt(this.suiviCF.ab_tf, String(ab_arr.length), ab_arr.length, lab);

			this.suiviCF.myCounter.days_txt.text = "";
			this.suiviCF.myCounter.sep_txt.text = "";
			this.suiviCF.myCounter.months_txt.text = "";

			myTimer.removeEventListener(TimerEvent.TIMER, timerHandler);
			myTimer.stop();
		}
		//-------------------------------------------------
		private function highlight_txt(tf:Object, txt:String, n:int, limit:int):void
		{
			tf.textColor = 0x000000;
			tf.htmlText = txt;
			if (n >= limit)
			{
				tf.htmlText = "<b>" + txt + "</b>";
			}
			if (n == limit)
			{
				tf.textColor = 0x0000ff;
			}
			if (n > limit)
			{
				tf.textColor = 0x990000;
			}
		}
		//-------------------------------------------------
		private function timerHandler(e:TimerEvent):void
		{
			if (curr_month < mois.length)
			{
				this.suiviCF.myCounter.months_txt.text = String(curr_month + 1);
				if (curr_day < joursParMois[curr_month])
				{
					this.suiviCF.myCounter.days_txt.text = String(curr_day + 1);
					for (var s:int = 0; s < daily_sessions; s++)
					{
						var obs:String = presenceF[selected_row][curr_month][curr_day][s]["obs"].toString().toLowerCase();
						obs = obs.substr(0,2);
						var date:String = formatNbr(curr_day + 1) + "/" + formatNbr(curr_month + 1);
						if (obs != "")
						{
							switch (obs)
							{
								case "ca" :
									ca_arr.push(date);
									break;
								case "ma" :
									ma_arr.push(date);
									break;
								case "ce" :
									ce_arr.push(date);
									break;
								case "cs" :
									cs_arr.push(date);
									break;
								case "ab" :
									ab_arr.push(date);
									break;
							}
						}
					}
					curr_day++;
				}
				else
				{
					curr_day = 0;
					curr_month++;
				}
			}
			else
			{
				curr_month = 0;
				curr_day = 0;
				fillRows();

				alarm_clicks = 0;
				this.alarm_btn.label = "Alarmes";
			}
			e.updateAfterEvent();
		}
		//-------------------------------------------------
		private function formatNbr(n:int):String
		{
			var st:String = (n > 9) ? String(n) : "0" + String(n);
			return st;
		}
		//-------------------------------------------------
		private function updateRows():void
		{
			trace("updateRows", cadres.length);
			clearHolder();
			var xx:int = 0;
			var yy:int = 0;

			rows.splice(0);
			for (var f:int = 0; f < cadres.length; f++)
			{
				rows[f] = new RowCongesF();
				rows[f].name = String(f);
				rows[f].nbr.text = String(f + 1);
				rows[f].nom.text = cadres[f]["nom"] + " " + cadres[f]["prenom"];

				rows[f].bg.alpha = .2;
				if (f % 2 != 0)
				{
					rows[f].bg.alpha = .4;
				}

				rows[f].nbr.border = true;
				rows[f].nom.border = true;

				rows[f].x = xx;
				rows[f].y = yy;
				yy +=  rows[f].height;

				rows[f].addEventListener(MouseEvent.CLICK, onMouseClick);
				rows[f].addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				rows[f].addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

				this.holder.addChild(rows[f]);
			}
			this.sp.source = this.holder;
		}
		//-----------------------------------
		private function GetConges():void
		{
			initCongeFile();

			this.suiviCF.formateur.htmlText = "<b>" + cadres[selected_row]["nom"] + " " + cadres[selected_row]["prenom"] + "</b>";
			this.suiviCF.annee.htmlText = "<b>Année: " + String(yyyy) + "</b>";
			this.suiviCF.txtbg.alpha = .5;
			this.suiviCF.ft1bg.alpha = .5;
			this.suiviCF.ft2bg.alpha = .5;

			this.suiviCF.scaleX = 0;
			this.suiviCF.visible = true;
			tw = new TweenLite(this.suiviCF,1,{scaleX:1,onComplete:updateConge});

		}
		//-----------------------------------
		private function onMouseClick(e:MouseEvent):void
		{
			selected_row = int(e.currentTarget.name);
			GetConges();
		}
		//-----------------------------------
		private function onMouseOver(e:MouseEvent):void
		{
			curr_row = int(e.currentTarget.name);
			rows[curr_row].bg.alpha = 0;
		}
		//-----------------------------------
		private function onMouseOut(e:MouseEvent):void
		{
			rows[curr_row].bg.alpha = .2;
			if (curr_row % 2 != 0)
			{
				rows[curr_row].bg.alpha = .4;
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
		//------------------------------------------------;
		function restoreMsg():void
		{
			this.msg.text = "";
			this.msg.alpha = 1;
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