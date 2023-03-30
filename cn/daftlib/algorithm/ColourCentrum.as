package cn.daftlib.algorithm
{
	import flash.display.BitmapData;
	
	import cn.daftlib.display.DaftBitmap;

	public class ColourCentrum extends DaftBitmap
	{
		private var __width:int;
		private var __height:int;

		public function ColourCentrum(width:int, height:int)
		{
			super(null, "auto", false);

			__width = width;
			__height = height;

			this.bitmapData = new BitmapData(__width, __height, false, 0x0);

			var j:uint = 0;
			var color:uint;
			while(j < __height)
			{
				var i:uint = 0;
				while(i < __width)
				{
					this.bitmapData.setPixel(i, j, (RD(i, j) << 16 | GR(i, j) << 8 | BL(i, j)));
					i++;
				}
				j++;
			}
		}
		private function RD(i:int, j:int):Number
		{
			return (_sq(Math.cos(Math.atan2(j - __height * .5, i - __width * .5) / 2)) * 255);
		}
		private function GR(i:int, j:int):Number
		{
			return (_sq(Math.cos(Math.atan2(j - __height * .5, i - __width * .5) / 2 - 2 * Math.acos(-1) / 3)) * 255);
		}
		private function BL(i:int, j:int):Number
		{
			return (_sq(Math.cos(Math.atan2(j - __height * .5, i - __width * .5) / 2 + 2 * Math.acos(-1) / 3)) * 255);
		}
		private function _sq(value:Number):Number
		{
			return value * value;
		}
		/*unsigned char RD(int i,int j){
			return (char)(_sq(cos(atan2(j-512,i-512)/2))*255);
		}
		
		unsigned char GR(int i,int j){
			return (char)(_sq(cos(atan2(j-512,i-512)/2-2*acos(-1)/3))*255);
		}
		
		unsigned char BL(int i,int j){
			return (char)(_sq(cos(atan2(j-512,i-512)/2+2*acos(-1)/3))*255);
		}*/
	}
}