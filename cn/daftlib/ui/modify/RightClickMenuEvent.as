package cn.daftlib.ui.modify
{
	import flash.display.InteractiveObject;
	import flash.events.Event;

	public final class RightClickMenuEvent extends Event
	{
		public static const MENU_ITEM_SELECT:String = "menuItemSelect";

		public var contextMenuOwner:InteractiveObject;
		public var isMouseTargetInaccessible:Boolean;
		public var mouseTarget:InteractiveObject;
		public var message:String;

		public function RightClickMenuEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}