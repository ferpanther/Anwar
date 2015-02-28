package
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.net.*;
	import fl.transitions.*;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import fl.motion.*;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.ui.Mouse;


	public class PanelBg extends MovieClip
	{

		public function PanelBg()
		{
			this.addEventListener(MouseEvent.MOUSE_OVER, toHand);
			this.addEventListener(MouseEvent.MOUSE_OUT, toAuto);
			this.addEventListener(MouseEvent.MOUSE_DOWN, drag);
			this.addEventListener(MouseEvent.MOUSE_UP, drop);
		}
		private function toHand(e:MouseEvent):void
		{
			Mouse.cursor="hand";
		}
		
		private function toAuto(e:MouseEvent):void
		{
			Mouse.cursor="auto";
		}

		private function drag(e:MouseEvent):void
		{
			e.currentTarget.parent.startDrag();
		}
		private function drop(e:MouseEvent):void
		{
			e.currentTarget.parent.stopDrag();
		}
		//----------------------------------------------------------------------------
	}
}