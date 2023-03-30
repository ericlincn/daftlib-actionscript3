package cn.daftlib.time
{
	import flash.display.Bitmap;
	import flash.events.Event;

	/**
	 * Globe enterFrame events firer.
	 * 用于一些需要dispatch EnterFrame事件的非显示对象
	 * 或者为需要加到舞台上的显示对象提供更高的EnterFrame事件发送效率
	 *
	 * @example Adding a enterFrame event listener
	 *
	 *		<listing version="3.0">
	 * 			EnterFrame.addEventListener(update);
	 *
	 *			function update(e:Event):void
	 * 			{
	 * 				trace("fire event pre frame");
	 * 			}
	 *		</listing>
	 *
	 * @author Eric.lin
	 */
	public final class EnterFrame
	{
		private static var __pulse:Bitmap = new Bitmap();

		public static function addEventListener(listener:Function):void
		{
			__pulse.addEventListener(Event.ENTER_FRAME, listener, false, 0, false);
		}
		public static function removeEventListener(listener:Function):void
		{
			__pulse.removeEventListener(Event.ENTER_FRAME, listener, false);
		}
	}
}