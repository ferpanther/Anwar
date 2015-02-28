package 
{
	import com.greensock.TweenLite;
	import com.greensock.*;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.easing.*;
	import com.AmfPhp;

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

	public class CadresPanel extends MovieClip
	{
		public static const CADRES_SAVED:String = "cadres_saved";
		public static const CADRES_NOTSAVED:String = "cadres_notsaved";
		public static const CADRE_DELETED:String = "cadre_deleted";
		public static const CADRE_NOTDELETED:String = "cadre_notdeleted";

		public var amfPhp:AmfPhp = new AmfPhp();

		public var php_load:String;
		public var php_save:String;
		public var php_delete:String;

		public var deletePanel:DeletePanel;
		public var cadresp:Array = new Array();
		public var nupdates:int;
		private var prev_cadresp:Array = new Array();
		private var rows:Array = new Array();
		private var counter:int;
		

		private var curr_row:int = 0;
		private var next_row:int = 0;
		private var prev_row:int = 0;

		//-----------------------------------
		public function CadresPanel()
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
		//------------------------------------
		private function init(e:Event = null):void
		{
			if (e != null)
			{
				this.removeEventListener(Event.ADDED_TO_STAGE, init);
			}

			showPanel();
		}
		//------------------------------------
		public function showPanel():void
		{
			this.year.htmlText = getYear();
			this.nbr.htmlText = "N°";
			this.msg.text = "";
			
			this.nbr.border = true;
			this.nom.border = true;
			this.prenom.border = true;
			this.uid.border = true;
			this.matiere.border = true;
			this.horaire.border = true;

			this.sp.tabEnabled = false;
			
			this.add_btn.addEventListener(MouseEvent.CLICK, addRow);
		}
		//-----------------------------------;
		private function fillRows():void
		{
			//this.add_btn.enabled = true;
			clearHolder();
			var xx:int = 0;
			var yy:int = 0;
			var tab:int = 1;

			rows.splice(0);
			for (var r:int = 0; r < cadresp.length; r++)
			{
				rows[r] = new RowCadres();
				rows[r].name = "row_" + String(r);
				rows[r].nbr.text = String(r + 1);
				rows[r].nom.text = cadresp[r]["nom"];
				rows[r].prenom.text = cadresp[r]["prenom"];
				rows[r].uid.text = cadresp[r]["uid"];
				rows[r].matiere.text = cadresp[r]["matiere"];
				rows[r].horaire.text = cadresp[r]["horaire"];

				rows[r].nbr.border = true;
				rows[r].nom.border = true;
				rows[r].prenom.border = true;
				rows[r].uid.border = true;
				rows[r].matiere.border = true;
				rows[r].horaire.border = true;

				rows[r].x = xx;
				rows[r].y = yy;
				yy +=  rows[r].height;
				
				rows[r].bg.alpha = .2;
				if (r % 2 != 0)
				{
					rows[r].bg.alpha = .4;
				}
				
				rows[r].addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				rows[r].addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

				rows[r].nom.addEventListener(Event.CHANGE, onChange);
				rows[r].prenom.addEventListener(Event.CHANGE, onChange);
				rows[r].uid.addEventListener(Event.CHANGE, onChange);
				rows[r].matiere.addEventListener(Event.CHANGE, onChange);
				rows[r].horaire.addEventListener(Event.CHANGE, onChange);

				rows[r].nom.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
				rows[r].prenom.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
				rows[r].uid.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
				rows[r].matiere.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
				rows[r].horaire.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);

				rows[r].nom.addEventListener(FocusEvent.FOCUS_IN, onFocus);
				rows[r].prenom.addEventListener(FocusEvent.FOCUS_IN, onFocus);
				rows[r].uid.addEventListener(FocusEvent.FOCUS_IN, onFocus);
				rows[r].matiere.addEventListener(FocusEvent.FOCUS_IN, onFocus);
				rows[r].horaire.addEventListener(FocusEvent.FOCUS_IN, onFocus);

				this.holder.addChild(rows[r]);
			}
			this.sp.source = this.holder;
			
			if (cadresp.length == 0)
			{
				this.msg.text = "Fiche vide.";
			}
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
		//------------------------------------
		private function clearHolder():void
		{
			for (var c:int = this.holder.numChildren-1; c>=0; c--)
			{
				this.holder.removeChildAt(c);
			}
			this.sp.source = this.holder;
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
			curr_row = int(e.currentTarget.parent.name.substr(4));
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
						case "nom" :
							stage.focus = rows[curr_row].prenom;
							break;
						case "prenom" :
							stage.focus = rows[curr_row].uid;
							break;
						case "uid" :
							stage.focus = rows[curr_row].matiere;
							break;
						case "matiere" :
							stage.focus = rows[curr_row].horaire;
							break;
						case "horaire" :
							if (curr_row == rows.length - 1)
							{
								addRow();
							}
							else
							{
								stage.focus = rows[next_row].nom;
							}
							break;
					}
					e.currentTarget.setSelection(0, e.currentTarget.length);
					break;

				case 39 :
					//right
					switch (e.currentTarget.name)
					{
						case "nom" :
							stage.focus = rows[curr_row].prenom;
							break;
						case "prenom" :
							stage.focus = rows[curr_row].uid;
							break;
						case "uid" :
							stage.focus = rows[curr_row].matiere;
							break;
						case "matiere" :
							stage.focus = rows[curr_row].horaire;
							break;
						case "horaire" :
							stage.focus = rows[next_row].nom;
							break;
					}
					break;

				case 37 :
					//left
					switch (e.currentTarget.name)
					{
						case "nom" :
							stage.focus = rows[prev_row].horaire;
							break;
						case "prenom" :
							stage.focus = rows[curr_row].nom;
							break;
						case "uid" :
							stage.focus = rows[curr_row].prenom;
							break;
						case "matiere" :
							stage.focus = rows[curr_row].uid;
							break;
						case "horaire" :
							stage.focus = rows[curr_row].matiere;
							break;
					}
					break;
				case 40 :
					//down
					switch (e.currentTarget.name)
					{
						case "nom" :
							stage.focus = rows[next_row].nom;
							break;
						case "prenom" :
							stage.focus = rows[next_row].prenom;
							break;
						case "uid" :
							stage.focus = rows[next_row].uid;
							break;
						case "matiere" :
							stage.focus = rows[next_row].matiere;
							break;
						case "horaire" :
							stage.focus = rows[next_row].horaire;
							break;
					}
					break;

				case 38 :
					//up
					switch (e.currentTarget.name)
					{
						case "nom" :
							stage.focus = rows[prev_row].nom;
							break;
						case "prenom" :
							stage.focus = rows[prev_row].prenom;
							break;
						case "uid" :
							stage.focus = rows[prev_row].uid;
							break;
						case "matiere" :
							stage.focus = rows[prev_row].matiere;
							break;
						case "horaire" :
							stage.focus = rows[prev_row].horaire;
							break;
					}
					break;
			}
		}
		//------------------------------------
		private function onChange(e:Event):void
		{
			curr_row = int(e.currentTarget.parent.name.substr(4));
			switch (e.currentTarget.name)
			{
				case "nom" :
					cadresp[curr_row]["nom"] = e.currentTarget.text;
					break;
				case "prenom" :
					cadresp[curr_row]["prenom"] = e.currentTarget.text;
					break;
				case "uid" :
					cadresp[curr_row]["uid"] = e.currentTarget.text;
					break;
				case "matiere" :
					cadresp[curr_row]["matiere"] = e.currentTarget.text;
					break;
				case "horaire" :
					cadresp[curr_row]["horaire"] = e.currentTarget.text;
					break;
			}

			this.msg.text = "";
		}
		//------------------------------------
		private function addRow(e:MouseEvent=null):void
		{
			cadresp.push({"nom":"", "prenom":"", "uid":"", "matiere":"", "horaire":""});
			fillRows();
			this.sp.verticalScrollPosition = this.sp.maxVerticalScrollPosition;
			stage.focus = rows[rows.length - 1]["nom"];
		}
		//------------------------------------
		public function getYear():String
		{
			var date:Date = new Date();
			var year = date.getFullYear();
			var year_st:String = String(year) + " / " + String(year + 1);
			return year_st;
		}
		//-----------------------------------
		public function parseXml(xml:XML):void
		{
			this.msg.text = "";
			var xml_list:XMLList = xml.children();

			cadresp.splice(0);
			prev_cadresp.splice(0);
			for (var m:int = 0; m < xml_list.length(); m++)
			{
				cadresp.push({"nom":xml_list[m]. @ nom, "prenom":xml_list[m]. @ prenom, "uid":xml_list[m]. @ uid, "matiere":xml_list[m]. @ matiere, "horaire":xml_list[m]. @ horaire});
				prev_cadresp.push({"nom":xml_list[m]. @ nom, "prenom":xml_list[m]. @ prenom, "uid":xml_list[m]. @ uid, "matiere":xml_list[m]. @ matiere, "horaire":xml_list[m]. @ horaire});
			}
			cadresp.sortOn("nom", Array.CASEINSENSITIVE);
			prev_cadresp.sortOn("nom", Array.CASEINSENSITIVE);
			dispatchEvent(new Event(Event.COMPLETE));
			
			/*this.add_btn.enabled = true;
			this.save_btn.enabled = true;
			this.delete_btn.enabled = true;*/
			fillRows();
		}
		//-----------------------------------
		public function getCadres():Array
		{
			return this.cadresp;
		}
		//------------------------------------;
		private function trim(st:String):String
		{
			while (st.charAt(0) == " ")
			{
				st = st.substr(1);
			}
			return st;
		}
		//-----------------------------------
		public function disableAll():void
		{
			this.delete_btn.enabled = false;
			this.exit_btn.enabled = false;
			this.save_btn.enabled = false;
			this.add_btn.enabled = false;
		}
		//-----------------------------------
		public function enableAll():void
		{
			this.delete_btn.enabled = true;
			this.exit_btn.enabled = true;
			this.save_btn.enabled = true;
			this.add_btn.enabled = true;
		}
		//-----------------------------------
		public function deleteRow(_php_delete:String):void
		{
			php_delete = _php_delete;
			disableAll();

			deletePanel = new DeletePanel(cadresp);
			deletePanel.addEventListener(Event.COMPLETE, onDeleteComplete);
			deletePanel.x = this.delete_btn.x + this.delete_btn.width +50 - deletePanel.width;
			deletePanel.y = this.delete_btn.y - deletePanel.bg.height - 10;
			this.addChild(deletePanel);
		}
		//-----------------------------------
		function onDeleteComplete(e:Event):void
		{
			if (deletePanel.ret == 1)
			{
				deleteCadre(deletePanel.nbr);
			}
			else
			{
				enableAll();
			}
		}
		//-----------------------------------
		function deleteCadre(n:int):void
		{
			restoreMsg();
			this.msg.text = "Suppression en cours...";
			var uid_st:String = cadresp[n]["uid"];
			
			amfPhp.addEventListener("cadre_deleted", onDeleteResult);
			amfPhp.addEventListener("cadre_notdeleted", onDeleteFault);
			amfPhp.deleteCadre(php_delete, uid_st);
		}
		//-----------------------------------
		function onDeleteResult(reponse:Object):void
		{
			amfPhp.removeEventListener("cadre_deleted", onDeleteResult);
			dispatchEvent(new Event(CadresPanel.CADRE_DELETED));
		}
		//-----------------------------------
		function onDeleteFault(reponse:Object):void
		{
			amfPhp.removeEventListener("cadre_notdeleted", onDeleteFault);
			this.msg.text = "Échec de la suppression.";
			new TweenLite(this.msg,15,{alpha:0,onComplete:restoreMsg});
			enableAll();
			dispatchEvent(new Event(CadresPanel.CADRE_NOTDELETED));
		}
		//-----------------------------------
		public function saveCadres(_php_save:String):void
		{
			php_save = _php_save;
			/*this.add_btn.enabled = false;
			this.save_btn.enabled = false;
			this.delete_btn.enabled = false;*/

			counter = 0;
			nupdates = 0;
			
			cadresp.sortOn("nom", Array.CASEINSENSITIVE);
			prev_cadresp.sortOn("nom", Array.CASEINSENSITIVE);
			saveInfo();
		}
		//-----------------------------------
		function saveInfo():void
		{

			var updated:Boolean = true;
			if (counter < cadresp.length)
			{
				var uid:String = trim(cadresp[counter]["uid"]);
				var nom:String = trim(cadresp[counter]["nom"]);
				var prenom:String = trim(cadresp[counter]["prenom"]);
				var matiere:String = trim(cadresp[counter]["matiere"]);
				var horaire:String = trim(cadresp[counter]["horaire"]);

				if (! isUpdated(nom,prenom,uid, matiere, horaire))
				{
					counter++;
					saveInfo();
				}
				else
				{
					nupdates++;
					amfPhp.addEventListener("cadre_saved", onCadreSaved);
					amfPhp.addEventListener("cadre_notsaved", onCadreNotSaved);
					amfPhp.saveCadre(php_save, uid, nom, prenom, matiere, horaire);
				}
			}
			else
			{
				dispatchEvent(new Event(CadresPanel.CADRES_SAVED));
			}
		}
		//-----------------------------------
		function onCadreSaved(reponse:Object):void
		{
			counter++;
			this.msg.text = "Enregistrement en cours... " + String(counter) + "/" + String(cadresp.length);
			this.msg.autoSize = TextFieldAutoSize.LEFT;
			saveInfo();
		}
		//-----------------------------------
		function onCadreNotSaved(reponse:Object):void
		{
			dispatchEvent(new Event(CadresPanel.CADRES_NOTSAVED));
		}
		//-----------------------------------
		public function restoreMsg():void
		{
			this.msg.text = "";
			this.msg.alpha = 1;
		}
		//-----------------------------------
		function isUpdated(nom:String, prenom:String, uid:String, matiere:String, horaire:String):Boolean
		{
			nom = trim(nom.toLowerCase());
			prenom = trim(prenom.toLowerCase());
			uid = trim(uid.toLowerCase());
			matiere = trim(matiere.toLowerCase());
			horaire = trim(horaire.toLowerCase());

			if (nom == "" && prenom == "" && uid == "" && matiere == "" && horaire == "")
			{
				return false;
			}
			var updated:Boolean = true;
			for (var n:int = 0; n < prev_cadresp.length; n++)
			{
				var prev_nom:String = trim(prev_cadresp[n]["nom"].toLowerCase());
				var prev_prenom:String = trim(prev_cadresp[n]["prenom"].toLowerCase());
				var prev_uid:String = trim(prev_cadresp[n]["uid"].toLowerCase());
				var prev_matiere:String = trim(prev_cadresp[n]["matiere"].toLowerCase());
				var prev_horaire:String = trim(prev_cadresp[n]["horaire"].toLowerCase());

				if ((uid == prev_uid && nom == prev_nom && prenom == prev_prenom && matiere == prev_matiere && horaire == prev_horaire))
				{
					updated = false;
				}
			}
			return updated;
		}
		//-----------------------------------

	}

}