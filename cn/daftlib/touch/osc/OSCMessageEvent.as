package cn.daftlib.touch.osc
{
	import flash.events.Event;

	public final class OSCMessageEvent extends Event
	{
		public static var MESSAGE_RECEIVED:String = "messageReceived";

		public var data:Array;

		public function OSCMessageEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, data:Array = null)
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
	}
}