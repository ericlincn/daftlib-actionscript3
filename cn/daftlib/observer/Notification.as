package cn.daftlib.observer
{
	/**
	 * Used by NotificationsCenter
	 *
	 * @author Eric.lin
	 */
	public final class Notification implements INotification
	{
		private var __name:String;
		private var __body:Object;

		public function Notification(name:String, body:Object)
		{
			__name = name;
			__body = body;
		}
		public function get name():String
		{
			return __name;
		}
		public function get body():Object
		{
			return __body;
		}
	}
}