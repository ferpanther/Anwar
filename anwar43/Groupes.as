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

	public class Groupes extends MovieClip
	{
		public static const GROUPES_SAVED:String = "groupes_saved";
		public static const GROUPE_DELETED:String = "groupe_deleted";
		public static const GROUPE_NOTDELETED:String = "groupe_notdeleted";

		public var amfPhp:AmfPhp = new AmfPhp();

		public var deletePanel:DeletePanel;
		private var groupes:Array = new Array();
		public var nupdates:int;

		private var prev_groupes:Array = new Array();
		private var rows:Array = new Array();
		private var counter:int;
		private var curr_row:int = 0;
		private var next_row:int = 0;
		private var prev_row:int = 0;

		//-----------------------------------
		public function Groupes()
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
		//--------------------------------------------
		private function init(e:Event = null):void
		{
			if (e != null)
			{
				this.removeEventListener(Event.ADDED_TO_STAGE, init);
			}
			showPanel();
		}
		//------------------------------------------------
		public function getGroupes():Array
		{
			return this.groupes;
		}
		//--------------------------------------------
		public function showPanel():void
		{
			this.year.htmlText = getYear();
			this.msg.text = "";

			this.nbr.border = true;
			this.nom.border = true;

			this.sp.tabEnabled = false;

			this.add_btn.addEventListener(MouseEvent.CLICK, addRow);
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
		//------------------------------------------------;
		public function deleteRow():void
		{
			disableAll();

			deletePanel = new DeletePanel(groupes);
			deletePanel.addEventListener(Event.COMPLETE, onDeleteComplete);
			deletePanel.x = this.delete_btn.x;
			deletePanel.y = this.delete_btn.y - deletePanel.bg.height - 10;
			this.addChild(deletePanel);
		}
		//------------------------------------------------
		function onDeleteComplete(e:Event):void
		{
			if (deletePanel.ret == 1)
			{
				deleteGroupe(deletePanel.nbr);
			}
			else
			{
				enableAll();
			}
		}
		//------------------------------------------------
		public function deleteGroupe(n:int):void
		{
			restoreMsg();
			this.msg.text = "Suppression en cours...";
			var uid_st:String = escape(groupes[n]["nom"]);

			amfPhp.addEventListener("groupe_deleted", onDeleteResult);
			amfPhp.addEventListener("groupe_notdeleted", onDeleteFault);
			amfPhp.deleteGroupe(uid_st);

		}
		//------------------------------------------------
		function onDeleteResult(reponse:Object):void
		{
			amfPhp.removeEventListener("groupe_deleted", onDeleteResult);
			this.msg.text = "Suppression terminée.";
			this.msg.autoSize = TextFieldAutoSize.LEFT;
			new TweenLite(this.msg,5,{alpha:1,onComplete:restoreMsg});
			enableAll();
			dispatchEvent(new Event(Groupes.GROUPE_DELETED));
		}
		//------------------------------------------------
		function onDeleteFault(reponse:Object):void
		{
			amfPhp.removeEventListener("groupe_notdeleted", onDeleteFault);
			this.msg.text = "Échec de la suppression.";
			new TweenLite(this.msg,15,{alpha:0,onComplete:restoreMsg});
			enableAll();
			dispatchEvent(new Event(Groupes.GROUPE_NOTDELETED));
		}
		//------------------------------------------------
		public function parseXml(xml:XML):void
		{
			this.msg.text = "";
			var xml_list:XMLList = xml.children();

			groupes.splice(0);
			prev_groupes.splice(0);
			for (var m:int = 0; m < xml_list.length(); m++)
			{
				groupes.push({"nom":unescape(xml_list[m]. @ nom)});
				prev_groupes.push({"nom":unescape(xml_list[m]. @ nom)});
			}
			groupes.sortOn("nom", Array.CASEINSENSITIVE);
			prev_groupes.sortOn("nom", Array.CASEINSENSITIVE);

			fillRows();
		}
		//------------------------------------------------
		private function fillRows():void
		{
			this.add_btn.enabled = true;
			clearHolder();
			var xx:int = 0;
			var yy:int = 0;

			rows.splice(0);
			for (var r:int = 0; r < groupes.length; r++)
			{
				rows[r] = new RowGroupe();
				rows[r].name = "row_" + String(r);
				rows[r].nbr.text = String(r + 1);
				rows[r].nbr.border = true;
				rows[r].nom.text = groupes[r]["nom"];
				rows[r].nom.border = true;

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
				rows[r].nom.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
				rows[r].nom.addEventListener(FocusEvent.FOCUS_IN, onFocus);

				this.holder.addChild(rows[r]);
			}
			this.sp.source = this.holder;
			if (groupes.length == 0)
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
		//--------------------------------------------
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
							stage.focus = rows[next_row].nom;
							break;
					}
					break;

				case 37 :
					//left
					switch (e.currentTarget.name)
					{
						case "nom" :
							stage.focus = rows[prev_row].nom;
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
					}
					break;

				case 38 :
					//up
					switch (e.currentTarget.name)
					{
						case "nom" :
							stage.focus = rows[prev_row].nom;
							break;
					}
					break;
			}
		}
		//--------------------------------------------
		private function onChange(e:Event):void
		{
			curr_row = int(e.currentTarget.parent.name.substr(4));
			switch (e.currentTarget.name)
			{
				case "nom" :
					groupes[curr_row]["nom"] = e.currentTarget.text;
					break;
			}

			this.msg.text = "";
		}
		//--------------------------------------------
		private function addRow(e:MouseEvent=null):void
		{
			groupes.push({"nom":""});
			fillRows();
			this.sp.verticalScrollPosition = this.sp.maxVerticalScrollPosition;
			stage.focus = rows[rows.length - 1]["nom"];
		}
		//--------------------------------------------
		public function getYear():String
		{
			var date:Date = new Date();
			var year = date.getFullYear();
			var year_st:String = String(year) + " / " + String(year + 1);
			return year_st;
		}
		//--------------------------------------------
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
		//--------------------------------------------
		private function trim(st:String):String
		{
			while (st.charAt(0) == " ")
			{
				st = st.substr(1);
			}
			return st;
		}
		//------------------------------------------------
		public function saveGroupes():void
		{
			counter = 0;
			nupdates = 0;
			restoreMsg();
			this.msg.text = "Enregistrement en cours...";
			groupes.sortOn("nom", Array.CASEINSENSITIVE);
			prev_groupes.sortOn("nom", Array.CASEINSENSITIVE);
			saveInfo();
		}
		//------------------------------------------------
		function saveInfo():void
		{
			var updated:Boolean = true;
			if (counter < groupes.length)
			{
				var nom:String = trim(groupes[counter]["nom"]);
				if (! isUpdated(nom))
				{
					counter++;
					saveInfo();
				}
				else
				{
					nupdates++;

					amfPhp.addEventListener("groupe_saved", onGroupeSaved);
					amfPhp.addEventListener("groupe_notsaved", onSaveFault);
					amfPhp.saveGroupes(escape(nom));
				}
			}
			else
			{
				dispatchEvent(new Event(Groupes.GROUPES_SAVED));
			}
		}
		//------------------------------------------------
		function onGroupeSaved(e:Event):void
		{
			amfPhp.removeEventListener("groupe_saved", onGroupeSaved);
			counter++;
			this.msg.text = "Enregistrement en cours... " + String(counter) + "/" + String(groupes.length);
			this.msg.autoSize = TextFieldAutoSize.LEFT;
			saveInfo();
		}
		//------------------------------------------------
		function onSaveFault(reponse:Object):void
		{
			amfPhp.removeEventListener("groupe_notsaved", onSaveFault);
			this.msg.text = "Échec de l'Enregistrement.";
			new TweenLite(this.msg,15,{alpha:0,onComplete:restoreMsg});
			this.add_btn.enabled = true;
			this.save_btn.enabled = true;
		}
		//------------------------------------------------
		public function restoreMsg():void
		{
			//this.msg.textColor = 0xffffff;
			this.msg.text = "";
			this.msg.alpha = 1;
		}
		//------------------------------------------------
		function isUpdated(nom:String):Boolean
		{
			nom = trim(nom.toLowerCase());

			if (nom == "")
			{
				return false;
			}
			var updated:Boolean = true;
			for (var n:int = 0; n < prev_groupes.length; n++)
			{
				var prev_nom:String = trim(prev_groupes[n]["nom"].toLowerCase());

				if ((nom == prev_nom))
				{
					updated = false;
					break;
				}
			}
			return updated;
		}
		//-----------------------------------

	}

}