package cn.daftlib.display
{
	import flash.display.Sprite;

	import cn.daftlib.arcane;
	import cn.daftlib.core.IDestroyable;
	import cn.daftlib.core.IRemovableEventDispatcher;
	import cn.daftlib.core.ListenerManager;

	/**
	 * DaftSprite can be destroyed, within destroy method,
	 * the instance will be removed from display list, and also all event listeners will be removed.
	 *
	 * @example Completely destroy a DaftSprite
	 *
	 *		<listing version="3.0">
	 * 			//Create a DaftSprite
	 * 			var sp:DaftSprite=new DaftSprite();
	 * 			sp.addChild(new Bitmap(null));
	 * 			sp.addChild(new MovieClip());
	 * 			sp.addEventListener(Event.ENTER_FRAME, update);
	 * 			sp.addEventListener(MouseEvent.CLICK, click);
	 * 			this.addChild(sp);
	 *
	 * 			//Remove the children in DaftSprite
	 * 			DisplayObjectUtil.destroyAllChildrenIn(sp);
	 * 			sp.destroy();
	 *
	 * 			//Clear the reference
	 * 			sp=null;
	 *		</listing>
	 *
	 * @author Eric.lin
	 *
	 */
	public class DaftSprite extends Sprite implements IDestroyable, IRemovableEventDispatcher
	{
		public function DaftSprite()
		{
			super();

			this.mouseChildren = this.mouseEnabled = false;
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