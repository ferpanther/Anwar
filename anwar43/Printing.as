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

	public class Printing extends MovieClip
	{

		public function Printing()
		{
		}

		public function printLandscape(clip:Sprite):void
		{
			try
			{
				var realW:Number = clip.width;
				var realH:Number = clip.height;
				var orgX:Number = clip.x;
				var orgY:Number = clip.y;
				var pj:PrintJob = new PrintJob();
				var options:PrintJobOptions = new PrintJobOptions();
				options.printAsBitmap = true;
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

				var rect:Rectangle = new Rectangle(0,0,realW,realH);
				if (pj.addPage(clip,rect))
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
			catch (e:Event)
			{
				trace("e= ", e);
			}

		}


	}
}