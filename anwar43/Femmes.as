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

	public class Femmes extends MovieClip
	{
		public static const FEMMES_SAVED:String = "femmes_saved";
		public static const FEMMES_NOTSAVED:String = "femmes_notsaved";
		public static const FEMME_DELETED:String = "femme_deleted";
		public static const FEMME_NOTDELETED:String = "femme_notdeleted";

		public var amfPhp:AmfPhp = new AmfPhp();
		public var php_load:String;
		public var php_save:String;
		public var php_delete:String;

		public var deletePanel:DeletePanel;
		public var femmes:Array = new Array();
		private var prev_femmes:Array = new Array();
		private var rows:Array = new Array();
		private var counter:int;
		public var nupdates:int;

		private var curr_row:int = 0;
		private var next_row:int = 0;
		private var prev_row:int = 0;

		//-----------------------------------
		public function Femmes()
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

			this.sp.tabEnabled = false;

			this.add_btn.addEventListener(MouseEvent.CLICK, addRow);

		}
		//-----------------------------------;
		private function fillRows():void
		{
			this.add_btn.enabled = true;
			clearHolder();
			var xx:int = 0;
			var yy:int = 0;
			var tab:int = 1;

			rows.splice(0);
			for (var r:int = 0; r < femmes.length; r++)
			{
				rows[r] = new RowFemmes();
				rows[r].name = "row_" + String(r);
				rows[r].nbr.text = String(r + 1);
				rows[r].nom.text = femmes[r]["nom"];
				rows[r].prenom.text = femmes[r]["prenom"];
				rows[r].uid.text = femmes[r]["uid"];

				rows[r].nbr.border = true;
				rows[r].nom.border = true;
				rows[r].prenom.border = true;
				rows[r].uid.border = true;

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

				rows[r].nom.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
				rows[r].prenom.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
				rows[r].uid.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);

				rows[r].nom.addEventListener(FocusEvent.FOCUS_IN, onFocus);
				rows[r].prenom.addEventListener(FocusEvent.FOCUS_IN, onFocus);
				rows[r].uid.addEventListener(FocusEvent.FOCUS_IN, onFocus);

				this.holder.addChild(rows[r]);
			}
			this.sp.source = this.holder;
			if (femmes.length == 0)
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
							stage.focus = rows[next_row].nom;
							break;
					}
					break;

				case 37 :
					//left
					switch (e.currentTarget.name)
					{
						case "nom" :
							stage.focus = rows[prev_row].uid;
							break;
						case "prenom" :
							stage.focus = rows[curr_row].nom;
							break;
						case "uid" :
							stage.focus = rows[curr_row].prenom;
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
					femmes[curr_row]["nom"] = e.currentTarget.text;
					break;
				case "prenom" :
					femmes[curr_row]["prenom"] = e.currentTarget.text;
					break;
				case "uid" :
					femmes[curr_row]["uid"] = e.currentTarget.text;
					break;
			}

			this.msg.text = "";
		}
		//------------------------------------
		private function addRow(e:MouseEvent=null):void
		{
			femmes.push({"nom":"", "prenom":"", "uid":""});
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
		//------------------------------------
		public function updateButtonStyle(btn:Button):void
		{
			var tf:TextFormat = new TextFormat();
			tf.size = 18;
			tf.color = 0x000000;
			tf.font = "Times New Roman";
			btn.setStyle("textFormat", tf);
			btn.setSize(btn.width, 35);
			btn.useHandCursor = true;
		}
		//-----------------------------------
		public function parseXml(xml:XML):void
		{
			this.msg.text = "";

			var xml_list:XMLList = xml.children();

			femmes.splice(0);
			prev_femmes.splice(0);
			for (var m:int = 0; m < xml_list.length(); m++)
			{
				femmes.push({"nom":xml_list[m]. @ nom, "prenom":xml_list[m]. @ prenom, "uid":xml_list[m]. @ uid});
				prev_femmes.push({"nom":xml_list[m]. @ nom, "prenom":xml_list[m]. @ prenom, "uid":xml_list[m]. @ uid});
			}
			femmes.sortOn("nom", Array.CASEINSENSITIVE);
			prev_femmes.sortOn("nom", Array.CASEINSENSITIVE);
			dispatchEvent(new Event(Event.COMPLETE));

			fillRows();
		}
		//-----------------------------------
		public function getFemmes():Array
		{
			return this.femmes;
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
		//-----------------------------------;
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

			deletePanel = new DeletePanel(femmes);
			deletePanel.addEventListener(Event.COMPLETE, onDeleteComplete);
			deletePanel.x = this.delete_btn.x;
			deletePanel.y = this.delete_btn.y - deletePanel.bg.height - 10;
			this.addChild(deletePanel);
		}
		//-----------------------------------
		function onDeleteComplete(e:Event):void
		{
			if (deletePanel.ret == 1)
			{
				deleteFemmes(deletePanel.nbr);
			}
			else
			{
				enableAll();
			}
		}
		//-----------------------------------
		public function deleteFemmes(n:int):void
		{
			restoreMsg();
			this.msg.text = "Suppression en cours...";
			var uid_st:String = femmes[n]["uid"];

			amfPhp.addEventListener("femme_deleted", onDeleteResult);
			amfPhp.addEventListener("femme_notdeleted", onDeleteFault);
			amfPhp.deleteFemmes(php_delete, uid_st);
		}
		//-----------------------------------
		function onDeleteResult(reponse:Object):void
		{
			amfPhp.removeEventListener("femme_deleted", onDeleteResult);
			this.msg.text = "Suppression terminée.";
			this.msg.autoSize = TextFieldAutoSize.LEFT;
			new TweenLite(this.msg,5,{alpha:1,onComplete:restoreMsg});
			enableAll();
			dispatchEvent(new Event(Femmes.FEMME_DELETED));
		}
		//-----------------------------------
		function onDeleteFault(reponse:Object):void
		{
			amfPhp.removeEventListener("femme_notdeleted", onDeleteFault);
			this.msg.text = "Échec de la suppression.";
			new TweenLite(this.msg,15,{alpha:0,onComplete:restoreMsg});
			enableAll();
			dispatchEvent(new Event(Femmes.FEMME_NOTDELETED));
		}
		//-----------------------------------
		public function saveFemmes(_php_save:String):void
		{
			php_save = _php_save;
			this.add_btn.enabled = false;
			this.save_btn.enabled = false;

			counter = 0;
			nupdates = 0;
			restoreMsg();
			this.msg.text = "Enregistrement en cours...";
			femmes.sortOn("nom", Array.CASEINSENSITIVE);
			prev_femmes.sortOn("nom", Array.CASEINSENSITIVE);
			saveInfo();
		}
		//-----------------------------------
		function saveInfo():void
		{
			var updated:Boolean = true;
			if (counter < femmes.length)
			{
				var uid:String = trim(femmes[counter]["uid"]);
				var nom:String = trim(femmes[counter]["nom"]);
				var prenom:String = trim(femmes[counter]["prenom"]);

				if (! isUpdated(nom,prenom,uid))
				{
					counter++;
					saveInfo();
				}
				else
				{
					nupdates++;
					amfPhp.addEventListener("femme_saved", onFemmeSaved);
					amfPhp.addEventListener("femme_notsaved", onFemmeNotSaved);
					amfPhp.saveFemmes(php_save, uid, nom, prenom);
				}
			}
			else
			{
				dispatchEvent(new Event(Femmes.FEMMES_SAVED));
			}
		}
		//-----------------------------------
		function onFemmeSaved(reponse:Object):void
		{
			counter++;
			this.msg.text = "Enregistrement en cours... " + String(counter) + "/" + String(femmes.length);
			this.msg.autoSize = TextFieldAutoSize.LEFT;
			saveInfo();
		}
		//-----------------------------------
		function onFemmeNotSaved(reponse:Object):void
		{
			dispatchEvent(new Event(Femmes.FEMMES_NOTSAVED));
			this.msg.text = "Échec de l'Enregistrement.";
			new TweenLite(this.msg,15,{alpha:0,onComplete:restoreMsg});
			this.add_btn.enabled = true;
			this.save_btn.enabled = true;
		}
		//-----------------------------------
		public function restoreMsg():void
		{
			this.msg.text = "";
			this.msg.alpha = 1;
		}
		//-----------------------------------
		function isUpdated(nom:String, prenom:String, uid:String):Boolean
		{
			nom = trim(nom.toLowerCase());
			prenom = trim(prenom.toLowerCase());
			uid = trim(uid.toLowerCase());

			if (nom == "" && prenom == "" && uid == "")
			{
				return false;
			}
			var updated:Boolean = true;
			for (var n:int = 0; n < prev_femmes.length; n++)
			{
				var prev_nom:String = trim(prev_femmes[n]["nom"].toLowerCase());
				var prev_prenom:String = trim(prev_femmes[n]["prenom"].toLowerCase());
				var prev_uid:String = trim(prev_femmes[n]["uid"].toLowerCase());

				if ((uid == prev_uid && nom == prev_nom && prenom == prev_prenom))
				{
					updated = false;
				}
			}
			return updated;
		}
		//-----------------------------------

	}

}