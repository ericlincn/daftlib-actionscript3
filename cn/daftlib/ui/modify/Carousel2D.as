package cn.daftlib.ui.modify
{
	import cn.daftlib.display.DaftSprite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	public class Carousel2D extends DaftSprite
	{
		private var __fl:Number;
		private var __radius:Number;
		private var __zpos:Number;
		private var __ypos:Number;
		
		private var __yRotation:Number;
		
		private var __items:Array = [];
		private var __blur:BlurFilter = new BlurFilter(0, 0, 2);
		private var __depthBlur:Boolean = false;
		private var __depthAlpha:Boolean = false;
		
		public function Carousel2D($focalLength:int = 800, $radius:int = 300, $zpos:Number = 0, $ypos:Number=0)
		{
			super();
			
			__fl = $focalLength;
			__radius = $radius;
			__zpos = $zpos;
			__ypos = $ypos;
		}
		override public function destroy():void
		{
			this.removeEventListener(Event.ENTER_FRAME, update);
			
			var i:int = __items.length;
			while (i--) 
			{
				var ci:CarouselItem = __items[i];
				removeChild(ci);
				ci = null;
			}
			__items=null;
			__blur=null;
			
			super.destroy();
		}
		public function get yRotation():Number { return __yRotation; }
		public function set yRotation($value:Number):void { __yRotation = $value; }
		
		public function set depthBlur($value:Boolean):void
		{
			__depthBlur = $value;
		}
		public function set depthAlpha($value:Boolean):void
		{
			__depthAlpha = $value;
		}
		
		public function addItem($do:DisplayObject):void
		{
			var item:CarouselItem = new CarouselItem($do);
			__items.push(item);
			
			var numItems:uint = __items.length;
			var angleStep:Number = (2 * Math.PI) / numItems;
			
			__yRotation = -(90 - (360 / numItems));
			
			var i:int = __items.length;
			while (i--) 
			{
				var ci:CarouselItem = __items[i];
				ci.radius = __radius;
				ci.radians = __yRotation * Math.PI / 180;
				ci.angle = angleStep * i;
				ci.focalLength = __fl;
				ci.zpos = __zpos;
				ci.ypos = __ypos;
				ci.updateDisplay();
			}
			addChild(item);
			
			// if at least one item, go ahead and init the sucker
			if (numItems == 1) startCarousel();
		}
		
		private function startCarousel():void 
		{
			this.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(event:Event):void
		{
			var rads:Number = __yRotation * Math.PI / 180;
			__items.sortOn("zpos", Array.NUMERIC);
			__items.reverse();
			
			var i:int = __items.length;
			while (i--) 
			{
				var item:CarouselItem = __items[i];
				item.radians = rads;
				if (__depthBlur) 
				{
					if (!isNaN(item.zpos))
					{
						// play with this blur amount - to taste
						__blur.blurX = __blur.blurY = int(((item.zpos - __zpos) + 200) / 40);
						item.filters = [__blur];
					}
				}
				
				if(__depthAlpha)
				{
					if (!isNaN(item.zpos))
					{
						var alpha:Number=(item.zpos - __zpos + 200)/1000;
						// when item on backside, completely fadeout
						alpha=alpha<0?1:0;
						item.alpha=alpha;
					}
				}
				
				item.updateDisplay();
				//need better z sorting
				this.setChildIndex(item, i);
			}
		}
	}
}
import flash.display.DisplayObject;
import flash.display.Sprite;

class CarouselItem extends Sprite
{
	public var angle:Number;
	public var radius:Number;
	public var focalLength:int;
	public var radians:Number;
	
	private var __orgZPos:Number;
	private var __orgYPos:Number;
	private var __zpos:Number;
	
	public function CarouselItem(image:DisplayObject):void 
	{
		updateDisplay();
		addChild(image);
	}
	
	internal function updateDisplay():void
	{
		var targetAngle:Number = angle + radians;
		var xpos:Number = Math.cos(targetAngle) * radius;
		__zpos = __orgZPos + Math.sin(targetAngle) * radius;
		var scaleRatio:Number = focalLength / (focalLength + __zpos);
		x = xpos * scaleRatio;
		y = __orgYPos * scaleRatio;
		scaleX = scaleY = scaleRatio;
	}
	
	// must remain public for Array.sortOn() method in OBO_3DCarousel instance.
	public function get zpos():Number { return __zpos; }
	public function set zpos(value:Number):void { __orgZPos = value; }
	internal function set ypos(value:Number):void { __orgYPos = value; }
}