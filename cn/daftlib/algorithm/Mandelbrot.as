package cn.daftlib.algorithm
{
	import flash.display.BitmapData;
	
	import cn.daftlib.display.DaftBitmap;
	
	public class Mandelbrot extends DaftBitmap
	{
		private var __width:int;
		private var __height:int;
		
		public function Mandelbrot(width:int, height:int)
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
			var x:Number=0,y:Number=0;var k:int;for(k=0;k++<256;){var a:Number=x*x-y*y+(i-__width*.75)/(__width*.5);y=2*x*y+(j-__height/2)/(__height*.5);x=a;if(x*x+y*y>4)break;}return Math.log(k)*47;
		}
		private function GR(i:int, j:int):Number
		{
			var x:Number=0,y:Number=0;var k:int;for(k=0;k++<256;){var a:Number=x*x-y*y+(i-__width*.75)/(__width*.5);y=2*x*y+(j-__height/2)/(__height*.5);x=a;if(x*x+y*y>4)break;}return Math.log(k)*47;
		}
		private function BL(i:int, j:int):Number
		{
			var x:Number=0,y:Number=0;var k:int;for(k=0;k++<256;){var a:Number=x*x-y*y+(i-__width*.75)/(__width*.5);y=2*x*y+(j-__height/2)/(__height*.5);x=a;if(x*x+y*y>4)break;}return 128-Math.log(k)*23;
		}
		/*unsigned char RD(int i,int j){
			float x=0,y=0;int k;for(k=0;k++<256;){float a=x*x-y*y+(i-768.0)/512;y=2*x*y+(j-512.0)/512;x=a;if(x*x+y*y>4)break;}return log(k)*47;
		}
		
		unsigned char GR(int i,int j){
			float x=0,y=0;int k;for(k=0;k++<256;){float a=x*x-y*y+(i-768.0)/512;y=2*x*y+(j-512.0)/512;x=a;if(x*x+y*y>4)break;}return log(k)*47;
		}
		
		unsigned char BL(int i,int j){
			float x=0,y=0;int k;for(k=0;k++<256;){float a=x*x-y*y+(i-768.0)/512;y=2*x*y+(j-512.0)/512;x=a;if(x*x+y*y>4)break;}return 128-log(k)*23;
		}*/
	}
}