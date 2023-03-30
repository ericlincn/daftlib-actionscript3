package cn.daftlib.events
{
	import flash.events.Event;
	
	public final class ScrollEvent extends Event
	{
		public static const UPDATE_LIST_SIZE:String = "updateListSize";
		public static const UPDATE_LIST_POSITION:String = "updateListPosition";
		public static const SCROLL_STOP:String = "scrollStop";
		
		public var viewportSize:Number;
		public var listSize:Number;
		public var scrollPosition:Number;
		
		public function ScrollEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}