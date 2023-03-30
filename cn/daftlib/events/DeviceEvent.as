package cn.daftlib.events
{
	import flash.events.Event;
	
	public final class DeviceEvent extends Event
	{
		public static const RENDER:String = "render";
		public static const MUTED:String = "muted";
		
		public function DeviceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}