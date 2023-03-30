package cn.daftlib.touch
{
	import flash.display.Stage;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	import cn.daftlib.errors.DuplicateDefinedError;
	import cn.daftlib.touch.clients.MouseClient;
	import cn.daftlib.touch.clients.TouchDeviceType;
	import cn.daftlib.touch.clients.TouchScreenClient;
	import cn.daftlib.touch.clients.TuioClient;

	public final class DaftTouch
	{
		private static var __initialized:Boolean = false;

		public function DaftTouch(stage:Stage, touchDeviceType:String = TouchDeviceType.TOUCH_SCREEN)
		{
			if(__initialized == true)
				throw new DuplicateDefinedError("[class DaftTouch]");

			if(touchDeviceType == TouchDeviceType.MOUSE)
			{
				new MouseClient(new TouchListener(stage), stage);
				__initialized = true;
			}
			else if(touchDeviceType == TouchDeviceType.TOUCH_SCREEN)
			{
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				new TouchScreenClient(new TouchListener(stage), stage);
				__initialized = true;
			}
			else if(touchDeviceType == TouchDeviceType.TUIO)
			{
				new TuioClient(new TouchListener(stage), stage, "127.0.0.1", 3333);
				__initialized = true;
			}
		}
	}
}