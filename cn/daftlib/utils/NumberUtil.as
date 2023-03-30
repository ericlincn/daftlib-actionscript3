package cn.daftlib.utils
{
	public final class NumberUtil
	{
		public static function abs(x:Number):Number
		{
			return (x < 0) ? ( -x) : x;
		}
		public static function min(x:Number, y:Number):Number
		{
			return (x < y) ? x : y;
		}
		public static function max(x:Number, y:Number):Number
		{
			return (x > y) ? x : y;
		}
		public static function floor(n:Number):int
		{
			var ni:int = n;
			return (n < 0 && n != ni) ? ni - 1 : ni;
		}
		public static function round(n:Number):int
		{
			return n < 0 ? n + .5 == (n | 0) ? n : n - .5 : n + .5;
		}
		public static function ceil(n:Number):int
		{
			var ni:int = n;
			return (n >= 0 && n != ni) ? ni + 1 : ni;
		}
		/**
		 * 得到唯一数
		 * @return
		 */
		public static function getUnique():Number
		{
			var date:Date = new Date();

			return date.getTime();
		}

		/**
		 * 取得小数部分
		 * @param $value
		 * @return
		 */
		public static function getDecimal(value:Number):Number
		{
			if(value < 1)
				return value;
			var arr:Array = String(value).split(".");
			if(arr[1])
				return Number("0." + arr[1]);
			return 0;
		}

		/**
		 * 将目标数值限定于某个范围内，大于最大值等于最大值，小于最小值等于最小值
		 * @param $value
		 * @param $min
		 * @param $max
		 * @return
		 */
		public static function clamp(value:Number, min:Number, max:Number):Number
		{
			return NumberUtil.min(max, NumberUtil.max(value, min));
		}
		
		/**
		 * 取得百分比
		 * @param $value
		 * @param $min
		 * @param $max
		 * @return
		 */
		public static function getPercent(value:Number, min:Number, max:Number):Number
		{
			return (value - min) / (max - min);
		}

		/**
		 * 按位数取得小数
		 * @param value
		 * @param place
		 * @return
		 * @example
		 * 		<code>
		 * 			trace(NumberUtil.roundDecimalToPlace(3.14159, 2)); // Traces 3.14
		 * 			trace(NumberUtil.roundDecimalToPlace(3.14159, 3)); // Traces 3.142
		 * 		</code>
		 */
		public static function roundDecimalToPlace(value:Number, place:uint):Number
		{
			var p:Number = Math.pow(10, place);

			return NumberUtil.round(value * p) / p;
		}

		/**
		 * 在某个范围内取随机数
		 * @param $min
		 * @param $max
		 * @return
		 */
		public static function randomInRange(min:Number, max:Number):Number
		{
			return min + (Math.random() * (max - min));
		}
		/**
		 * 随机布尔值
		 * @return
		 */
		public static function randomBoolean():Boolean
		{
			return Math.random() < 0.5;
		}
		/**
		 * 随机正负数
		 * @return
		 */
		public static function randomWave():int
		{
			return NumberUtil.floor(Math.random() * 2) * 2 - 1;
		}
		/**
		 * 提取正负号
		 * @param $value
		 * @return
		 */
		public static function extractPlusMinus(value:Number):int
		{
			return int(value / NumberUtil.abs(value));
		}
	}
}