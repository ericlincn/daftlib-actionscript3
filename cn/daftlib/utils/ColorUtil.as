package cn.daftlib.utils
{
	public final class ColorUtil
	{
		public static function toRGB(argb:uint):uint
		{
			var rgb:uint = 0;
			rgb = (argb & 0xFFFFFF);
			return rgb;
		}
		public static function toARGB(rgb:uint, alpha:Number = 1):uint
		{
			var argb:uint = rgb;
			argb += (alpha * 255 << 24);
			return argb;
		}
		public static function getRandomColor():uint
		{
			return uint("0x" + (Math.random() * 0xFFFFFF).toString(16));
		}
		public static function getGray(gray:uint):uint
		{
			gray = Math.max(0, Math.min(255, gray));
			
			var r:uint;
			var g:uint;
			var b:uint;
			r = g = b = gray & 0xFF;
			return r << 16 | g << 8 | b;
		}
		public static function isDarkColor(rgb:uint):Boolean
		{
			var r:uint = rgb >> 16 & 0xFF;
			var g:uint = rgb >> 8  & 0xFF;
			var b:uint = rgb & 0xFF;
			var perceivedLuminosity:Number = (0.299 * r + 0.587 * g + 0.114 * b);
			return perceivedLuminosity < 70;
		}
		public static function getAverageColor(colors:Array):uint
		{
			var r:Number = 0;
			var g:Number = 0;
			var b:Number = 0;
			var l:int = colors.length;
			var i:int = 0;
			while (i < l)
			{
				r += colors[i] >> 16;
				g += (colors[i] & 0x00ff00) >> 8;
				b += colors[i] & 0x0000ff;
				
				i++;
			}
			r /= l;
			g /= l;
			b /= l;
			
			return int(r) << 16 | int(g) << 8 | int(b);
		}
	}
}