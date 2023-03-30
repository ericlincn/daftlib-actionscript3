package cn.daftlib.touch.events
{
	import flash.events.Event;

	public final class FingerGestureEvent extends Event
	{
		public static const GESTURE_PAN:String = "gesturePan";
		public static const GESTURE_ROTATE_SCALE:String = "gestureRotateScale";

		// For pan
		public var offsetX:Number;
		public var offsetY:Number;
		public var speedX:Number;
		public var speedY:Number;

		// For scale rotate
		public var scaleRatio:Number;
		public var rotationDelta:Number;
		public var registeX:Number;
		public var registeY:Number;

		public var stageX:Number;
		public var stageY:Number;

		public function FingerGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}