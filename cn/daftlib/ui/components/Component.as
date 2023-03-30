package cn.daftlib.ui.components
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import cn.daftlib.display.DaftSprite;
	import cn.daftlib.utils.BitmapDataUtil;
	import cn.daftlib.utils.ColorUtil;
	
	public class Component extends DaftSprite
	{
		private static var __cache:Dictionary=new Dictionary();
		
		protected var __width:int = 0;
		protected var __height:int = 0;
		
		public function Component()
		{
			super();
			
			this.mouseEnabled = true;
			
			addChildren();
			invalidate();
		}
		override public function set width(value:Number):void
		{
			value = Math.round(value);
			
			if(__width == value) return;
			
			__width = value;
			
			invalidate();
		}
		override public function set height(value:Number):void
		{
			value = Math.round(value);
			
			if(__height == value) return;
			
			__height = value;
			
			invalidate();
		}
		override public function get width():Number
		{
			return __width;
		}
		override public function get height():Number
		{
			return __height;
		}
		/**
		 * Overriden in subclasses to create child display objects.
		 */	
		protected function addChildren():void
		{
			throw new Error('This function should be overrided by subclass.');
		}
		/**
		 * Do not call render() directly, call invalidate() instead
		 */		
		protected function render():void
		{
			throw new Error('This function should be overrided by subclass.');
		}
		/**
		 * Marks the component to be redrawn on the next frame.
		 */	
		protected function invalidate():void
		{
			this.addEventListener(Event.ENTER_FRAME, invalidateHandler);
		}
		/**
		 * Called one frame after invalidate is called.
		 */
		private function invalidateHandler(e:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME, invalidateHandler);
			render();
		}

		protected function getButtonUpTexture(width:int, height:int):BitmapData
		{
			var id:String="getButtonUpTexture:"+width+":"+height;
			if(__cache[id])
				return __cache[id];
			
			var bmd:BitmapData=new BitmapData(width, height, true, 0x0);
			bmd.lock();
			
			gradientLine(bmd, 0x696969, 0, int(height*.6));
			gradientLine(bmd, 0x696969, width-1, int(height*.6));
			bmd.fillRect(new Rectangle(0, height-1, width, 1), ColorUtil.toARGB(0x696969, 1));
			
			var outline:BitmapData=new BitmapData(width-2, height-2, false, 0x0);
			BitmapDataUtil.gradientFill(outline, 0x303030, 0x272727, true);
			bmd.copyPixels(outline, outline.rect, new Point(1, 1));
			
			var inner:BitmapData=new BitmapData(width-4, height-4-1, false, 0x0);
			BitmapDataUtil.gradientFill(inner, 0x757575, 0x636363, true);
			bmd.copyPixels(inner, inner.rect, new Point(2, 2+1));
			
			bmd.fillRect(new Rectangle(2, 2, width-4, 1), ColorUtil.toARGB(0x919191, 1));
			
			bmd.unlock();
			__cache[id]=bmd;
			return bmd;
		}
		protected function getButtonDownTexture(width:int, height:int):BitmapData
		{
			var id:String="getButtonDownTexture:"+width+":"+height;
			if(__cache[id])
				return __cache[id];
			
			var bmd:BitmapData=new BitmapData(width, height, true, 0x0);
			bmd.lock();
			
			gradientLine(bmd, 0x696969, 0, int(height*.6));
			gradientLine(bmd, 0x696969, width-1, int(height*.6));
			bmd.fillRect(new Rectangle(0, height-1, width, 1), ColorUtil.toARGB(0x696969, 1));
			
			var outline:BitmapData=new BitmapData(width-2, height-2, false, 0x0);
			BitmapDataUtil.gradientFill(outline, 0x303030, 0x272727, true);
			bmd.copyPixels(outline, outline.rect, new Point(1, 1));
			
			var inner:BitmapData=new BitmapData(width-4, height-4, false, 0x3a3a3a);
			inner.fillRect(new Rectangle(0, 0, inner.width, 1), 0x373737);
			inner.fillRect(new Rectangle(0, 1, inner.width, 1), 0x383838);
			inner.fillRect(new Rectangle(0, 0, 1, inner.height), 0x383838);
			inner.fillRect(new Rectangle(inner.width-1, 0, 1, inner.height), 0x383838);
			bmd.copyPixels(inner, inner.rect, new Point(2, 2));
			
			bmd.unlock();
			__cache[id]=bmd;
			return bmd;
		}
		private function gradientLine(target:BitmapData, color:uint, x:int, y:int):void
		{
			var i:uint=0;
			while(i<(target.height-y))
			{
				var p:Number=i/(target.height-y-1);
				target.setPixel32(x, i+y, ColorUtil.toARGB(color, p));
				i++;
			}
		}
	}
}