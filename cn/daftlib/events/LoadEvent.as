package cn.daftlib.events
{
	import flash.events.Event;

	public final class LoadEvent extends Event
	{
		public static const START:String = "start";
		public static const PROGRESS:String = "progress";
		public static const COMPLETE:String = "complete";
		public static const ITEM_COMPLETE:String = "itemComplete";

		public var url:String;
		public var percent:Number;
		public var itemsLoaded:uint;
		public var itemsTotal:uint;

		public function LoadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}