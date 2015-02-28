package com.flashblocks.utils
{

	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;

	public class Printing
	{

		public function Printing()
		{
		}

		public static function printLandscape(clip:Sprite):void
		{
			var realW:Number = clip.width;
			var realH:Number = clip.height;
			var orgX:Number = clip.x;
			var orgY:Number = clip.y;
			var pj:PrintJob = new PrintJob();
			var pageCount:Number = 0;

			if (! pj.start())
			{
				return;
			}

			clip.x = 0;
			clip.y = 0;
			var cscaleX:Number,cscaleY:Number;
			if (pj.orientation.toLowerCase() != "landscape")
			{
				clip.rotation = 90;
				clip.x = clip.width;
				cscaleX = (pj.pageWidth / realH);
				cscaleY = (pj.pageHeight / realW);
			}
			else
			{
				cscaleX = (pj.pageWidth / realW);
				cscaleY = (pj.pageHeight / realH);
			}
			clip.scaleX = clip.scaleY = Math.min(cscaleX,cscaleY);
			if (pj.addPage(clip,new Rectangle(0,0,realW,realH)))
			{
				pageCount++;
			}

			if (pageCount > 0)
			{
				pj.send();
			}
			clip.scaleX = clip.scaleY = 1;
			clip.rotation = 0;
			clip.x = orgX;
			clip.y = orgY;
			pj = null;
		}
	}
}
package com.flashblocks.utils
{

	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;

	public class Printing
	{

		public function Printing()
		{
		}

		public static function printLandscape(clip:Sprite):void
		{
			var realW:Number = clip.width;
			var realH:Number = clip.height;
			var orgX:Number = clip.x;
			var orgY:Number = clip.y;
			var pj:PrintJob = new PrintJob();
			var pageCount:Number = 0;

			if (! pj.start())
			{
				return;
			}

			clip.x = 0;
			clip.y = 0;
			var cscaleX:Number,cscaleY:Number;
			if (pj.orientation.toLowerCase() != "landscape")
			{
				clip.rotation = 90;
				clip.x = clip.width;
				cscaleX = (pj.pageWidth / realH);
				cscaleY = (pj.pageHeight / realW);
			}
			else
			{
				cscaleX = (pj.pageWidth / realW);
				cscaleY = (pj.pageHeight / realH);
			}
			clip.scaleX = clip.scaleY = Math.min(cscaleX,cscaleY);
			if (pj.addPage(clip,new Rectangle(0,0,realW,realH)))
			{
				pageCount++;
			}

			if (pageCount > 0)
			{
				pj.send();
			}
			clip.scaleX = clip.scaleY = 1;
			clip.rotation = 0;
			clip.x = orgX;
			clip.y = orgY;
			pj = null;
		}
	}
}