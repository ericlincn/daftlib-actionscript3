package cn.daftlib.ui.effects
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import cn.daftlib.core.IDestroyable;

	public class DisplacementGenerator implements IDestroyable
	{
		private static const ZERO:Point = new Point();

		private var __filter:DisplacementMapFilter;
		private var __channleMap:BitmapData;
		private var __outputChannleMap:BitmapData;
		private var __drawMatrix:Matrix;

		public function DisplacementGenerator($channleMap:BitmapData, $channleMapPrecision:Number = 1, $strength:Number = 64, $colorChannle:uint = BitmapDataChannel.BLUE, $mode:String = DisplacementMapFilterMode.CLAMP)
		{
			__channleMap = $channleMap;

			if($channleMapPrecision == 1)
			{
				__outputChannleMap = __channleMap;
			}
			else
			{
				__outputChannleMap = new BitmapData(__channleMap.width / $channleMapPrecision, __channleMap.height / $channleMapPrecision, false, 0x0);

				__drawMatrix = new Matrix();
				__drawMatrix.scale(__outputChannleMap.width / __channleMap.width, __outputChannleMap.height / __channleMap.height);
			}

			__filter = new DisplacementMapFilter(null, ZERO, $colorChannle, $colorChannle, $strength, $strength, $mode);
		}
		public function get filter():DisplacementMapFilter
		{
			if(__drawMatrix != null)
				__outputChannleMap.draw(__channleMap, __drawMatrix);

			__filter.mapBitmap = __outputChannleMap;
			return __filter;
		}
		public function destroy():void
		{
			__filter = null;
			__channleMap = null;

			if(__drawMatrix != null)
				__outputChannleMap.dispose();

			__outputChannleMap = null;
		}
	}
}