package cn.daftlib.utils
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display3D.Context3D;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import cn.daftlib.color.HSL;
	import cn.daftlib.color.RGB32;

	public final class BitmapDataUtil
	{
		/**
		 * Select color just like photoshop magic wond
		 * @param $bitmapData
		 * @param $RGB
		 * @param $offsetRange
		 * @return
		 */
		public static function selectColors(target:BitmapData, color24:uint, offsetRange:uint = 50):BitmapData
		{
			const ZERO:Point = new Point();

			var range:Array = [-offsetRange, offsetRange];

			var rmin:Number = Math.min(255, Math.max(0, ((color24 >> 16) & 0xff) + range[0]));
			var gmin:Number = Math.min(255, Math.max(0, ((color24 >> 8) & 0xff) + range[0]));
			var bmin:Number = Math.min(255, Math.max(0, (color24 & 0xff) + range[0]));
			var rgbMin:Number = rmin << 16 | gmin << 8 | bmin;

			var rmax:Number = Math.min(255, Math.max(0, ((color24 >> 16) & 0xff) + range[1]));
			var gmax:Number = Math.min(255, Math.max(0, ((color24 >> 8) & 0xff) + range[1]));
			var bmax:Number = Math.min(255, Math.max(0, (color24 & 0xff) + range[1]));
			var rgbMax:Number = rmax << 16 | gmax << 8 | bmax;

			rmin = (rgbMin >> 16) & 0xff;
			gmin = (rgbMin >> 8) & 0xff;
			bmin = rgbMin & 0xff;

			rmax = (rgbMax >> 16) & 0xff;
			gmax = (rgbMax >> 8) & 0xff;
			bmax = rgbMax & 0xff;

			var tmp:Number

			if(rmin > rmax)
			{
				tmp = rmin;
				rmin = rmax;
				rmax = tmp;
			}

			if(gmin > gmax)
			{
				tmp = gmin;
				gmin = gmax;
				gmax = tmp;
			}

			if(bmin > bmax)
			{
				tmp = bmin;
				bmin = bmax;
				bmax = tmp;
			}

			var mask:BitmapData = new BitmapData(target.width, target.height, true, 0);

			var hideColor:Number = 0xffff00ff;
			var rect:Rectangle = target.rect;

			mask.threshold(target, rect, ZERO, "<", rmin << 16, hideColor, 0x00FF0000, true);
			mask.threshold(mask, rect, ZERO, "<", gmin << 8, hideColor, 0x0000ff00, true);
			mask.threshold(mask, rect, ZERO, "<", bmin, hideColor, 0x000000ff, true);

			mask.threshold(mask, rect, ZERO, ">", rmax << 16, hideColor, 0x00FF0000, true);
			mask.threshold(mask, rect, ZERO, ">", gmax << 8, hideColor, 0x0000ff00, true);
			mask.threshold(mask, rect, ZERO, ">", bmax, hideColor, 0x000000ff, true);

			mask.threshold(mask, rect, ZERO, "!=", hideColor, 0xffffffff, 0xFFFFFF, true);

			mask.floodFill(0, 0, 0);
			mask.threshold(mask, rect, ZERO, "!=", 0x00FFFFFF, hideColor, 0xff000000, true);

			//mask.applyFilter( mask,rect,zero, new BlurFilter(2,2,1));

			var selectedColorBMD:BitmapData = new BitmapData(target.width, target.height, true, 0);
			selectedColorBMD.copyPixels(target, rect, ZERO, mask, ZERO, true);
			mask.dispose();

			return selectedColorBMD;
		}
		public static function takeSnapshotOfContext3D(context3D:Context3D, targetBitmapData:BitmapData):void
		{
			context3D.drawToBitmapData(targetBitmapData);
			context3D.present();
		}
		public static function getBluredBitmapData(target:BitmapData, radius:uint, scale:Number = 1):BitmapData
		{
			const ZERO:Point = new Point();

			var bmd:BitmapData;
			if(scale == 1)
				bmd = target.clone();
			else
			{
				var w:Number = target.width;
				var h:Number = target.height;
				var m:Matrix = new Matrix();
				m.scale(scale, scale);
				bmd = new BitmapData(w * scale, h * scale, target.transparent);
				bmd.draw(target, m);
			}
			bmd.applyFilter(bmd, bmd.rect, ZERO, new BlurFilter(radius, radius, 3));

			return bmd;
		}
		public static function getAlphaBitmapData(source:BitmapData, alphaMap:BitmapData):BitmapData
		{
			const ZERO:Point = new Point();
			const RECT:Rectangle = alphaMap.rect;

			var result:BitmapData = new BitmapData(alphaMap.width, alphaMap.height, true, 0x0);
			result.copyPixels(source, RECT, ZERO);
			result.copyChannel(alphaMap, RECT, ZERO, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);

			/*var x:int = result.width;
			var y:int = result.height;
			for(var j:int = 0; j < x; j++)
			{
				for(var i:int = 0; i<y; i++)
				{
					var c:uint = alphaMap.getPixel( i, j);
					var _a:int = c &0xFF;
					c = _a <<24 | result.getPixel( i,j );
					result.setPixel32( i, j, c );
				}
			}*/

			return result;
		}
		public static function gradientFill(target:BitmapData, color:uint, color2:uint, landscape:Boolean = false):void
		{
			var h1:HSL = new HSL();
			h1.value = color;
			var h2:HSL = new HSL();
			h2.value = color2;
			
			var rect:Rectangle = landscape==true?new Rectangle(0, 0, target.width, 1):new Rectangle(0, 0, 1, target.height);
			var step:int = landscape==true?target.height:target.width;
			
			var i:uint = 0;
			while(i < step)
			{
				var hDist:Number = h2.h-h1.h;
				var sDist:Number = h2.s-h1.s;
				var lDist:Number = h2.l-h1.l;
				var p:Number = i / (step - 1);
				
				var c:HSL = new HSL();
				c.h = h1.h + p * hDist;
				c.s = h1.s + p * sDist;
				c.l = h1.l + p * lDist;
				
				if(landscape == true)
					rect.y = i;
				else
					rect.x = i;
				
				target.fillRect(rect, c.value);
				i++;
			}
		}
		public static function lighter(target:BitmapData, power:int):void
		{	
			for(var x:int = 0; x < target.width; x++) 
			{
				for(var y:int = 0; y < target.height; y++) 
				{
					var c32:uint = target.getPixel32(x, y);
					var rgb32:RGB32 = new RGB32();
					rgb32.value = c32;
					rgb32.r += power;
					rgb32.g += power;
					rgb32.b += power;
					target.setPixel32(x, y, rgb32.value);
				}
			}
		}
		public static function stroke32(target:BitmapData, color32:uint, width:uint = 1):void
		{
			fillRect32(target, new Rectangle(0, 0, target.width - width, width), color32);
			fillRect32(target, new Rectangle(width, target.height - width, target.width - width, width), color32);
			fillRect32(target, new Rectangle(0, width, width, target.height - width), color32);
			fillRect32(target, new Rectangle(target.width - width, 0, width, target.height - width), color32);
		}
		public static function fillRect32(target:BitmapData, rect:Rectangle, color32:uint):void
		{
			target.lock();

			for(var i:uint = 0; i < rect.width; i++)
			{
				for(var j:uint = 0; j < rect.height; j++)
				{
					setPixel32(target, i + rect.x, j + rect.y, color32);
				}
			}

			target.unlock();
		}
		private static function setPixel32(target:BitmapData, x:uint, y:uint, color32:uint):void
		{
			if(x >= target.width || y >= target.height)
				return;

			var a:uint = color32 >>> 24;

			if(a > 0)
			{
				var c1:uint = target.getPixel32(x, y);
				var a1:uint = c1 >>> 24;
				var a0:uint = a ^ 0xff;

				c1 &= 0x00ffffff;
				var _r:uint = (a0 * (c1 >> 16 & 0xff) + a * (color32 >> 16 & 0xff)) >> 8;
				var _g:uint = (a0 * (c1 >> 8 & 0xff) + a * (color32 >> 8 & 0xff)) >> 8;
				var _b:uint = (a0 * (c1 & 0xff) + a * (color32 & 0xff)) >> 8;
				target.setPixel32(x, y, Math.min(a1 + a, 0xff) << 24 | _r << 16 | _g << 8 | _b);
			}
			else
			{
				target.setPixel(x, y, color32 & 0x00ffffff);
			}
		}
	}
}