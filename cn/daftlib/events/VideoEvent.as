package cn.daftlib.events
{
	import flash.events.Event;

	public final class VideoEvent extends Event
	{
		public static const START:String = "start";
		public static const STOP:String = "stop";
		public static const META_DATA:String = "metaData";
		public static const BUFFER_FULL:String = "bufferFull";
		public static const BUFFER_EMPTY:String = "bufferEmpty";

		public var duration:Number;
		public var framerate:uint;
		public var width:Number;
		public var height:Number;

		public function VideoEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}