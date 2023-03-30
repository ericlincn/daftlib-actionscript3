package cn.daftlib.utils
{
	public final class BitUtil
	{
		public static function getBitN(value:int, n:int):int
		{
			return (value >> (n - 1)) & 1;
		}
		public static function setBitN1(value:int, n:int):int
		{
			return value | (1 << (n - 1));
		}
		public static function setBitN0(value:int, n:int):int
		{
			return value & ~(1 << (n - 1));
		}

		/**
		 * 是否符号相反
		 * @param a
		 * @param b
		 * @return 
		 */		
		public static function oppositeSigns(a:int, b:int):Boolean
		{
			return (a ^ b) < 0;
		}
		/**
		 * 是否为奇数
		 * @param value
		 * @return
		 */
		public static function isOdd(value:int):Boolean
		{
			return (value & 1) == 1;
		}

		/**
		 * 取绝对值
		 * @param value
		 * @return
		 */
		public static function abs(value:int):int
		{
			return (value ^ (value >> 31)) - (value >> 31);
		}

		public static function max(a:int, b:int):int
		{
			return a ^ ((a ^ b) & -(a < b ? 1 : 0));
		}
		public static function min(a:int, b:int):int
		{
			return b ^ ((a ^ b) & -(a < b ? 1 : 0));
		}

		/**
		 * 取平均值
		 * @param a
		 * @param b
		 * @return
		 * 如果用 (x+y)/2 求平均值，可能产生溢出
		 */
		public static function average(a:int, b:int):int
		{
			return (a & b) + ((a ^ b) >> 1);
		}

		/**
		 * 是否为2的幂
		 * @param x
		 * @return
		 */
		public static function isPower2(value:int):Boolean
		{
			return ((value & (value - 1)) == 0) && (value != 0);
		}

		/**
		 * 乘法 value * 2
		 * @param value
		 * @return
		 */
		public static function mul2(value:int):int
		{
			return value << 1;
		}

		/**
		 * 除法 value / 2
		 * @param value
		 * @return
		 */
		public static function div2(value:int):int
		{
			return value >> 1;
		}

		/**
		 * 取模 value % 2
		 * @param value
		 * @return
		 */
		public static function mod2(value:int):int
		{
			return value & 1;
		}

		/**
		 * 对2^n取模
		 * @param value
		 * @param power
		 * @return
		 * value % (2^power)
		 */
		public static function mod2exp(value:int, power:int):int
		{
			return value & (2 ^ power - 1);
		}

		/**
		 * 对2^n做乘法
		 * @param value
		 * @param power
		 * @return
		 * value * (2 ^ power)
		 */
		public static function mul2exp(value:int, power:int):int
		{
			return value << power;
		}
		/**
		 * 对2^n做除法
		 * @param value
		 * @param power
		 * @return
		 * value / (2 ^ power)
		 */
		public static function div2exp(value:int, power:int):int
		{
			return value >> power;
		}
	}
}