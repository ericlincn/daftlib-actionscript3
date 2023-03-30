package cn.daftlib.core
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import cn.daftlib.arcane;

	/**
	 * Within destroy method, all event listeners will be removed.
	 *
	 * Just in case you need an object with destroy method, and the it is IEventDispatcher,
	 * an also it is NOT displayobject, then the object should extends RemovableEventDispatcher.
	 * And if the object IS displayobject, the object should extends DaftSprite.
	 *
	 * @author Eric.lin
	 *
	 */
	public class RemovableEventDispatcher extends EventDispatcher implements IRemovableEventDispatcher, IDestroyable
	{
		public function RemovableEventDispatcher(target:IEventDispatcher = null)
		{
			super(target);
		}

		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			ListenerManager.arcane::registerEventListener(this, type, listener, useCapture);
		}
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			super.removeEventListener(type, listener, useCapture);
			ListenerManager.arcane::unregisterEventListener(this, type, listener, useCapture);
		}
		public function removeEventsForType(type:String):void
		{
			ListenerManager.arcane::removeEventsForType(this, type);
		}
		public function removeEventsForListener(listener:Function):void
		{
			ListenerManager.arcane::removeEventsForListener(this, listener);
		}
		public function removeEventListeners():void
		{
			ListenerManager.arcane::removeEventListeners(this);
		}
		public function destroy():void
		{
			this.removeEventListeners();
		}
	}
}