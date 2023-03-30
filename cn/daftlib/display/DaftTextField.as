package cn.daftlib.display
{
	import flash.text.TextField;

	import cn.daftlib.arcane;
	import cn.daftlib.core.IDestroyable;
	import cn.daftlib.core.IRemovableEventDispatcher;
	import cn.daftlib.core.ListenerManager;

	public class DaftTextField extends TextField implements IDestroyable, IRemovableEventDispatcher
	{
		public function DaftTextField()
		{
			super();

			this.mouseEnabled = this.mouseWheelEnabled = false;
			this.selectable = false;
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
		public function removeEventsForListener(listene:Function):void
		{
			ListenerManager.arcane::removeEventsForListener(this, listene);
		}
		public function removeEventListeners():void
		{
			ListenerManager.arcane::removeEventListeners(this);
		}

		override public function set x(value:Number):void
		{
			super.x = Math.round(value);
		}
		override public function set y(value:Number):void
		{
			super.y = Math.round(value);
		}
		/**
		 * Remove all event listeners for this object and remove this from display list.
		 * For completely destroy, you should set this object referrence to Null after call destroy().
		 */
		public function destroy():void
		{
			this.removeEventListeners();

			if(this.parent != null)
				this.parent.removeChild(this);
		}
	}
}