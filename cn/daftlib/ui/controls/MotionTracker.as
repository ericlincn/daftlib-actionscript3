package cn.daftlib.ui.controls
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import cn.daftlib.color.ColorMatrix;
	import cn.daftlib.core.IDestroyable;

	public final class MotionTracker implements IDestroyable
	{
		private static const DEFAULT_AREA:Number = .1;
		private static const DEFAULT_BLUR:Number = 20;
		private static const DEFAULT_BRIGHTNESS:Number = .2;
		private static const DEFAULT_CONTRAST:Number = 1.5;

		private var __src:DisplayObject;
		private var __now:BitmapData;
		private var __old:BitmapData;

		private var __blr:BlurFilter;
		private var __cmx:ColorMatrix;
		private var __col:ColorMatrixFilter;
		private var __box:Rectangle;
		private var __act:Boolean;
		private var __mtx:Matrix;
		private var __min:Number;

		private var __brightness:Number = 0.0;
		private var __contrast:Number = 0.0;

		private var ZERO:Point = new Point();

		public function MotionTracker($source:DisplayObject)
		{
			__src = $source;
			__now = new BitmapData($source.width, $source.height, false, 0x0);
			__old = __now.clone();

			__cmx = new ColorMatrix();
			__blr = new BlurFilter();

			blur = DEFAULT_BLUR;
			minArea = DEFAULT_AREA;
			contrast = DEFAULT_CONTRAST;
			brightness = DEFAULT_BRIGHTNESS;

			applyColorMatrix();
		}
		public function destroy():void
		{
			__src = null;
			__now = null;
			__old = null;

			__blr = null;
			__cmx = null;
			__col = null;
			__box = null;
			__mtx = null;

			ZERO = null;
		}

		/**
		 * The image the MotionTracker is working from
		 */
		public function get trackingImage():BitmapData
		{
			return __now;
		}
		/**
		 * Whether or not movement is currently being detected
		 */
		public function get hasMovement():Boolean
		{
			return __act;
		}
		/**
		 * The area in which movement is being detected
		 */
		public function get motionArea():Rectangle
		{
			return __box;
		}
		public function get motionX():Number
		{
			if(__box != null)
				return __box.x + (__box.width / 2);

			return NaN;
		}
		public function get motionY():Number
		{
			if(__box != null)
				return __box.y + (__box.height / 2);

			return NaN;
		}
		/**
		 * the blur being applied to the input in order to improve accuracy
		 */
		public function set blur($value:Number):void
		{
			__blr.blurX = __blr.blurY = $value;
		}
		/**
		 * The brightness filter being applied to the input
		 */
		public function set brightness($value:Number):void
		{
			__brightness = $value;
			applyColorMatrix();
		}
		/**
		 * The contrast filter being applied to the input
		 */
		public function set contrast($value:Number):void
		{
			__contrast = $value;
			applyColorMatrix();
		}
		/**
		 * The minimum area (percent of the input dimensions) of movement to be considered movement
		 */
		public function set minArea($value:Number):void
		{
			__min = $value;
		}
		/**
		 * Whether or not to flip the input for mirroring
		 */
		public function set flipInput($b:Boolean):void
		{
			__mtx = new Matrix();
			if($b)
			{
				__mtx.translate(-__src.width, 0);
				__mtx.scale(-1, 1);
			}
		}
		public function track():void
		{
			__now.draw(__src, __mtx);
			__now.draw(__old, null, null, BlendMode.DIFFERENCE);

			__now.applyFilter(__now, __now.rect, ZERO, __col);
			__now.applyFilter(__now, __now.rect, ZERO, __blr);

			__now.threshold(__now, __now.rect, ZERO, '>', 0xFF333333, 0xFFFFFFFF);
			__old.draw(__src, __mtx);

			var area:Rectangle = __now.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF, true);
			__act = (area.width > (__src.width * __min) || area.height > (__src.height * __min));

			if(__act)
			{
				__box = area;
			}
		}
		private function applyColorMatrix():void
		{
			__cmx.reset();
			__cmx.contrast = __contrast;
			__cmx.brightness = __brightness;
			__col = new ColorMatrixFilter(__cmx);
		}
	}
}