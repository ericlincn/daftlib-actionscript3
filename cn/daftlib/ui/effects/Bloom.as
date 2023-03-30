package cn.daftlib.ui.effects
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Bloom
	{
		private static const BLUR_RADIUS:Number = 8;
		private static const BLUR_FILTER:BlurFilter = new BlurFilter(BLUR_RADIUS, BLUR_RADIUS, BitmapFilterQuality.HIGH);
		private static const ZERO:Point = new Point();

		public static function getBitmapData($source:DisplayObject):BitmapData
		{
			var width:int = int($source.width);
			var height:int = int($source.height);
			var sourceImage:BitmapData = new BitmapData(width, height, false, 0x0);
			sourceImage.draw($source);

			var numPasses:int = 2;

			var result:BitmapData = new BitmapData(width, height, false, 0x000000);
			// create a grayscale version of the source image:
			var grayScale:BitmapData = new BitmapData(width, height, false, 0x000000);
			var rect:Rectangle = new Rectangle(0, 0, width, height);

			var matrix:Array = [
				0.3, 0.59, 0.11, 0, 0,
				0.3, 0.59, 0.11, 0, 0,
				0.3, 0.59, 0.11, 0, 0,
				0,   0,    0,    1, 0];
			grayScale.applyFilter(sourceImage, rect, ZERO, new ColorMatrixFilter(matrix));

			// multiply the grayscale image with itself:
			result.draw(grayScale);
			for(var i:int = 0; i < numPasses; i++)
			{
				// note: for larger numbers of passes (but less fine-grained control), you can 
				// optimize this by multiplying result with itself instead of the original grayScale.
				// if you need more fine-tuned control, try changing the brightness/contrast after each step.
				result.draw(grayScale, null, null, BlendMode.MULTIPLY);
			}
			// multiply with the source image to add color back in:
			result.draw(sourceImage, null, null, BlendMode.MULTIPLY);

			// blur the multiplied image
			result.applyFilter(result, rect, ZERO, BLUR_FILTER);
			// add the source back in
			result.draw(sourceImage, null, null, BlendMode.ADD);

			return result;
		}
	}
}