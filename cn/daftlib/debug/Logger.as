package cn.daftlib.debug
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	public class Logger extends Sprite
	{
		private static const TIME_WIDTH:Number=55;
		
		private var __messageLogger:TextField;
		private var __timeLogger:TextField;

		public function Logger(width:Number=500, height:Number=240)
		{
			super();

			this.mouseChildren = this.mouseEnabled = false;

			this.addChild(new Bitmap(new BitmapData(width, height, false, 0x222222))).alpha=.7;

			__messageLogger = new TextField();
			__messageLogger.defaultTextFormat = new TextFormat("Tahoma", 9, 0xFFFFFF, true);
			__messageLogger.wordWrap = true;
			__messageLogger.width = width - 14 - TIME_WIDTH;
			__messageLogger.height = height -20;
			__messageLogger.x = 7;
			__messageLogger.y = 5;
			this.addChild(__messageLogger);

			__timeLogger = new TextField();
			__timeLogger.defaultTextFormat = new TextFormat("Tahoma", 9, 0xAAAAAA, true);
			__timeLogger.wordWrap = false;
			__timeLogger.width = TIME_WIDTH;
			__timeLogger.height = __messageLogger.height;
			__timeLogger.x = __messageLogger.x + __messageLogger.width;
			__timeLogger.y = 5;
			this.addChild(__timeLogger);

			var tip:TextField = new TextField();
			tip.defaultTextFormat = new TextFormat("Tahoma", 9, 0xAAAAAA, true);
			tip.autoSize = TextFieldAutoSize.LEFT;
			tip.text = "Scroll with mouse wheel or mouse drag";
			tip.x = 7;
			tip.y = this.height - 21;
			this.addChild(tip);

			__messageLogger.selectable = __messageLogger.mouseEnabled = __messageLogger.mouseWheelEnabled = false;
			__timeLogger.selectable = __timeLogger.mouseEnabled = __timeLogger.mouseWheelEnabled = false;
			tip.selectable = tip.mouseEnabled = tip.mouseWheelEnabled = false;
			__messageLogger.addEventListener(Event.SCROLL, followScrollV);
		}
		internal function saveLogToFile():void
		{
			if(__messageLogger.text.length <= 0)
				return;
			
			var str:String = __messageLogger.text;
			str = str.split("\r").join("\r\n");
			
			var file:FileReference = new FileReference();
			try
			{
				file.save(str, "log" + int(getTimer() / 1000) + ".txt");
			}
			catch(error:Error)
			{
				trace(Profiler, error);
			}
		}
		internal function log(... parameters):void
		{
			var i:int = 0;
			while(i < parameters.length)
			{
				if(i == (parameters.length - 1))
					__messageLogger.appendText(parameters[i].toString() + "\n");
				else
					__messageLogger.appendText(parameters[i].toString());

				i++;
			}

			__messageLogger.scrollV = __messageLogger.maxScrollV;

			__timeLogger.appendText(getTimer().toString() + "\n");

			if(__messageLogger.numLines > __timeLogger.numLines)
			{
				i = __messageLogger.numLines - __timeLogger.numLines;
				while(i--)
				{
					__timeLogger.appendText("\n");
				}
			}
		}
		internal function updateScrollOffsets(offsets:int):void
		{
			var targetScrollV:int = __messageLogger.scrollV + offsets;
			if(targetScrollV < 1)
				targetScrollV = 1;
			else if(targetScrollV > __messageLogger.maxScrollV)
				targetScrollV = __messageLogger.maxScrollV;

			__messageLogger.scrollV = targetScrollV;
		}
		private function followScrollV(e:Event):void
		{
			__timeLogger.scrollV = __messageLogger.scrollV;
		}
	}
}
