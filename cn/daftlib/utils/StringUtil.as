package cn.daftlib.utils
{
	import flash.utils.ByteArray;

	public final class StringUtil
	{
		public static const BG2312:String = "gb2312"; //chinese, CN-GB, csGB2312, csGB231280, csISO58GB231280, GB_2312-80, GB231280, GB2312-80, GBK, iso-ir-58
		public static const BIG5:String = "big5"; //cn-big5, csbig5, x-x-big5
		public static const GBK:String = "gbk";
		public static const UNICODE:String = "unicode"; //utf-16
		public static const UTF8:String = "utf-8"; //unicode-1-1-utf-8, unicode-2-0-utf-8, x-unicode-2-0-utf-8

		/**
		 * 以指定的字符集编码字符串
		 * @param $sourceStr
		 * @param $charset
		 * @return
		 */
		public static function encodeByCharset(source:String, charset:String):String
		{
			var result:String = "";
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(source, charset);
			for(var i:uint = 0; i < byte.length; i++)
			{
				result += escape(String.fromCharCode(byte[i]));
			}
			return result;
		}
		/**
		 * 是否为网址
		 * @param char
		 * @return
		 */
		public static function isURL(source:String):Boolean
		{
			source = trim(source).toLowerCase();
			var pattern:RegExp = /^http:\/\/[A-Za-z0-9]+\.[A-Za-z0-9]+[\/=\?%\-&_~`@[\]\':+!]*([^<>\"\"])*$/;
			var result:Object = pattern.exec(source);
			if(result == null)
			{
				return false;
			}
			return true;
		}
		/**
		 * 是否是Email
		 * @param email
		 * @return
		 */
		public static function isEmail(source:String):Boolean
		{
			var pattern:RegExp = /^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$/i;
			return source.match(pattern) != null;
		}
		/**
		 * 是否是数字
		 * @param char
		 * @return
		 */
		public static function isNumber(source:String):Boolean
		{
			return !isNaN(Number(source));
		}
		/**
		 * 去左右空格
		 * @param char
		 * @return
		 */
		public static function trim(source:String):String
		{
			return rtrim(ltrim(source));
		}
		/**
		 * 去左空格
		 * @param char
		 * @return
		 */
		public static function ltrim(source:String):String
		{
			var pattern:RegExp = /^\s*/;
			return source.replace(pattern, "");
		}
		/**
		 * 去右空格
		 * @param char
		 * @return
		 */
		public static function rtrim(source:String):String
		{
			var pattern:RegExp = /\s*$/;
			return source.replace(pattern, "");
		}
		/**
		 * 字符串首字母大写，其余字母小写
		 * @param original
		 * @return
		 */
		public static function initialCap(source:String):String
		{
			return source.charAt(0).toUpperCase() + source.substr(1).toLowerCase();
		}
		/**
		 * Removes tabs, linefeeds, carriage returns and spaces from String.
		 * @param source
		 * @return
		 */
		public static function removeWhitespace(source:String):String
		{
			var pattern:RegExp = new RegExp('[ \n\t\r]', 'g');
			return source.replace(pattern, '');
		}
		/**
		 * 取得字符串中的数字
		 * @param source
		 * @return
		 */
		public static function getNumbersFromString(source:String):String
		{
			var pattern:RegExp = /[^0-9]/g;
			return source.replace(pattern, '');
		}
		/**
		 * 取得字符串中的字母
		 * @param source
		 * @return
		 */
		public static function getLettersFromString(source:String):String
		{
			var pattern:RegExp = /[^A-Z^a-z]/g;
			return source.replace(pattern, '');
		}
		/**
		 * Replaces target characters with new characters.
		 * @param source
		 * @param remove
		 * @param replace
		 * @return
		 */
		public static function replace(source:String, remove:String, replace:String):String
		{
			var pattern:RegExp = new RegExp(remove, 'g');
			return source.replace(pattern, replace);
		}
		/**
		 * 替换字符串模板
		 *
		 * var str:String = "Hei jave, there are {0} apples，and {1} banana！ {2} dollar all together";
		 * trace(StringUtil.substitute(str, 5, 10, 20));
		 *
		 * @param str
		 * @param rest
		 * @return
		 */
		public static function substitute(source:String, ... rest):String
		{
			if(source == null)
				return '';

			// Replace all of the parameters in the msg string. 
			var len:uint = rest.length;
			var args:Array;

			if(len == 1 && rest is Array)
			{
				args = rest as Array;
				len = args.length;
			}
			else
			{
				args = rest;
			}

			for(var i:int = 0; i < len; i++)
			{
				source = source.replace(new RegExp("\\{" + i + "\\}", "g"), args);
			}

			return source;
		}
		/**
		 * 以属性名方式替换字符串模板
		 *
		 * var str:String = "{call}这是{structname}结构代换你的懂。";
		 * trace(StringUtil.substituteProperty(str, {call:"哥，", structname:"k,v数据"}));
		 *
		 * @param str
		 * @param obj
		 * @return
		 */
		public static function substituteProperty(source:String, obj:Object):String
		{
			if(source == null)
				return '';

			for(var key:String in obj)
			{
				source = source.replace(new RegExp("\\{" + key + "\\}", "gm"), obj[key]);
			}

			return source;
		}
		/**
		 * 去掉文件名中的扩展名
		 * @param $fileName
		 * @return
		 */
		public static function removeExtension(source:String):String
		{
			// Find the location of the period.
			var extensionIndex:int = source.lastIndexOf('.');
			if(extensionIndex == -1)
			{
				// Oops, there is no period. Just return the $fileName.
				return source;
			}
			else
			{
				return source.substr(0, extensionIndex);
			}
		}

		/**
		 * 只取得文件名中的扩展名
		 * @param $fileName
		 * @return
		 */
		public static function getExtension(source:String):String
		{
			// Find the location of the period.
			var extensionIndex:int = source.lastIndexOf('.');
			if(extensionIndex == -1)
			{
				// Oops, there is no period, so return the empty string.
				return null;
			}
			else
			{
				return source.substr(extensionIndex + 1, source.length).toLowerCase();
			}
		}

		/**
		 * 随机字符串(不保证唯一)
		 * @param $length
		 * @return
		 */
		public static function getRandomString(len:uint):String
		{
			var chars:String = "ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678"; // 默认去掉了容易混淆的字符oOLl,9gq,Vv,Uu,I1
			var maxPos:int = chars.length;
			var out:String = "";
			var i:int = len;
			while(i--)
			{
				out += chars.charAt(Math.floor(Math.random() * maxPos));
			}
			return out;
		}

		/**
		 * 字符串是否含有中文
		 *
		 * <listing version="3.0">
		 * trace(StringUtil.containsChinese("き"), StringUtil.containsNonEnglish("き"));
		 * trace(StringUtil.containsChinese("test,.?!%^&*(){}[]"), StringUtil.containsNonEnglish("test,.?!%^&*(){}[]"));
		 * trace(StringUtil.containsChinese("测试"), StringUtil.containsNonEnglish("测试"));
		 * trace(StringUtil.containsChinese("“测试”，。？！%……&*（）——{}【】”"), StringUtil.containsNonEnglish("“测试”，。？！%……&*（）——{}【】”"));
		 * trace(StringUtil.containsChinese("ＡＢab"), StringUtil.containsNonEnglish("ＡＢab"));
		 *
		 * 输出:
		 *
		 * false true
		 * false false
		 * true true
		 * true true
		 * false true
		 * </listing>
		 *
		 * @param $str
		 * @return
		 */
		public static function containsChinese(source:String):Boolean
		{
			var i:uint = 0;
			while(i < source.length)
			{
				var code:Number = source.charCodeAt(i);
				if((code >= 0x4e00) && (code <= 0x9fbb))
				{
					return true;
				}
				i++;
			}
			return false;
		}
		/**
		 * 字符串是否含有非英文字符
		 * @param $str
		 * @return
		 */
		public static function containsNonEnglish(source:String):Boolean
		{
			var i:uint = 0;
			while(i < source.length)
			{
				var code:Number = source.charCodeAt(i);
				if(code > 255 || code < 0)
				{
					return true;
				}
				i++;
			}
			return false;
		}
		public static function getFormattedNumber(value:Number):String
		{
			if(isNaN(value))
				return "NaN";
			if(value == Number.POSITIVE_INFINITY)
				return "Infinity";
			if(value == Number.NEGATIVE_INFINITY)
				return "-Infinity";

			var thousandsSeparator:String = ",";
			var decimalSeparator:String = ".";
			var str:String = value.toString();
			//	convert num to string for formatting
			//  we split it at the decimal point first
			var pieces:Array = str.split('.');
			var before:Array = pieces[0].split('');
			var after:String = pieces[1] != undefined ? pieces[1] : '';

			// add thousands separator			
			var len:int = before.length;
			var before_formatted:Array = [];
			for(var i:uint = 0; i < len; ++i)
			{
				if(i % 3 == 0 && i != 0)
					before_formatted.unshift(thousandsSeparator);
				before_formatted.unshift(before[len - 1 - i]);
			}

			var result:String = before_formatted.join('');
			if(after.length > 0)
				result += decimalSeparator + after;

			return result;
		}
	}
}