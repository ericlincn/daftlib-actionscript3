package cn.daftlib.device
{
	import flash.display.Screen;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public final class Monitors
	{
		public static function expendsStageToAllMonitors($stage:Stage):void
		{
			var screens:Array = Screen.screens;
			var rect:Rectangle = new Rectangle();

			var i:uint = 0;
			while(i < screens.length)
			{
				rect = rect.union(screens[i].bounds);
				i++;
			}

			$stage.nativeWindow.bounds = rect;
			$stage.nativeWindow.alwaysInFront = true;
			$stage.nativeWindow.activate();
		}
		public static function get currentMonitorsCount():uint
		{
			return Screen.screens.length;
		}
	}
}