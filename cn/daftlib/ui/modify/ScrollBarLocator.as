package cn.daftlib.ui.modify
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.IEventDispatcher;

	import cn.daftlib.display.DaftSprite;
	import cn.daftlib.events.ScrollEvent;
	import cn.daftlib.utils.DisplayObjectUtil;
	import cn.daftlib.utils.NumberUtil;

	public class ScrollBarLocator extends DaftSprite
	{
		private static const SCROLLBAR_MIN_HEIGHT:Number = 20;

		private var __size:Number;
		private var __color:uint;
		private var __is:IEventDispatcher;
		private var __scrollBar:Bitmap;

		public function ScrollBarLocator($is:IEventDispatcher, $color:uint = 0xffffff, $size:Number = 6)
		{
			super();

			__size = $size;
			__color = $color;

			__is = $is;
			__is.addEventListener(ScrollEvent.UPDATE_LIST_SIZE, createScrollBar);
			__is.addEventListener(ScrollEvent.UPDATE_LIST_POSITION, updateScrollPostion);
			__is.addEventListener(ScrollEvent.SCROLL_STOP, hideScrollBar);
		}
		override public function destroy():void
		{
			super.destroy();

			__is.removeEventListener(ScrollEvent.UPDATE_LIST_SIZE, createScrollBar);
			__is.removeEventListener(ScrollEvent.UPDATE_LIST_POSITION, updateScrollPostion);
			__is.removeEventListener(ScrollEvent.SCROLL_STOP, hideScrollBar);
			__is = null;
		}
		private function hideScrollBar(e:ScrollEvent):void
		{
			if(__scrollBar == null)
				return;

			DisplayObjectUtil.fadeout(__scrollBar);
		}
		private function createScrollBar(e:ScrollEvent):void
		{
			if(e.viewportSize < e.listSize)
			{
				if(__scrollBar == null)
				{
					__scrollBar = new Bitmap();
					this.addChild(__scrollBar);
				}

				var h:Number = e.viewportSize / e.listSize * e.viewportSize;
				__scrollBar.bitmapData = getScrollBarBMD(h < SCROLLBAR_MIN_HEIGHT ? SCROLLBAR_MIN_HEIGHT : h);
				__scrollBar.alpha = 0;
			}
			else if(__scrollBar != null)
			{
				if(this.contains(__scrollBar))
					this.removeChild(__scrollBar);

				__scrollBar = null;
			}
		}
		private function updateScrollPostion(e:ScrollEvent):void
		{
			if(__scrollBar == null)
				return;

			var scollPercent:Number = e.scrollPosition / (-e.listSize + e.viewportSize);

			DisplayObjectUtil.fadein(__scrollBar);

			var h:Number = 0;

			if(scollPercent < 0)
			{
				h = __scrollBar.bitmapData.height - e.scrollPosition;
				h = h < SCROLLBAR_MIN_HEIGHT ? SCROLLBAR_MIN_HEIGHT : h;
				__scrollBar.height = h;
			}
			else if(scollPercent > 1)
			{
				h = __scrollBar.bitmapData.height - (e.viewportSize - e.listSize - e.scrollPosition);
				h = h < SCROLLBAR_MIN_HEIGHT ? SCROLLBAR_MIN_HEIGHT : h;
				__scrollBar.height = h;
			}
			else
			{
				__scrollBar.scaleY = 1;
			}

			__scrollBar.y = (e.viewportSize - __scrollBar.height) * NumberUtil.clamp(scollPercent, 0, 1);
		}
		private function getScrollBarBMD($height:Number):BitmapData
		{
			/*var bmd:BitmapData = new BitmapData(__size, $height, true, 0x0);

			var scrollBar:Shape = new Shape();
			scrollBar.graphics.beginFill(__color, .8);
			//scrollBar.graphics.drawRoundRect(0, 0, __size, $height, __size, __size);
			scrollBar.graphics.drawRect(0, 0, __size, $height);
			scrollBar.graphics.endFill();

			bmd.draw(scrollBar);*/
			
			var bmd:BitmapData = new BitmapData(__size, $height, false, __color);

			return bmd;
		}
	}
}