package cn.daftlib.ui.modify
{
	import cn.daftlib.display.DaftSprite;
	import cn.daftlib.utils.DisplayObjectUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Vector3D;
	
	public class Carousel3D extends DaftSprite
	{
		private var __radius:Number;
		
		private var __items:Array = [];
		private var __blur:BlurFilter = new BlurFilter(0, 0, 1);
		private var __useBlur:Boolean = false;
		
		public function Carousel3D($radius:int=300)
		{
			super();
			
			__radius = $radius;
		}
		override public function destroy():void
		{
			this.removeEventListener(Event.ENTER_FRAME, update);
			
			DisplayObjectUtil.destroyAllChildrenIn(this);
			
			__items=null;
			__blur=null;
			
			super.destroy();
		}
		public function set blur(value:Boolean):void
		{
			__useBlur = value;
		}
		public function addItem($do:DisplayObject):void
		{
			__items.push($do);
			this.addChild($do);
			
			var numItems:uint = __items.length;
			var angleStep:Number = Math.PI * 2 / numItems;
			
			var i:int = __items.length;
			while (i--) 
			{
				var angle:Number=angleStep*i;
				var d:DisplayObject = __items[i];
				d.x = Math.cos(angle) * __radius;
				d.z = Math.sin(angle) * __radius;
				d.rotationY = -360 / numItems * i - 90;
			}
			
			if (numItems == 1) startCarousel();
		}
		public function getItemIndex($do:DisplayObject):int
		{
			return __items.indexOf($do);
		}
		private function startCarousel():void 
		{
			this.addEventListener(Event.ENTER_FRAME, update);
		}
		public function resumeCarousel():void 
		{
			startCarousel();
		}
		public function pauseCarousel():void 
		{
			this.removeEventListener(Event.ENTER_FRAME, update);
		}
		private function update(event:Event):void
		{
			var i:int;
			var distArray:Array=[];
			var curMid:Vector3D;
			var curDist:Number;
			var observerPos:Vector3D=new Vector3D();
			
			observerPos.x=root.transform.perspectiveProjection.projectionCenter.x;
			observerPos.y=root.transform.perspectiveProjection.projectionCenter.y;
			observerPos.z=-root.transform.perspectiveProjection.focalLength;
			
			i=0
			while(i<__items.length)
			{
				var d:DisplayObject = __items[i];
				curMid=d.transform.getRelativeMatrix3D(root).position.clone();
				curDist=Math.sqrt(Math.pow(curMid.x-observerPos.x,2)+Math.pow(curMid.y-observerPos.y,2)+Math.pow(curMid.z-observerPos.z,2));
				
				distArray.push({distance:curDist,which:i});
				
				if (__useBlur) 
				{
					if((curDist-z)>0)
					{
						__blur.blurX = __blur.blurY = int(((curDist-z) ) / 30);
						d.filters = [__blur];
					}
					else
						d.filters = [];
				}
				
				i++;
			}
			
			distArray.sortOn("distance", Array.NUMERIC | Array.DESCENDING);
			
			i=0
			while(i<distArray.length)
			{
				this.setChildIndex(__items[distArray[i].which], i);
				//this.addChild(__items[distArray[i].which]);
				
				i++;
			}
		}
	}
}