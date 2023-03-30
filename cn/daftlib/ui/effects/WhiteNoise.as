package cn.daftlib.ui.effects
{
	import flash.display.BitmapData;

	import cn.daftlib.display.DaftBitmap;

	public final class WhiteNoise extends DaftBitmap implements IRenderable
	{
		private var __buff:Vector.<uint>;
		private var __seed:uint = 2222;
		private var __fcnt:uint = 11;

		public function WhiteNoise($width:Number, $height:Number)
		{
			super(null, "auto", false);

			this.bitmapData = new BitmapData($width, $height, false, 0x0);
			__buff = new Vector.<uint>($width * $height, true);

			// Its faster than IntervalFrame.addEventListener(updateNoise, 5);
			//IntervalFrame.addEventListener(updateNoise, 4);
		}
		public function onRenderTick():void
		{
			__fcnt++;

			var s:uint = __seed;
			var n:int = (__buff.length >> 1) - (__fcnt & 1);

			while(n > 2)
			{
				n--;
				n--;

				// custom PRNG
				s = (((s & 1) - 1) & 0xF00FC7C8) ^ (s >> 1);

				var c:uint = s & 0xFE;

				// grayscale noise
				__buff[n << 1] = (c << 16) | (c << 8) | (c << 0);
			}

			__seed = s;

			this.bitmapData.setVector(this.bitmapData.rect, __buff);
		}
	}
}