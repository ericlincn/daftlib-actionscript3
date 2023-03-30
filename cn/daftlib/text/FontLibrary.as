package cn.daftlib.text
{
	import flash.text.Font;

	public final class FontLibrary
	{
		public static const DroidSansFallback:String = "Droid Sans Fallback";
		public static const MicrosoftYAHEI:String = "微软雅黑";

		public static function getRegistedFonts(embedded:Boolean = true):Array
		{
			var out:Array = [];
			var arr:Array = Font.enumerateFonts(!embedded);
			arr.sortOn("fontName", Array.CASEINSENSITIVE);

			var i:uint = 0;
			while(i < arr.length)
			{
				if(arr[i].fontType != "embedded" || embedded == true)
				{
					if(out.indexOf(arr[i].fontName) < 0)
						out.push(arr[i].fontName);
				}
				i++;
			}
			return out;
		}
		public static function getSystemFirstChoiceFont():String
		{
			var fontsArr:Array = getRegistedFonts(false);

			if(fontsArr.indexOf(DroidSansFallback) >= 0)
				return DroidSansFallback;

			if(fontsArr.indexOf(MicrosoftYAHEI) >= 0)
				return MicrosoftYAHEI;

			return null;
		}
	}
}