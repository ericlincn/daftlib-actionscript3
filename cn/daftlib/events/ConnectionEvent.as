package cn.daftlib.events
{
	import flash.events.Event;
	
	import cn.daftlib.net.INetPackage;
	
	public final class ConnectionEvent extends Event
	{
		public static const NET_STATUS_INFO:String="netStatusInfo";
		public static const PACKAGE_RECEIVE:String="packageReceive";
		
		public var infoCode:String;
		public var netPackage:INetPackage;
		
		public function ConnectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}