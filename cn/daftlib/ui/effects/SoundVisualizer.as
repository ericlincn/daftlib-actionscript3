package cn.daftlib.ui.effects
{
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	
	import cn.daftlib.display.DaftSprite;

	public final class SoundVisualizer extends DaftSprite implements IRenderable
	{
		private static const CHANNELS:uint = 512;

		private var __maxChannel:uint;
		private var __color:uint;
		private var __factors:uint;
		private var __indicators:Array;
		private var __byteArray:ByteArray;

		public function SoundVisualizer($maxChannel:uint, $channelWidth:Number, $channelHeight:Number, $channelGap:uint, $color:uint = 0x0)
		{
			super();

			__maxChannel = $maxChannel > 256 ? 256 : $maxChannel;
			__color = $color;
			__factors = uint(CHANNELS / __maxChannel);

			initVisual($channelWidth, $channelHeight, $channelGap);
			
			//IntervalFrame.addEventListener(updateVisual, 2);
		}
		override public function destroy():void
		{
			__indicators = null;
			__byteArray = null;

			super.destroy();
		}
		public function onRenderTick():void
		{
			try
			{
				//SoundMixer.computeSpectrum(__byteArray, true, __factors);
				SoundMixer.computeSpectrum(__byteArray);
			}
			catch(err:Error)
			{
				trace(this, err.message);
			}
			
			for(var n:uint = 0; n < __maxChannel; n++)
			{
				var indicator:MiniIndicator = __indicators[n];
				__byteArray.position = __factors * 4 * n;
				var percent:Number = __byteArray.readFloat();
				indicator.update(percent);
			}
		}
		private function initVisual($channelWidth:Number, $channelHeight:Number, $channelGap:uint):void
		{
			__indicators = [];
			var i:uint = 0;
			while(i < __maxChannel)
			{
				var indicator:MiniIndicator = new MiniIndicator($channelWidth, $channelHeight, __color);
				this.addChild(indicator);
				indicator.x = ($channelWidth + $channelGap) * i;
				__indicators.push(indicator);

				i++;
			}

			__byteArray = new ByteArray();
		}
	}
}
import flash.display.Bitmap;
import flash.display.BitmapData;

class MiniIndicator extends Bitmap
{
	private static var __black:BitmapData;

	public function MiniIndicator(w:Number, h:Number, c:uint = 0x000000)
	{
		if(!__black)
			__black = new BitmapData(w, h, false, c);

		this.bitmapData = __black;
		update(0);
	}
	public function update($percent:Number):void
	{
		this.scaleY = $percent;
		this.alpha = $percent < .2 ? .2 : $percent;
		this.height = uint(this.height) < 1 ? 1 : uint(this.height);
		this.y = -this.height;
	}
}