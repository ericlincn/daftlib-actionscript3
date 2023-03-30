package cn.daftlib.ui.modify
{
	import cn.daftlib.display.DaftSprite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class LoopScroll extends DaftSprite
	{	
		private var __w:Number;
		
		private var __startSlideX:Number=NaN;
		private var __isSliding:Boolean=false;
		
		private static var SPEED_SPRINGNESS:Number = 0.4;
		private var __velocity:Number=0;
		
		public function LoopScroll()
		{
			super();
		}
		public function start():void
		{
			if(this.numChildren<1)
				return;
			
			var w:Number=this.width;
			var h:Number=this.height;
			__w=w;
			
			var bmd:BitmapData=new BitmapData(w, h, true, 0x0);
			bmd.draw(this);
			var left:Bitmap=new Bitmap(bmd);
			var right:Bitmap=new Bitmap(bmd);
			
			left.x=-w;
			right.x=w;
			this.addChild(left);
			this.addChild(right);
			
			this.addEventListener(Event.ENTER_FRAME, checkPosition);
		}
		public function slideHandler($offset:Number):void
		{
			if(!isNaN(__startSlideX))
			{
				var targetX:Number=__startSlideX+$offset;
				var offsetX:Number=targetX-this.x;
				//this.x+=offsetX*.8;
				
				trace(this.x, offsetX+this.x, __w);
				
				if( (offsetX+this.x)>__w )
				{
					offsetX=offsetX-__w;
					this.x+=offsetX;
				}
				else
					this.x+=offsetX;
				
				__velocity += (offsetX * SPEED_SPRINGNESS);
				//this.x+=__velocity;
			}
		}
		public function downHandler():void
		{
			__startSlideX=this.x;
			__isSliding=true;
		}
		public function upHandler():void
		{
			__isSliding=false;
		}
		private function checkPosition(e:Event):void
		{	
			if(__isSliding)
			{
				__velocity *= .5;
			}
			else
			{
				__velocity *= .93;
				this.x += __velocity;
				
				if(this.x<-__w)
					this.x=0;
				else if(this.x>__w)
					this.x=this.x-__w;
			}
		}
	}
}