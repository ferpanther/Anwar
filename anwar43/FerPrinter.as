package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.text.TextFieldAutoSize;
	import flash.printing.PrintJob;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;

	public class FerPrinter extends Sprite
	{
		private var page:MovieClip = new MovieClip();
		private var page_height:int = 840;
		public var scal:Number = 1;

		//--------------------------------------------------------------------------------------------------------
		public function FerPrinter(_page:MovieClip, _scale:Number)
		{
			page = _page;
			this.scal = _scale;

			dispatchEvent(new Event(Event.COMPLETE));
			Print();
		}
		//--------------------------------------------------------------------------------------------------------
		private function Print():void
		{
			var myPrintJob:PrintJob = new PrintJob  ;

			page.scaleX = this.scal;
			page.scaleY = this.scal;

			if (myPrintJob.start())
			{
				
				trace(">> page.scaleY: " + page.scaleX, page.scaleY);
				trace(">> page.width, page.height: " + page.width, page.height);
				trace(">> pj.orientation: " + myPrintJob.orientation);
				trace(">> pj.pageWidth, pj.pageHeight " + myPrintJob.pageWidth, myPrintJob.pageHeight);
				trace(">> pj.paperWidth, pj.paperHeight: " + myPrintJob.paperWidth, myPrintJob.paperHeight);

				try
				{
					while (page.width > (myPrintJob.pageWidth-20))
					{
						page.scaleX -=  .01;
						page.scaleY -=  .01;
					}

					myPrintJob.addPage(page);
					page.scaleX = 1;
					page.scaleY = 1;
				}
				catch (e:Error)
				{
					trace(e);
				}
				myPrintJob.send();
			}
		}
		//--------------------------------------------------------------------------------------------------------

	}

}