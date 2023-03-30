package cn.daftlib.media
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import cn.daftlib.core.RemovableEventDispatcher;
	import cn.daftlib.events.CuePointEvent;

	[Event(name = "cue", type = "cn.daftlib.events.CuePointEvent")]

	public final class CuePointLocator extends RemovableEventDispatcher
	{
		private var __media:IMedia;
		private var __timer:Timer;
		private var __refreshRate:uint;
		private var __cuepointsMap:Dictionary = new Dictionary();
		private var __cuepointsCount:uint = 0;

		public function CuePointLocator(media:IMedia, refreshRate:uint = 15)
		{
			super(null);

			__media = media;
			__refreshRate = refreshRate;
		}
		override public function destroy():void
		{
			__cuepointsMap = null;

			stopCheckingCuepoints();
			__timer = null;

			super.destroy();
		}
		public function addCuepoint(ms:Number):void
		{
			if(__cuepointsMap == null)
				return;

			__cuepointsMap[ms] = "false";
			__cuepointsCount++;

			if(__cuepointsCount == 1)
				startCheckingCuepoints();
		}
		private function startCheckingCuepoints():void
		{
			if(__timer == null)
			{
				__timer = new Timer(uint(1000 / __refreshRate));
				__timer.addEventListener(TimerEvent.TIMER, checkCuepoints);
				__timer.start();
			}
		}
		private function stopCheckingCuepoints():void
		{
			if(__timer != null)
			{
				__timer.removeEventListener(TimerEvent.TIMER, checkCuepoints);
				__timer.stop();
			}
		}
		private function checkCuepoints(e:Event = null):void
		{
			// Fix for destroy()
			if(__cuepointsMap == null)
				return;

			var targetKey:Number = NaN;

			for(var key:* in __cuepointsMap)
			{
				if(__media.playingTime >= Number(key) && Math.abs(__media.playingTime - Number(key)) < 1000)
				{
					if(isNaN(targetKey))
						targetKey = Number(key);
					else
						targetKey = Math.max(targetKey, Number(key));
				}
			}

			if(isNaN(targetKey))
				return;

			for(var k:* in __cuepointsMap)
			{
				if(k == targetKey)
				{
					if(__cuepointsMap[k] == "false")
					{
						__cuepointsMap[k] = "true";

						var event:CuePointEvent = new CuePointEvent(CuePointEvent.CUE);
						event.time = k;
						this.dispatchEvent(event);
					}
				}
				else
					__cuepointsMap[k] = "false";
			}
		}
	}
}