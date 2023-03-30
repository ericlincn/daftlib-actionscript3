package cn.daftlib.utils
{
	public final class TimeUtil
	{
		public static const MONTHS_EN:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		public static const DAYS_EN:Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		public static const MONTHS_CN:Array = ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"];
		public static const DAYS_CN:Array = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];

		/**
		 * Parses W3CDTF Time stamps eg 1994-11-05T13:15:30Z, 1997-07-16T19:20:30.45+01:00
		 * @param $str
		 * @return
		 */
		public static function parseW3CDTF(source:String):Date
		{
			var ignoreTimezone:Boolean = false;
			var finalDate:Date = null;
			try
			{
				var dateStr:String = source.substring(0, source.indexOf("T"));
				var timeStr:String = source.substring(source.indexOf("T") + 1, source.length);
				var dateArr:Array = dateStr.split("-");
				var year:int = int(dateArr.shift());
				var month:int = int(dateArr.shift());
				var date:int = int(dateArr.shift());

				var multiplier:int;
				var offsetHours:int;
				var offsetMinutes:int;
				var offsetStr:String;

				if(timeStr.indexOf("Z") != -1 || ignoreTimezone == true)
				{
					multiplier = 1;
					offsetHours = 0;
					offsetMinutes = 0;
					timeStr = timeStr.replace("Z", "");
				}
				else if(timeStr.indexOf("+") != -1)
				{
					multiplier = 1;
					offsetStr = timeStr.substring(timeStr.indexOf("+") + 1, timeStr.length);
					offsetHours = int(offsetStr.substring(0, offsetStr.indexOf(":")));
					offsetMinutes = int(offsetStr.substring(offsetStr.indexOf(":") + 1, offsetStr.length));
					timeStr = timeStr.substring(0, timeStr.indexOf("+"));
				}
				else
				{ // offset is -
					multiplier = -1;
					offsetStr = timeStr.substring(timeStr.indexOf("-") + 1, timeStr.length);
					offsetHours = int(offsetStr.substring(0, offsetStr.indexOf(":")));
					offsetMinutes = int(offsetStr.substring(offsetStr.indexOf(":") + 1, offsetStr.length));
					timeStr = timeStr.substring(0, timeStr.indexOf("-"));
				}
				var timeArr:Array = timeStr.split(":");
				var hour:int = int(timeArr.shift());
				var minutes:int = int(timeArr.shift());
				var secondsArr:Array = (timeArr.length > 0) ? String(timeArr.shift()).split(".") : null;
				var seconds:int = (secondsArr != null && secondsArr.length > 0) ? int(secondsArr.shift()) : 0;
				var milliseconds:int = (secondsArr != null && secondsArr.length > 0) ? int(secondsArr.shift()) : 0;

				if(ignoreTimezone == true)
				{
					finalDate = new Date(year, month - 1, date, hour, minutes, seconds, milliseconds);
				}
				else
				{
					var utc:Number = Date.UTC(year, month - 1, date, hour, minutes, seconds, milliseconds);
					var offset:Number = (((offsetHours * 3600000) + (offsetMinutes * 60000)) * multiplier);
					finalDate = new Date(utc - offset);
				}
				if(finalDate.toString() == "Invalid Date")
				{
					throw new Error("This date does not conform to W3CDTF.");
				}
			}
			catch(e:Error)
			{
				var eStr:String = "Unable to parse the string [" + source + "] into a date. ";
				eStr += "The internal error was: " + e.toString();
				trace('[TimeUtil] ' + eStr);
			}
			return finalDate;
		}

		/**
		 * Basic date formatting function
		 *
		 * getFormattedDate(date); // "Saturday, September 15, 2008 9:00pm"
		 * getFormattedDate(date, false, false, false); // "September 2009"
		 */
		public static function getFormattedDateEN(date:Date):String
		{
			var s:String = "";
			s += DAYS_EN[date.day] + ", ";
			s += MONTHS_EN[date.month] + " ";
			s += date.date + ", ";
			s += date.fullYear;
			s += " " + getShortHour(date) + ":" + (date.minutes < 10 ? "0" : "") + date.minutes + getAMPM(date);
			return s;
		}
		public static function getFormattedDateCN(date:Date):String
		{
			var s:String = "";
			s += number2Chinese(date.fullYear) + "年, ";
			s += MONTHS_CN[date.month];
			s += number2Chinese(date.date) + "日, ";
			s += DAYS_CN[date.day] + ", ";
			s += (getAMPM(date) == "pm" ? "下午" : "上午") + number2Chinese(getShortHour(date)) + "点" + number2Chinese(date.minutes);
			return s;
		}

		/**
		 * Returns AM or PM for a given date
		 */
		public static function getAMPM(date:Date):String
		{
			return (date.hours > 11) ? "pm" : "am";
		}

		/**
		 * 将毫秒以 00:00:00 或 00:00 的形式格式化
		 * @param $ms
		 * @return
		 */
		public static function getClockTime(ms:uint, showHour:Boolean = true):String
		{
			var time:Date = new Date(ms);
			var hours:int = time.getUTCHours();
			var minutes:int = time.getUTCMinutes();
			var seconds:int = time.getUTCSeconds();
			var timeStr:String;

			if(showHour == true)
				timeStr = fixNumber(hours) + ":" + fixNumber(minutes) + ":" + fixNumber(seconds);
			else
				timeStr = fixNumber(minutes) + ":" + fixNumber(seconds);

			return timeStr;
		}

		/**
		 * Convert framerate to time in ms, usually used for Timer class
		 * @param $frameRate
		 * @return
		 */
		public static function frameRateToTime(frameRate:uint):uint
		{
			return uint(1000 / frameRate);
		}

		/**
		 * 给不足2位的数字补0
		 * @param $num
		 * @return
		 */
		private static function fixNumber(num:int):String
		{
			var addzero:String = String(num + 100).substr(1, 2);
			return addzero;
		}
		private static function getShortHour(date:Date):int
		{
			var h:int = date.hours;
			if(h == 0 || h == 12)
				return 12;
			else if(h > 12)
				return h - 12;
			else
				return h;
		}
		private static function number2Chinese(num:uint):String
		{
			const arr:Array = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];

			var str:String = String(num);

			if(num > 1000)
				return arr[uint(str.charAt(0))] + arr[uint(str.charAt(1))] + arr[uint(str.charAt(2))] + arr[uint(str.charAt(3))];
			if(num < 10)
				return arr[num];
			if(num < 100)
				return (uint(num / 10) > 1 ? arr[uint(num / 10)] : "十") + (num % 10 ? arr[num % 10] : "十");
			return null;
		}
	}
}