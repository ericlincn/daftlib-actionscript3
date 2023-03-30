package cn.daftlib.ui.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	import cn.daftlib.display.DaftBitmap;

	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "ioError", type = "flash.events.IOErrorEvent")]

	public final class RemoteBitmap extends DaftBitmap
	{
		private var __loader:Loader;
		private var __request:URLRequest;
		private var __resize:int;

		public function RemoteBitmap(reszie:int = 0)
		{
			super(null, "auto", false);

			__resize = reszie;

			__loader = new Loader();
			__request = new URLRequest();
		}
		override public function destroy():void
		{
			clear();

			__loader = null;
			__request = null;

			super.destroy();
		}
		public function set source(value:Object):void
		{
			if(value is String)
			{
				if(__request.url == String(value))
					return;

				__request.url = String(value);

				try
				{
					__loader.unload();
				}
				catch(error:Error)
				{
					trace(this, error);
				}

				prepareLoader();
				__loader.load(__request);
			}
			else if(value is ByteArray)
			{
				__request.url = null;

				try
				{
					__loader.unload();
				}
				catch(error:Error)
				{
					trace(this, error);
				}

				prepareLoader();
				__loader.loadBytes(ByteArray(value));
			}
			else if(value == null)
			{
				try
				{
					__loader.unload();
				}
				catch(error:Error)
				{
					trace(this, error);
				}

				clear();
			}
		}
		private function prepareLoader():void
		{
			__loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
			__loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		private function clear():void
		{
			__loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			__loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			__request.url = null;

			this.bitmapData = null;
		}
		private function loadCompleteHandler(event:Event):void
		{
			var li:LoaderInfo = event.target as LoaderInfo;
			var bmd:BitmapData = Bitmap(li.content).bitmapData;
			if(__resize > 0)
			{
				var w:Number;
				var h:Number;
				var s:Number;
				if(bmd.width > bmd.height)
				{
					w = __resize;
					s = __resize / bmd.width;
					h = int(bmd.height * s);
				}
				else
				{
					h = __resize;
					s = __resize / bmd.height;
					w = int(bmd.width * s);
				}
				var m:Matrix = new Matrix();
				m.scale(s, s);
				var nbmd:BitmapData = new BitmapData(w, h, true, 0x0);
				nbmd.draw(bmd, m, null, null, null, true);
				bmd = nbmd;
			}
			this.bitmapData = bmd;

			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			//trace(this, event);
			this.dispatchEvent(event);
		}
	}
}