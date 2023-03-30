package cn.daftlib.ui.effects
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	import cn.daftlib.display.DaftBitmap;

	public final class SpotsMask extends DaftBitmap
	{
		/**
		 * Get a video mask with pellets
		 *
		 * <listing version="3.0">
		 * new VideoMask(500, 300, 4, 12, 0, true);
		 * new VideoMask(500, 300, 4, 5, 5);
		 * </listing>
		 *
		 * @param $width
		 * @param $height
		 * @param $pelletSize
		 * @param $gapX
		 * @param $gapY
		 * @param $interlace
		 */
		public function SpotsMask($width:Number, $height:Number, $pelletSize:uint = 1, $gapX:uint = 1, $gapY:uint = 1, $interlace:Boolean = false)
		{
			super(null, "auto", false);

			var maskBMD:BitmapData = new BitmapData($width, $height, true, 0x0);
			maskBMD.lock();

			var stepX:uint = $gapX + $pelletSize;
			var stepY:uint = $gapY + $pelletSize;
			var rect:Rectangle = new Rectangle();

			var i:uint = 0;
			while(i < $width)
			{
				var j:uint = 0;
				while(j < $height)
				{
					var pixelX:uint = i;
					var pixelY:uint = j;

					//if($interlace == true) pixelX+=(j/stepY%2)*$pelletSize;
					if($interlace == true)
						pixelX += j % stepX;

					if($pelletSize <= 1)
						maskBMD.setPixel32(pixelX, pixelY, 0xff000000);
					else
					{
						rect.x = pixelX;
						rect.y = pixelY;
						rect.width = $pelletSize;
						rect.height = $pelletSize;
						maskBMD.fillRect(rect, 0xff000000);
					}

					j += stepY;
				}
				i += stepX;
			}

			maskBMD.unlock();
			this.bitmapData = maskBMD;
		}
	}
}