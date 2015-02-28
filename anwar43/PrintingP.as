package 
{

	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.events.Event;
	import flash.display.MovieClip;

	import com.greensock.TweenLite;
	import com.greensock.*;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	import com.greensock.easing.*;

	public class PrintingP extends MovieClip
	{
		private var pages:Array = new Array();
		private var pj:PrintJob;
		private var options:PrintJobOptions;
		private var pageCount:int;

		public function PrintingP()
		{

		}
		public function printPortrait(pages:Array):void
		{
			this.pages = pages;
			pj = new PrintJob();
			options = new PrintJobOptions();
			options.printAsBitmap = true;
			pageCount = 0;
			startPrinting();
		}

		public function startPrinting():void
		{
			if (pj.start())
			{
				try
				{
					for (var p:int = 0; p < pages.length; p++)
					{
						var realW:Number = pages[p].width;
						var realH:Number = pages[p].height;
						var orgX:Number = pages[p].x;
						var orgY:Number = pages[p].y;

						pages[p].x = 0;
						pages[p].y = 0;
						var cscaleX:Number,cscaleY:Number;
						cscaleX = (pj.pageWidth / realW);
						cscaleY = (pj.pageHeight / realH);
						pages[p].scaleX = pages[p].scaleY = Math.min(cscaleX,cscaleY);

						var rect:Rectangle = new Rectangle(0,0,realW,realH);
						pj.addPage(pages[p],rect);

						pages[p].scaleX = pages[p].scaleY = 1;
						pages[p].rotation = 0;
						pages[p].x = orgX;
						pages[p].y = orgY;
						pageCount++;
					}
				}
				catch (e:Event)
				{
					trace("e= ", e);
				}
			}

			if (pageCount > 0)
			{
				pj.send();
			}
			pj = null;
		}


	}
}