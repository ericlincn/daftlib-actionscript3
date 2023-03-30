package cn.daftlib.ui.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import cn.daftlib.utils.BitmapDataUtil;

	public class PushButton extends Component
	{
		private static const DOWN:String="down";
		private static const UP:String="up";
		
		private var __label:Lable;
		private var __labelShadow:Bitmap;
		private var __skin:Bitmap;
		private var __state:String = UP;
		
		public function PushButton()
		{
			super();
		}
		public function get lable():Lable
		{
			return __label;
		}
		override protected function addChildren():void
		{
			__skin=new Bitmap();
			this.addChild(__skin);
			
			__labelShadow=new Bitmap();
			this.addChild(__labelShadow);
			
			__label=new Lable();
			__label.addEventListener(Event.RESIZE, childResizeHandler);
			__label.color=0xffffff;
			this.addChild(__label);
			
			__width=200;
			__height=50;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		private function downHandler(e:MouseEvent):void
		{
			__state=DOWN;
			updateTexture();
			stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
		}
		private function upHandler(e:MouseEvent):void
		{
			__state=UP;
			updateTexture();
			stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler); 
		}
		private function childResizeHandler(e:Event):void
		{
			__labelShadow.visible = false;
			__label.x=this.width*.5-__label.width*.5;
			__label.y=this.height*.5-__label.height*.5-1;
			invalidate();
		}
		override protected function render():void
		{
			updateTexture();
			
			__label.x=this.width*.5-__label.width*.5;
			__label.y=this.height*.5-__label.height*.5-1;
			__labelShadow.bitmapData=new BitmapData(__label.width, __label.height, true, 0x0);
			__labelShadow.bitmapData.draw(__label);
			BitmapDataUtil.lighter(__labelShadow.bitmapData, -255);
			__labelShadow.x=__label.x;
			__labelShadow.y=__label.y-1;
			__labelShadow.visible = true;
		}
		private function updateTexture():void
		{
			if(__state == DOWN)
				__skin.bitmapData=getButtonDownTexture(__width, __height);
			else if(__state == UP)
				__skin.bitmapData=getButtonUpTexture(__width, __height);
		}
	}
}