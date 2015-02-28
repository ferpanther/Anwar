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


	public class ParamsPanel extends MovieClip
	{
		public var ret:int = 0;
		public var paramsA:Array = new Array();
		public var paramsF:Array = new Array();
		private var inputsA:Array = new Array();
		private var inputsF:Array = new Array();

		public var cat:String = "pers";

		public function ParamsPanel()
		{
			this.form.visible = false;
			this.pers.visible = true;
			
			this.pers_tab.txt.htmlText = "<b>" + this.pers_tab.txt.text +"</b>";
			this.form_tab.txt.htmlText = this.form_tab.txt.text;
			this.form_tab.txt.textColor = 0xcccccc;
			this.form_tab.buttonMode = true;
			this.pers_tab.addEventListener(MouseEvent.CLICK, tabClicked);
			this.form_tab.addEventListener(MouseEvent.CLICK, tabClicked);

			inputsA.splice(0);
			inputsA.push(pers.p0);
			inputsA.push(pers.p1);
			inputsA.push(pers.p2);
			inputsA.push(pers.p3);
			inputsA.push(pers.p4);

			inputsA.push(pers.p5);
			inputsA.push(pers.p6);
			inputsA.push(pers.p7);
			inputsA.push(pers.p8);
			inputsA.push(pers.p9);

			inputsF.splice(0);
			inputsF.push(form.p0);
			inputsF.push(form.p1);
			inputsF.push(form.p2);
			inputsF.push(form.p3);
			inputsF.push(form.p4);

			inputsF.push(form.p5);
			inputsF.push(form.p6);
			inputsF.push(form.p7);
			inputsF.push(form.p8);
			inputsF.push(form.p9);

			for (var v:int = 0; v < inputsA.length; v++)
			{
				paramsA[v] = inputsA[v].text;
				inputsA[v].tabIndex = (v+1);
				inputsA[v].restrict = "0-9";
			}
			setParamsA(paramsA);

			for (v = 0; v < inputsF.length; v++)
			{
				paramsF[v] = inputsF[v].text;
				inputsF[v].tabIndex = (v+1);
				inputsF[v].restrict = "0-9";
			}
			setParamsF(paramsF);
		}
		private function tabClicked(e:MouseEvent):void
		{
			cat = e.currentTarget.name;
			cat = cat.substr(0, cat.indexOf("_"));

			setCat(cat);

			switch (cat)
			{
				case "pers" :
					this.pers_tab.txt.htmlText = "<b>" + this.pers_tab.txt.text +"</b>";
					this.form_tab.txt.htmlText = this.form_tab.txt.text;
					this.form_tab.txt.textColor = 0xcccccc;
					this.form.visible = false;
					this.pers.visible = true;
					break;
				case "form" :
					this.form_tab.txt.htmlText = "<b>" + this.form_tab.txt.text +"</b>";
					this.pers_tab.txt.htmlText = this.pers_tab.txt.text;
					this.form_tab.txt.textColor = 0xffffff;
					this.form.visible = true;
					this.pers.visible = false;
					break;
			}
		}

		public function setCat(cat:String):void
		{
			this.cat = cat;
		}
		public function getCat():String
		{
			return this.cat;
		}

		public function setParamsA(arr:Array):void
		{
			this.paramsA = arr;
			for (var v:int = 0; v < paramsA.length; v++)
			{
				inputsA[v].text = String(paramsA[v]);
			}
		}
		public function getParamsA():Array
		{
			for (var v:int = 0; v < inputsA.length; v++)
			{
				paramsA[v] = Number(inputsA[v].text);
			}
			return this.paramsA;
		}

		public function setParamsF(arr:Array):void
		{
			this.paramsF = arr;
			for (var v:int = 0; v < paramsF.length; v++)
			{
				inputsF[v].text = String(paramsF[v]);
			}
		}
		public function getParamsF():Array
		{
			for (var v:int = 0; v < inputsF.length; v++)
			{
				paramsF[v] = Number(inputsF[v].text);
			}
			return this.paramsF;
		}
	}
}