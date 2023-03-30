package cn.daftlib.time
{
	import flash.events.Event;
	
	import cn.daftlib.core.IDestroyable;

	public final class IntervalFrame implements IDestroyable
	{
		private static var __functionArr:Array;
		private static var __frameCount:uint;

		public function IntervalFrame()
		{
			__functionArr = [];
			__frameCount = 0;
		}
		public function destroy():void
		{
			EnterFrame.removeEventListener(enterFrameHandler);
			
			__functionArr = null;
		}
		public function addEventListener(listener:Function, interval:uint = 1):void
		{
			if(__functionArr == null) return;
			
			interval = Math.max(1, interval);

			var i:int = __functionArr.length;
			while(i--)
			{
				var f:Function = __functionArr[i].f;
				if(f == listener)
				{
					throw new Error("The $listener has been registered.");
					return;
				}
			}

			__functionArr.push({f:listener, i:interval});

			if(__functionArr.length == 1)
				EnterFrame.addEventListener(enterFrameHandler);
		}
		public function removeEventListener(listener:Function):void
		{
			if(__functionArr == null) return;
			
			if(__functionArr.length == 0)
				return;

			var i:int = __functionArr.length;
			while(i--)
			{
				var f:Function = __functionArr[i].f;
				if(f == listener)
					__functionArr.splice(i, 1);
			}

			if(__functionArr.length == 0)
			{
				EnterFrame.removeEventListener(enterFrameHandler);
				__frameCount = 0;
			}
		}
		private function enterFrameHandler(e:Event):void
		{
			if(__functionArr == null) return;
			
			__frameCount++;

			var i:int = __functionArr.length;
			while(i--)
			{
				var f:Function = __functionArr[i].f;
				var interval:uint = __functionArr[i].i;
				if(__frameCount % interval == 0)
					f.apply();
			}
		}
	}
}