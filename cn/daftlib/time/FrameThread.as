package cn.daftlib.time
{
	import flash.events.Event;
	
	import cn.daftlib.core.RemovableEventDispatcher;

	[Event(name = "complete", type = "flash.events.Event")]

	public final class FrameThread extends RemovableEventDispatcher
	{
		private var __methods:Vector.<Function>;
		private var __currentIndex:uint = 0;
		private var __intervalFrame:IntervalFrame;

		public function FrameThread(methods:Vector.<Function>, interval:uint = 1)
		{
			super(null);

			if(methods == null || methods.length <= 1)
				throw new Error("Argument $methods should be valid.");

			__methods = methods;
			__intervalFrame = new IntervalFrame();
			__intervalFrame.addEventListener(applyMethods, interval);
		}
		override public function destroy():void
		{
			__intervalFrame.removeEventListener(applyMethods);
			__intervalFrame.destroy();
			__intervalFrame = null;

			__methods = null;

			super.destroy();
		}
		private function applyMethods():void
		{
			__methods[__currentIndex].apply();
			__currentIndex++;

			if(__currentIndex >= __methods.length)
			{
				__intervalFrame.removeEventListener(applyMethods);
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
		}
	}
}