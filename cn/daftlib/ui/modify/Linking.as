package cn.daftlib.ui.modify
{
	import flash.utils.Dictionary;

	/**
	 * Create a temporary simple link between 2 objects instead the bind
	 *
	 * @example To link a url to a button
	 *
	 *		<listing version="3.0">
	 *			Linking.link(btn1, "http://www.google.com");
	 *			btn1.addEventListener(MouseEvent.CLICK, goUrl);
	 *
	 * 			Linking.link(btn2, "http://www.microsoft.com");
	 *			btn2.addEventListener(MouseEvent.CLICK, goUrl);
	 *
	 * 			//get the linked url by btn
	 *			function goUrl(e:MouseEvent):void
	 * 			{
	 * 				trace(Linking.getObjectByKey(e.target));
	 * 			}
	 *		</listing>
	 *
	 * @author Eric.lin
	 *
	 */
	public final class Linking
	{
		private static var __linkDict:Dictionary = new Dictionary(true);

		/**
		 * Links 2 objects, $uniqueKey is the key
		 * @param $uniqueKey
		 * @param $ob
		 */
		public static function link($uniqueKey:Object, $object:Object):void
		{
			if(__linkDict[$uniqueKey] != undefined)
				throw new Error($uniqueKey.toString() + " as a unique key has been linked.");

			__linkDict[$uniqueKey] = $object;
		}
		public static function getObjectByKey($uniqueKey:Object):Object
		{
			if(__linkDict[$uniqueKey] == undefined)
				throw new Error($uniqueKey.toString() + " as a key hasn't been linked.");

			return __linkDict[$uniqueKey];
		}
		public static function removeLink($uniqueKey:Object):void
		{
			if(__linkDict[$uniqueKey] != undefined)
				delete __linkDict[$uniqueKey];
		}
		public static function clear():void
		{
			__linkDict = new Dictionary(true);
		}
	}
}