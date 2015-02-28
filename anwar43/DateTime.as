package 
{
	import flash.display.MovieClip;
	
	public class DateTime extends MovieClip
	{

		public function DateTime()
		{
			
		}
		//------------------------------------------------------------------------------------------------------
		public function getTime():String
		{
			var date:Date = new Date();
			var mm:int = date.getMinutes();
			var hh:int = date.getHours();
			var st_mm:String = (mm > 9) ? String(mm) : "0" + String(mm);
			var st_hh:String = (hh > 9) ? String(hh) : "0" + String(hh);
			var tmp:String = st_hh + ":" + st_mm;
			return tmp;
		}
		//--------------------------------------------------------------------------------------------------------

	}

}