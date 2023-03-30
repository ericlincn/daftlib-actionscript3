package cn.daftlib.utils
{
	import flash.net.LocalConnection;
	import flash.system.Capabilities;
	import flash.system.TouchscreenType;

	public final class SystemUtil
	{
		public static function get inAir():Boolean
		{
			return (Capabilities.playerType == "Desktop");
		}
		public static function get inBrowser():Boolean
		{
			return (Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX");
		}
		public static function get isDebugger():Boolean
		{
			return Capabilities.isDebugger;
		}
		public static function get isTouchScreen():Boolean
		{
			return Capabilities.touchscreenType != TouchscreenType.NONE;
		}
		/**
		 * Forcing gc
		 */
		public static function gc():void
		{
			try
			{
				new LocalConnection().connect("__FORCE_GC__");
				new LocalConnection().connect("__FORCE_GC__");
			}
			catch(error:Error)
			{
			}
		}
	}
}