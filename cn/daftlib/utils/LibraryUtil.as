package cn.daftlib.utils
{
	import flash.display.DisplayObject;
	import flash.system.ApplicationDomain;

	public final class LibraryUtil
	{
		public static function createClassByNameInDisplayObject($className:String, $do:DisplayObject):*
		{
			var ad:ApplicationDomain = $do.loaderInfo.applicationDomain;

			return createClassByNameInApplicationDomain($className, ad);
		}
		public static function createClassByNameInApplicationDomain($className:String, $ad:ApplicationDomain):*
		{
			var TYPE:Class = getClassByNameInApplicationDomain($className, $ad);

			return new TYPE();
		}
		public static function getClassByNameInApplicationDomain($className:String, $ad:ApplicationDomain):Class
		{
			try
			{
				return $ad.getDefinition($className) as Class;
			}
			catch(error:Error)
			{
			}
			return null;
		}
		public static function getClassByNameInDisplayObject($className:String, $do:DisplayObject):Class
		{
			var ad:ApplicationDomain = $do.loaderInfo.applicationDomain;

			try
			{
				return ad.getDefinition($className) as Class;
			}
			catch(error:Error)
			{
			}
			return null;
		}
	}
}