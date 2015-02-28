package 
{
	import com.greensock.TweenLite;
	import com.greensock.*;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.easing.*;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import fl.managers.FocusManager;


	public class DeletePanel extends MovieClip
	{
		private var nom:String;
		private var prenom:String;
		private var uid:String;
		private var arr:Array;
		public var ret:int = 0;
		public var nbr:int = -1;

		public function DeletePanel(_arr:Array)
		{
			this.arr = _arr;

			this.visible = true;
			this.confirm_btn.enabled = true;
			this.cancel_btn.enabled = true;
			this.msg1.text = "Entrer le N° à supprimer:";
			this.msg.text = "";
			this.input.text = "";

			updateButtonStyle(this.confirm_btn);
			updateButtonStyle(this.cancel_btn);

			this.input.tabIndex = 1;
			this.cancel_btn.tabIndex = 2;
			this.confirm_btn.tabIndex = 3;

			this.input.restrict = "0-9";

			this.input.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
			this.confirm_btn.addEventListener(MouseEvent.CLICK, confirmClicked);
			this.cancel_btn.addEventListener(MouseEvent.CLICK, cancelClicked);

		}
		//----------------------------------------------------------------------------------------;
		private function onKEY_DOWN(e : KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case 13 :
					stage.focus = this.cancel_btn;
					break;
			}
		}
		//----------------------------------------------------------------------------------------
		private function cancelClicked(e : MouseEvent):void
		{
			this.visible = false;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		//----------------------------------------------------------------------------------------
		private function confirmClicked(e : MouseEvent):void
		{
			nbr = int(this.input.text) - 1;
			if (nbr >= 0 && nbr < arr.length && this.input.text != "")
			{
				this.confirm_btn.enabled = false;
				new TweenLite(this, 1, {y: this.y+90, onComplete:restore});
				this.input.visible = false;
				this.confirm_btn.removeEventListener(MouseEvent.CLICK, confirmClicked);
				this.confirm_btn.addEventListener(MouseEvent.CLICK, confirm2Clicked);

				this.msg1.text = "AVERTISSEMENT!";
				this.msg.text = "Vous allez définitivement supprimer ce nom de la liste. Cette action ne peut plus être défaite!";
				this.msg.appendText("\nNom: " + arr[nbr]["nom"]);
				if (arr[nbr]["prenom"] != undefined)
				{
					this.msg.appendText("\nPrenom: " + arr[nbr]["prenom"]);
					this.msg.appendText("\nIdentifiant Unique: " + arr[nbr]["uid"]);
				}

				this.msg.autoSize = TextFieldAutoSize.LEFT;
			}
		}
		//----------------------------------------------------------------------------------------
		private function restore():void
		{
			this.confirm_btn.enabled = true;
		}
		//----------------------------------------------------------------------------------------
		private function confirm2Clicked(e : MouseEvent):void
		{
			ret = 1;
			dispatchEvent(new Event(Event.COMPLETE));
			this.visible = false;
		}
		//---------------------------------------------------------------------
		private function updateButtonStyle(btn:Button):void
		{
			var tf:TextFormat = new TextFormat();
			tf.size = 18;
			tf.color = 0x330000;
			tf.font = "Times New Roman";
			tf.bold = true;
			btn.setStyle("textFormat", tf);
			btn.setSize(btn.width, 25);
			btn.useHandCursor = true;
		}
	}
}