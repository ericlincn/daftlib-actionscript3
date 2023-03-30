package cn.daftlib.ui.modify
{

	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;

	[Event(name = "menuItemSelect", type = "cn.daftlib.ui.modify.RightClickMenuEvent")]

	public class RightClickMenu
	{
		private static var __dispatcher:EventDispatcher = new EventDispatcher();

		private static var __menuMap:Dictionary = new Dictionary(true);
		private static var __messageMap:Dictionary = new Dictionary(true);

		public static function addMenuItemForTarget($menuTarget:InteractiveObject, $lable:String, $message:String = null, $separatorBefore:Boolean = false):void
		{
			var menu:ContextMenu;

			if(__menuMap[$menuTarget] == undefined)
			{
				menu = new ContextMenu();
				menu.hideBuiltInItems();
				__menuMap[$menuTarget] = menu;
				$menuTarget.contextMenu = menu;
			}
			else
				menu = __menuMap[$menuTarget];

			var menuItem:ContextMenuItem = new ContextMenuItem($lable, $separatorBefore);
			menu.customItems.push(menuItem);

			if($message != null)
			{
				__messageMap[menuItem] = $message;
				menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handleMenuItemSelect);
			}
		}
		private static function handleMenuItemSelect(e:ContextMenuEvent):void
		{
			var menuItem:ContextMenuItem = e.target as ContextMenuItem;

			var event:RightClickMenuEvent = new RightClickMenuEvent(RightClickMenuEvent.MENU_ITEM_SELECT);
			event.contextMenuOwner = e.contextMenuOwner;
			event.isMouseTargetInaccessible = e.isMouseTargetInaccessible;
			event.mouseTarget = e.mouseTarget;
			event.message = __messageMap[menuItem];

			dispatchEvent(event);
		}
		public static function removeMenuForTarget($menuTarget:InteractiveObject):void
		{
			if(__menuMap[$menuTarget] != undefined)
			{
				var menu:ContextMenu = __menuMap[$menuTarget];
				var i:uint = menu.customItems.length;
				while(i--)
				{
					var menuItem:ContextMenuItem = menu.customItems[i];
					if(menuItem.hasEventListener(ContextMenuEvent.MENU_ITEM_SELECT))
						menuItem.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handleMenuItemSelect);

					delete __messageMap[menuItem];
					menuItem = null;
				}

				delete __menuMap[$menuTarget];
				menu = null;
			}
		}

		public static function addEventListener(type:String, listener:Function):void
		{
			__dispatcher.addEventListener(type, listener, false, 0, false);
		}
		public static function removeEventListener(type:String, listener:Function):void
		{
			__dispatcher.removeEventListener(type, listener, false);
		}
		public static function dispatchEvent(event:Event):Boolean
		{
			return __dispatcher.dispatchEvent(event);
		}
		public static function hasEventListener(type:String):Boolean
		{
			return __dispatcher.hasEventListener(type);
		}
	}
}