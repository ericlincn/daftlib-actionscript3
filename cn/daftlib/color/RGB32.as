package cn.daftlib.color
{
	public final class RGB32 extends RGB
	{
		private var _a:int;

		public function RGB32($r:uint = 0, $g:uint = 0, $b:uint = 0, $a:uint = 255)
		{
			super($r, $g, $b);

			_a = $a;
		}
		override public function get value():uint
		{
			return _a << 24 | r << 16 | g << 8 | b;
		}
		override public function set value(value32:uint):void
		{
			_a = value32 >> 24;
			_a = _a < 0 ? (256 + _a) : _a;
			r = value32 >> 16 & 0xff;
			g = value32 >> 8 & 0xff;
			b = value32 & 0xff;
		}
		public function get alpha():uint
		{
			return _a;
		}
		public function set alpha(value:uint):void
		{
			_a = Math.max(0, Math.min(255, value));
		}
	}
}