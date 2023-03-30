package cn.daftlib.platform
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.events.Event;
	import flash.system.Capabilities;

	public final class MobileApplication
	{
		public static function get version():String
		{
			var appDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appDescriptor.namespace();
			return "" + appDescriptor.ns::versionNumber;
		}
		public static function get language():String
		{
			return Capabilities.language;
		}
		public static function set keepAwake(value:Boolean):void
		{
			if(value == true)
			{
				trace(MobileApplication, 'Flag <uses-permission android:name="android.permission.WAKE_LOCK"/> <uses-permission android:name="android.permission.DISABLE_KEYGUARD"/> must be added in the application descriptor.');
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			}
			else
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		}
		public static function set autoExit(value:Boolean):void
		{
			if(value == true)
			{
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, deactiveHandler);
			}
			else
				NativeApplication.nativeApplication.removeEventListener(Event.DEACTIVATE, deactiveHandler);
		}
		private static function deactiveHandler(e:Event):void
		{
			exit();
		}
		public static function exit():void
		{
			trace(MobileApplication, 'iOS didnt supports this method.')
			NativeApplication.nativeApplication.exit();
		}
	}
}