package cn.daftlib.color
{
	public final class HSL implements IColor
	{
		private var _h:Number; //Hue
		private var _s:Number; //Saturation
		private var _l:Number; //Lightness
		private var _r:uint;
		private var _g:uint;
		private var _b:uint;

		/**
		 * Initalize a HSL color
		 * @param $h	Hue (degree 360)
		 * @param $s	Saturation [0.0,1.0]
		 * @param $l	Lightness [0.0,1.0]
		 */
		public function HSL($h:Number = 0.0, $s:Number = 1.0, $l:Number = 0.5)
		{
			h = $h;
			s = $s;
			l = $l;
		}
		public function get value():uint
		{
			updateHSLtoRGB();
			return _r << 16 | _g << 8 | _b;
		}
		public function set value(value:uint):void
		{
			_r = value >> 16;
			_g = (value & 0x00ff00) >> 8;
			_b = value & 0x0000ff;
			updateRGBtoHSL();
		}

		/**
		 * The value of Hue, like a angle in a color wheel( 0~360 ).<br/>
		 * 0 is red, 120 is green、240 is blue.
		 */
		public function get h():Number
		{
			return _h;
		}
		public function set h(value:Number):void
		{
			_h = value;
		}

		/**
		 * The value of Saturation.<br/>
		 * Between 0.0 ~ 1.0 , Default is 1.
		 */
		public function get s():Number
		{
			return _s;
		}
		public function set s(value:Number):void
		{
			_s = Math.max(0.0, Math.min(1.0, value));
		}

		/**
		 * The value of Lightness.<br/>
		 * Between 0.0 ~ 1.0 , Default is 1.
		 */
		public function get l():Number
		{
			return _l;
		}
		public function set l(value:Number):void
		{
			_l = Math.max(0.0, Math.min(1.0, value));
		}

		/**
		 * Convert HSL to RGB
		 * @private
		 */
		private function updateHSLtoRGB():void
		{
			if(_s > 0)
			{
				var v:Number = (_l <= 0.5) ? _l + _s * _l : _l + _s * (1 - _l);
				var p:Number = 2.0 * _l - v;
				var h:Number = ((_h < 0) ? _h % 360 + 360 : _h % 360) / 60;
				if(h < 1)
				{
					_r = Math.round(255 * v);
					_g = Math.round(255 * (p + (v - p) * h));
					_b = Math.round(255 * p);
				}
				else if(h < 2)
				{
					_r = Math.round(255 * (p + (v - p) * (2 - h)));
					_g = Math.round(255 * v);
					_b = Math.round(255 * p);
				}
				else if(h < 3)
				{
					_r = Math.round(255 * p);
					_g = Math.round(255 * v);
					_b = Math.round(255 * (p + (v - p) * (h - 2)));
				}
				else if(h < 4)
				{
					_r = Math.round(255 * p);
					_g = Math.round(255 * (p + (v - p) * (4 - h)));
					_b = Math.round(255 * v);
				}
				else if(h < 5)
				{
					_r = Math.round(255 * (p + (v - p) * (h - 4)));
					_g = Math.round(255 * p);
					_b = Math.round(255 * v);
				}
				else
				{
					_r = Math.round(255 * v);
					_g = Math.round(255 * p);
					_b = Math.round(255 * (p + (v - p) * (6 - h)));
				}
			}
			else
			{
				_r = _g = _b = Math.round(255 * _l);
			}
		}

		/**
		 * Convert RGB to HSL
		 * @private
		 */
		private function updateRGBtoHSL():void
		{
			if(_r != _g || _r != _b)
			{
				if(_g > _b)
				{
					if(_r > _g)
					{ //r>g>b
						_l = (_r + _b);
						_s = (_l > 255) ? (_r - _b) / (510 - _l) : (_r - _b) / _l;
						_h = 60 * (_g - _b) / (_r - _b);
					}
					else if(_r < _b)
					{ //g>b>r
						_l = (_g + _r);
						_s = (_l > 255) ? (_g - _r) / (510 - _l) : (_g - _r) / _l;
						_h = 60 * (_b - _r) / (_g - _r) + 120;
					}
					else
					{ //g=>r=>b
						_l = (_g + _b);
						_s = (_l > 255) ? (_g - _b) / (510 - _l) : (_g - _b) / _l;
						_h = 60 * (_b - _r) / (_g - _b) + 120;
					}
				}
				else
				{
					if(_r > _b)
					{ // r>b=>g
						_l = (_r + _g);
						_s = (_l > 255) ? (_r - _g) / (510 - _l) : (_r - _g) / _l;
						_h = 60 * (_g - _b) / (_r - _g);
						if(_h < 0)
							_h += 360;
					}
					else if(_r < _g)
					{ //b=>g>r
						_l = (_b + _r);
						_s = (_l > 255) ? (_b - _r) / (510 - _l) : (_b - _r) / _l;
						_h = 60 * (_r - _g) / (_b - _r) + 240;
					}
					else
					{ //b=>r=>g
						_l = (_b + _g);
						_s = (_l > 255) ? (_b - _g) / (510 - _l) : (_b - _g) / _l;
						_h = 60 * (_r - _g) / (_b - _g) + 240;
					}
				}
				_l /= 510;
			}
			else
			{
				_h = _s = 0;
				_l = _r / 255;
			}
		}
	}
}