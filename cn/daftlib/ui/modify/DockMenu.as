package cn.daftlib.ui.modify
{
	import cn.daftlib.display.DaftSprite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	public class DockMenu extends DaftSprite
	{
		private const SCALE_LEVEL:Number=1.5;
		
		private var __itemArr:Array=[];
		private var __itemWidth:Number=NaN;
		private var __itemHeight:Number=NaN;
		
		private var __dockTopEdge:Number;
		private var __totalWidth:Number=0;
		
		public function DockMenu()
		{
			super();
		}
		override public function destroy():void
		{
			this.removeEventListener(Event.ENTER_FRAME, update);
			__itemArr=null;
			
			super.destroy();
		}
		public function set itemWidth($v:Number):void
		{
			__itemWidth=$v;
		}
		public function addItem($do:DisplayObject):void
		{
			if(isNaN(__itemWidth))
				__itemWidth=$do.width;
			
			if(isNaN(__itemHeight))
				__itemHeight=$do.height;
			
			$do.x=0;
			$do.y=0;
			__itemArr.push($do);
			this.addChild($do);
			
			__totalWidth=__itemArr.length*__itemWidth;
			__dockTopEdge=-__itemHeight;
			
			if(__itemArr.length==1) start();
		}
		private function start():void
		{
			this.addEventListener(Event.ENTER_FRAME, update);
		}
		private function update(e:Event):void
		{
			var max:int=__itemArr.length;
			var dockTarget:int=__itemWidth*SCALE_LEVEL;
			var limitTarget:Number = dockTarget/(SCALE_LEVEL - 1)*Math.PI/2;
			var deceleration:Number = 0.5;
			
			var i:uint;
			var item:DisplayObject;
			var basePos:int;
			
			if(Math.abs(mouseX) <= __totalWidth*.5 && mouseY <= 0 && mouseY >= __dockTopEdge)
			{
				__dockTopEdge=-__itemHeight*SCALE_LEVEL;
				
				i=0;
				while(i<max)
				{
					item = __itemArr[i];
					basePos = __itemWidth*(i - (max - 1)*0.5);
					var distance:int = mouseX - basePos;
					var radian:Number = distance*(SCALE_LEVEL - 1)/dockTarget;
					if (Math.abs(distance) < limitTarget) 
					{
						var targetScale:Number = 1 + (SCALE_LEVEL - 1)*Math.cos(radian);
						var targetPos:Number = basePos - dockTarget*Math.sin(radian);
						item.scaleX += (targetScale - item.scaleX)*deceleration;
						item.scaleY += (targetScale - item.scaleY)*deceleration;
						item.x += (targetPos - item.x)*deceleration;
					} 
					else 
					{
						item.scaleX += (1 - item.scaleX)*deceleration;
						item.scaleY += (1 - item.scaleY)*deceleration;
						if (distance < -limitTarget) 
						{
							item.x += (basePos + dockTarget + 10 - item.x)*deceleration;
						} 
						else 
						{
							item.x += (basePos - dockTarget - 10 - item.x)*deceleration;
						}
					}
					
					i++;
				}
			}
			else
			{
				__dockTopEdge=-__itemHeight;
				
				i=0;
				while(i<max)
				{
					item = __itemArr[i];
					basePos = __itemWidth*(i - (max - 1)*0.5);
					item.scaleX += (1 - item.scaleX)*deceleration;
					item.scaleY += (1 - item.scaleY)*deceleration;
					item.x += (basePos - item.x)*deceleration;
					
					i++;
				}
			}
			
			/*if(0 < this.mouseX && this.mouseX < __totalWidth && __dockTopEdge < this.mouseY && this.mouseY < 0)
			{
				__dockTopEdge=-120;
				
				i=0;
				while(i<__itemArr.length)
				{
					var distance:int = this.mouseX - i*__itemWidth - __itemWidth/2;
					
					if(-20 * Math.PI < distance && distance < 20 * Math.PI)
					{
						__itemArr[i].scaleY = 2.5+1.5*Math.cos(distance/20);
						__itemArr[i].scaleX = 2.5+1.5*Math.cos(distance/20);
						__itemArr[i].x = i*__itemWidth + __itemWidth/2 - 120*Math.sin(distance/40);
					} 
					else 
					{
						__itemArr[i].scaleY = 1;
						__itemArr[i].scaleX = 1;
						if(-20 * Math.PI > distance) 
						{
							__itemArr[i].x = i*__itemWidth + 120 + 25;
						} 
						else 
						{
							__itemArr[i].x = i*__itemWidth - 120 + 5;
						}
					}
					
					i++;
				}
			}
			else
			{
				__dockTopEdge=-__itemHeight;
				
				i=0;
				while(i<__itemArr.length)
				{
					__itemArr[i].scaleY = 1;
					__itemArr[i].scaleX = 1;
					__itemArr[i].x = i*__itemWidth+__itemWidth/2;
					i++;
				}
			}*/
		}
	}
}