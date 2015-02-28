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


	public class DatePanel extends MovieClip
	{
		public var ret:int = 0;
		public var date:Date;
		public var dd:int;
		public var jj:int;
		public var mm:int;
		public var yy:int;
		public var ms:Number;
		private var joursParMois:Array = new Array();

		public function DatePanel()
		{
			this.visible = true;
			this.confirm_btn.enabled = true;
			this.cancel_btn.enabled = true;
			this.jj_txt.text = "";
			this.mm_txt.text = "";
			this.yy_txt.text = "";

			this.jj_txt.tabIndex = 1;
			this.mm_txt.tabIndex = 2;
			this.yy_txt.tabIndex = 3;
			this.cancel_btn.tabIndex = 4;
			this.confirm_btn.tabIndex = 5;

			updateButtonStyle(this.confirm_btn);
			updateButtonStyle(this.cancel_btn);



			this.jj_txt.restrict = "0-9";
			this.mm_txt.restrict = "0-9";
			this.yy_txt.restrict = "0-9";

			this.jj_txt.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
			this.mm_txt.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
			this.yy_txt.addEventListener(KeyboardEvent.KEY_DOWN, onKEY_DOWN);
			this.confirm_btn.addEventListener(MouseEvent.CLICK, confirmClicked);
			this.cancel_btn.addEventListener(MouseEvent.CLICK, cancelClicked);

		}
		//------------------------------------------;
		private function isValidDate(jj, mm, yy):Boolean
		{
			joursParMois[0] = 31;
			joursParMois[1] = (yy % 4 == 0) ? 29:28;
			joursParMois[2] = 31;
			joursParMois[3] = 30;
			joursParMois[4] = 31;
			joursParMois[5] = 30;
			joursParMois[6] = 31;
			joursParMois[7] = 31;
			joursParMois[8] = 30;
			joursParMois[9] = 31;
			joursParMois[10] = 30;
			joursParMois[11] = 31;

			if (mm <= 0 || mm > 12)
			{
				return false;
			}
			if (jj <= 0 || jj > joursParMois[mm - 1])
			{
				return false;
			}

			return true;
		}
		//------------------------------------------
		private function onKEY_DOWN(e : KeyboardEvent):void
		{
			switch (e.keyCode)
			{
				case 13 :
					switch (e.currentTarget.name)
					{
						case "jj_txt" :
							if (jj_txt.text == "")
							{
								jj_txt.text = String(new Date().getDate());
								if (jj_txt.text.length < 2)
								{
									jj_txt.text = "0" + jj_txt.text;
								}
							}
							stage.focus = this.mm_txt;
							break;
						case "mm_txt" :
							if (mm_txt.text == "")
							{
								mm_txt.text = String(new Date().getMonth()+1);
								if (mm_txt.text.length < 2)
								{
									mm_txt.text = "0" + mm_txt.text;
								}
							}
							stage.focus = this.yy_txt;
							break;
						case "yy_txt" :
							if (yy_txt.text == "")
							{
								yy_txt.text = String(new Date().getFullYear());
							}
							stage.focus = this.confirm_btn;
							break;
					}
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
			jj = int(this.jj_txt.text);
			mm = int(this.mm_txt.text);
			yy = int(this.yy_txt.text);

			if (isValidDate(jj,mm,yy))
			{
				date = new Date(yy,mm-1,jj,0,0,0,0);
				dd = date.getDay();
				jj = date.getDate();
				mm = date.getMonth();
				yy = date.getFullYear();
				ms = date.valueOf();
				
				this.confirm_btn.enabled = false;
				this.confirm_btn.removeEventListener(MouseEvent.CLICK, confirmClicked);

				ret = 1;
				dispatchEvent(new Event(Event.COMPLETE));
				this.visible = false;
			}
		}
		//---------------------------------------------------------------------
		private function updateButtonStyle(btn:Button):void
		{
			var tf:TextFormat = new TextFormat();
			tf.size = 18;
			tf.color = 0x000000;
			tf.font = "Times New Roman";
			tf.bold = true;
			btn.setStyle("textFormat", tf);
			btn.setSize(btn.width, 25);
			btn.useHandCursor = true;
		}
	}
}