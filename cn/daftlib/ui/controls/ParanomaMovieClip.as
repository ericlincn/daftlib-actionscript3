package cn.daftlib.ui.controls
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;

	import cn.daftlib.display.DaftSprite;

	public final class ParanomaMovieClip extends DaftSprite
	{
		private const SEGMENTS:uint = 360;

		private var __mc:MovieClip;
		private var __angleMap:Dictionary;
		private var __currentAngle:Number = 0;

		public function ParanomaMovieClip($mc:MovieClip)
		{
			super();

			if($mc.totalFrames <= 1)
				throw new Error('The totalframes of MovieClip should more than 1.');

			__mc = $mc;
			__mc.gotoAndStop(1);
			this.addChild(__mc);

			__angleMap = new Dictionary();
			var step:Number = __mc.totalFrames / SEGMENTS;
			var targetFrame:Number = 0;
			var i:uint = 0;
			while(i < SEGMENTS)
			{
				__angleMap[i] = Math.ceil(targetFrame);
				targetFrame += step;
				i++;
			}
		}
		override public function destroy():void
		{
			__mc = null;
			__angleMap = null;

			super.destroy();
		}
		/**
		 * Set angle between -360 ~ 360
		 * @param $value
		 */
		public function set angle($value:Number):void
		{
			__currentAngle = int($value % SEGMENTS);
			if(__currentAngle < 0)
				__currentAngle += SEGMENTS;
			__mc.gotoAndStop(__angleMap[__currentAngle]);
		}
		public function get angle():Number
		{
			return __currentAngle;
		}
	}
}