package cn.daftlib.observer
{
	import flash.utils.Dictionary;

	/**
	 * Managements globe events communications,
	 * using the Notifications instead of flash events.
	 *
	 * @example Register some notifications
	 *
	 *		<listing version="3.0">
	 * 			//ui is an IObserver
	 *			NotificationsCenter.register(NotificationsConstants.START_UP, ui);
	 * 			...
	 *
	 * 			//Firing the Notifications, with a parameter(object).
	 * 			NotificationsCenter.sendNotification(NotificationsConstants.START_UP, data);
	 * 			...
	 *
	 * 			//In ui
	 * 			function handlerNotification($notification:INotification):void
	 * 			{
	 * 				switch($notification.getName)
	 * 				{
	 * 					case NotificationsConstants.START_UP:
	 * 						doSomething($notification.getBody);
	 * 						break;
	 * 				}
	 * 			}
	 *		</listing>
	 *
	 * @author Eric.lin
	 *
	 */
	public final class NotificationsCenter
	{
		private static var __observerMap:Dictionary = new Dictionary();

		public static function register(notificationName:String, observer:IObserver):void
		{
			var observersArr:Array = __observerMap[notificationName];
			if(observersArr != null)
			{
				var i:int = observersArr.length;
				while(i--)
				{
					if(observersArr[i] == observer)
						return;
				}

				observersArr.push(observer);
			}
			else
				__observerMap[notificationName] = [observer];
		}
		public static function sendNotification(notificationName:String, data:Object):void
		{
			var observersArr:Array = __observerMap[notificationName];
			if(observersArr == null)
				return;

			var i:uint = 0;
			while(i < observersArr.length)
			{
				var observer:IObserver = observersArr[i];
				var callback:Function = observer.handlerNotification;
				var notification:Notification = new Notification(notificationName, data);
				callback.apply(null, [notification]);

				i++;
			}
		}
		public static function unregisterForNotification(notificationName:String):void
		{
			delete __observerMap[notificationName];
		}
		public static function unregisterForObserver(observer:IObserver):void
		{
			for(var key:String in __observerMap)
			{
				var observersArr:Array = __observerMap[key];

				var i:int = observersArr.length;
				while(i--)
				{
					if(observersArr[i] == observer)
						observersArr.splice(i, 1);
				}

				if(observersArr.length == 0)
					delete __observerMap[key];
			}
		}
		public static function unregister(notificationName:String, observer:IObserver):void
		{
			var observersArr:Array = __observerMap[notificationName];
			if(observersArr == null)
				return;

			var i:int = observersArr.length;
			while(i--)
			{
				if(observersArr[i] == observer)
					observersArr.splice(i, 1);
			}

			if(observersArr.length == 0)
				delete __observerMap[notificationName];
		}
	}
}