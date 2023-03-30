package cn.daftlib.color
{
	public class RGB implements IColor
	{
		private var _r:uint;
		private var _g:uint;
		private var _b:uint;

		public function RGB($r:uint = 0, $g:uint = 0, $b:uint = 0)
		{
			r=$r;
			g=$g;
			b=$b;
		}
		public function get value():uint
		{
			return _r << 16 | _g << 8 | _b;
		}
		public function set value(value:uint):void
		{
			_r = value >> 16;
			_g = (value & 0x00ff00) >> 8;
			_b = value & 0x0000ff;
		}
		public function get r():Number
		{
			return _r;
		}
		public function set r(value:Number):void
		{
			_r = Math.max(0, Math.min(255, value));
		}
		public function get g():Number
		{
			return _g;
		}
		public function set g(value:Number):void
		{
			_g = Math.max(0, Math.min(255, value));
		}
		public function get b():Number
		{
			return _b;
		}
		public function set b(value:Number):void
		{
			_b = Math.max(0, Math.min(255, value));
		}
	}
}