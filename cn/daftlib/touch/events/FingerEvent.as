package cn.daftlib.touch.events
{
	import flash.events.Event;

	public final class FingerEvent extends Event
	{
		public static const FINGER_BEGIN:String = "fingerBegin";
		public static const FINGER_END:String = "fingerEnd";
		public static const FINGER_DOWN:String = "fingerDown";
		public static const FINGER_UP:String = "fingerUp";
		public static const FINGER_CLICK:String = "fingerClick";
		public static const FINGER_HOLD:String = "fingerHold";

		public var stageX:Number;
		public var stageY:Number;

		public function FingerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}