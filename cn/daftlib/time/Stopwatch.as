package cn.daftlib.time
{
	import flash.utils.getTimer;

	public final class Stopwatch
	{
		private static var __startTime:int = 0;

		public static function start():void
		{
			__startTime = getTimer();
		}
		public static function get time():int
		{
			return getTimer() - __startTime;
		}
	}
}