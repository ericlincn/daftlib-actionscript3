package cn.daftlib.ui.components
{
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import cn.daftlib.display.DaftTextField;

	[Event(name = "resize", type = "flash.events.Event")]
	
	public class Lable extends DaftTextField
	{
		private var __font:String = null;
		private var __size:Number = 20;
		private var __color:uint = 0x222222;

		private var __format:TextFormat;

		public function Lable()
		{
			super();

			this.autoSize = TextFieldAutoSize.LEFT;

			__format = new TextFormat(__font, __size, __color);

			render();
		}
		override public function set text(value:String):void
		{
			super.text=value;
			
			this.dispatchEvent(new Event(Event.RESIZE));
		}
		public function set font(fontName:String):void
		{
			if(__font == fontName)
				return;
			
			__font = fontName;
			
			render();
			
			this.dispatchEvent(new Event(Event.RESIZE));
		}
		public function set size(value:Number):void
		{
			if(__size == value)
				return;

			__size = value;

			render();
			
			this.dispatchEvent(new Event(Event.RESIZE));
		}
		public function set color(color:uint):void
		{
			if(__color == color)
				return;

			__color = color;

			render();
		}
		private function render():void
		{
			__format.font = __font;
			__format.size = __size;
			__format.color = __color;

			this.defaultTextFormat = __format;
			this.text = this.text;
		}
	}
}