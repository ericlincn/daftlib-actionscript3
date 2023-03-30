package cn.daftlib.ui.effects
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public final class Reflection
	{
		private static const HALF_PI:Number = 0.5 * Math.PI;
		private static const ZERO:Point = new Point();

		public static function getBitmapData($source:DisplayObject):BitmapData
		{
			var width:int = int($source.width);
			var height:int = int($source.height);

			var result:BitmapData = new BitmapData(width, height, true, 0x0);
			var mtx:Matrix = new Matrix();
			mtx.d = -1;
			mtx.ty = result.height;
			result.draw($source, mtx);

			// Fast
			mtx = new Matrix();
			mtx.createGradientBox(width, height, HALF_PI);
			var shape:Shape = new Shape();
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0,0], [0.9,0.2], [0,0xFF], mtx);
			shape.graphics.drawRect(0, 0, width, height);
			shape.graphics.endFill();
			var maskBMD:BitmapData = new BitmapData(width, height, true, 0x0);
			maskBMD.draw(shape);

			result.copyPixels(result, result.rect, ZERO, maskBMD, ZERO, false);

			// Slow
			/*bd.lock();
			for (var i:int = 0; i <$target.height; i++)
			{
				var rowFactor:Number = 1 - (i / $target.height);
				for (var j:int = 0; j <$target.width; j++)
				{
					var pixelColor:uint = bd.getPixel32(j, i);
					var pixelAlpha:uint = pixelColor >>> 24;
					var pixelRGB:uint = pixelColor & 0xffffff;
					var resultAlpha:uint = pixelAlpha * rowFactor;
					bd.setPixel32(j, i, resultAlpha << 24 | pixelRGB);
				}
			}
			bd.unlock(); */

			return result;
		}
	}
}