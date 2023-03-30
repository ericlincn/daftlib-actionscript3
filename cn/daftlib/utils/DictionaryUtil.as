package cn.daftlib.utils
{
	import flash.utils.Dictionary;

	public final class DictionaryUtil
	{
		public static function getDictionaryLength(map:Dictionary):uint
		{
			var i:uint = 0;
			for(var key:* in map)
			{
				i++;
			}
			return i;
		}
		public static function printDictionary(map:Dictionary):String
		{
			var outStr:String = "";
			var n:int = getDictionaryLength(map);
			for(var key:* in map)
			{
				outStr += map + " " + key + ": " + map[key];
				if(n > 1)
					outStr += "\n";

				n--;
			}
			return outStr == "" ? null : outStr;
		}
	}
}