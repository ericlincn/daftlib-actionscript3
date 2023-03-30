package cn.daftlib.events
{
	import flash.events.Event;

	public final class CuePointEvent extends Event
	{
		public static const CUE:String = "cue";

		public var time:Number;

		public function CuePointEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}