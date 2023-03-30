package cn.daftlib.core
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	import cn.daftlib.arcane;

	/**
	 * Managements all event listeners for IRemovableEventDispatcher.
	 * Provide the method to remove all event listeners for IRemovableEventDispatcher.
	 *
	 * @example If you want to manage IEventDispatcher using ListenerManager, code like this,
	 *
	 *		<listing version="3.0">
	 * 			//Create a regular sprite
	 * 			var sp:Sprite=new Sprite();
	 *
	 * 			sp.addEventListener(Event.ENTER_FRAME, update);
	 * 			sp.addEventListener(MouseEvent.CLICK, click);
	 * 			ListenerManager.registerEventListener(sp, Event.ENTER_FRAME, update, false);
	 *			ListenerManager.registerEventListener(sp, MouseEvent.CLICK, click, false);
	 *
	 * 			//Remove all event listeners for the sprite
	 * 			ListenerManager.removeEventListeners(sp);
	 *		</listing>
	 *
	 * @author Eric.lin
	 *
	 */
	use namespace arcane

	public final class ListenerManager
	{
		private static var __dispatcherMap:Dictionary = new Dictionary(true);

		arcane static function registerEventListener(dispatcher:IEventDispatcher, type:String, listener:Function, useCapture:Boolean):void
		{
			var eventInfoArr:Array = __dispatcherMap[dispatcher];
			var newEventInfo:EventInfo = new EventInfo(type, listener, useCapture);
			var oldEventInfo:EventInfo;

			if(eventInfoArr != null)
			{
				var i:int = eventInfoArr.length;
				while(i--)
				{
					oldEventInfo = eventInfoArr[i];
					if(oldEventInfo.equals(newEventInfo))
						return;
				}
				eventInfoArr.push(newEventInfo);
			}
			else
			{
				__dispatcherMap[dispatcher] = [newEventInfo];
			}
		}
		arcane static function unregisterEventListener(dispatcher:IEventDispatcher, type:String, listener:Function, useCapture:Boolean):void
		{
			var eventInfoArr:Array = __dispatcherMap[dispatcher];
			var newEventInfo:EventInfo = new EventInfo(type, listener, useCapture);
			var oldEventInfo:EventInfo;

			if(eventInfoArr == null)
				return;

			var i:int = eventInfoArr.length;
			while(i--)
			{
				oldEventInfo = eventInfoArr[i];
				if(oldEventInfo.equals(newEventInfo))
					eventInfoArr.splice(i, 1);
			}

			if(eventInfoArr.length == 0)
				delete __dispatcherMap[dispatcher];
		}
		arcane static function removeEventsForType(dispatcher:IEventDispatcher, type:String):void
		{
			var eventInfoArr:Array = __dispatcherMap[dispatcher];
			var oldEventInfo:EventInfo;

			if(eventInfoArr == null)
				return;

			var i:int = eventInfoArr.length;
			while(i--)
			{
				oldEventInfo = eventInfoArr[i];
				if(oldEventInfo.type == type)
				{
					eventInfoArr.splice(i, 1);
					dispatcher.removeEventListener(oldEventInfo.type, oldEventInfo.listener, oldEventInfo.useCapture);
				}
			}

			if(eventInfoArr.length == 0)
				delete __dispatcherMap[dispatcher];
		}
		arcane static function removeEventsForListener(dispatcher:IEventDispatcher, listener:Function):void
		{
			var eventInfoArr:Array = __dispatcherMap[dispatcher];
			var oldEventInfo:EventInfo;

			if(eventInfoArr == null)
				return;

			var i:int = eventInfoArr.length;
			while(i--)
			{
				oldEventInfo = eventInfoArr[i];
				if(oldEventInfo.listener == listener)
				{
					eventInfoArr.splice(i, 1);
					dispatcher.removeEventListener(oldEventInfo.type, oldEventInfo.listener, oldEventInfo.useCapture);
				}
			}

			if(eventInfoArr.length == 0)
				delete __dispatcherMap[dispatcher];
		}
		arcane static function removeEventListeners(dispatcher:IEventDispatcher):void
		{
			var eventInfoArr:Array = __dispatcherMap[dispatcher];
			var oldEventInfo:EventInfo;

			if(eventInfoArr == null)
				return;

			var i:int = eventInfoArr.length;
			while(i--)
			{
				oldEventInfo = eventInfoArr.splice(i, 1)[0];
				dispatcher.removeEventListener(oldEventInfo.type, oldEventInfo.listener, oldEventInfo.useCapture);
			}

			delete __dispatcherMap[dispatcher];

		}
		public static function printEventTypeList(dispatcher:IEventDispatcher):String
		{
			var eventInfoArr:Array = __dispatcherMap[dispatcher];
			var oldEventInfo:EventInfo;

			if(eventInfoArr == null)
				return null;

			var outputStr:String = (dispatcher as Object).toString() + " --Event type list-- " + "\n";
			var i:int = eventInfoArr.length;
			while(i--)
			{
				oldEventInfo = eventInfoArr[i];
				outputStr += "	EventType:" + oldEventInfo.type;

				var fix:String = "";
				if(i != 0)
					fix = "\n";
				outputStr += fix;
			}
			return outputStr;

		}
	}
}

class EventInfo
{
	public var type:String;
	public var listener:Function;
	public var useCapture:Boolean;

	public function EventInfo(type:String, listener:Function, useCapture:Boolean)
	{
		this.type = type;
		this.listener = listener;
		this.useCapture = useCapture;
	}
	public function equals(eventInfo:EventInfo):Boolean
	{
		return this.type == eventInfo.type && this.listener == eventInfo.listener && this.useCapture == eventInfo.useCapture;
	}
}