package cn.daftlib.color
{

	/**
	 * HSV color
	 *
	 * @example Making the color transition into a continuous loop
	 *
	 *		<listing version="3.0">
	 *			var hsv:HSV=new HSV(0, 0.8, 1);
	 *
	 * 			EnterFrame.addEventListener(Event.ENTER_FRAME, updateColor);
	 *
	 *			function updateColor(e:Event):void
	 * 			{
	 * 				//Update the color smoothly
	 * 				hsv.h += 1;
	 *
	 * 				//Convert RGB to ARGB
	 *				var rgb:uint=ColorUtil.toARGB(hsv.value, .04);
	 * 				this.drawRect(rgb);
	 * 			}
	 *		</listing>
	 *
	 * @author Eric.lin
	 *
	 */
	public final class HSV implements IColor
	{
		private var _h:Number; //Hue
		private var _s:Number; //Saturation
		private var _v:Number; //Brightness
		private var _r:uint;
		private var _g:uint;
		private var _b:uint;

		/**
		 * Initalize a HSV color
		 * @param $h	Hue (degree 360)
		 * @param $s	Saturation [0.0,1.0]
		 * @param $v	Brightness [0.0,1.0]
		 */
		public function HSV($h:Number = 0.0, $s:Number = 1.0, $v:Number = 1.0)
		{
			h = $h;
			s = $s;
			v = $v;
		}

		/**
		 * 24bit Color (0xRRGGBB)
		 */
		public function get value():uint
		{
			updateHSVtoRGB();
			return _r << 16 | _g << 8 | _b;
		}
		public function set value($value:uint):void
		{
			_r = $value >> 16;
			_g = ($value & 0x00ff00) >> 8;
			_b = $value & 0x0000ff;
			updateRGBtoHSV();
		}

		/**
		 * The value of Hue, like a angle in a color wheel( 0~360 ).<br/>
		 * 0 is red, 120 is green、240 is blue.
		 */
		public function get h():Number
		{
			return _h;
		}
		public function set h($value:Number):void
		{
			_h = $value;
		}

		/**
		 * The value of Saturation.<br/>
		 * Between 0.0 ~ 1.0 , Default is 1.
		 */
		public function get s():Number
		{
			return _s;
		}
		public function set s($value:Number):void
		{
			_s = Math.max(0.0, Math.min(1.0, $value));
		}

		/**
		 * The value of Brightness.<br/>
		 * Between 0.0 ~ 1.0 , Default is 1.
		 */
		public function get v():Number
		{
			return _v;
		}
		public function set v($value:Number):void
		{
			_v = Math.max(0.0, Math.min(1.0, $value));
		}

		/**
		 * Convert HSV to RGB
		 * @private
		 */
		private function updateHSVtoRGB():void
		{
			if(_s > 0)
			{
				var h:Number = ((_h < 0) ? _h % 360 + 360 : _h % 360) / 60;
				if(h < 1)
				{
					_r = Math.round(255 * _v);
					_g = Math.round(255 * _v * (1 - _s * (1 - h)));
					_b = Math.round(255 * _v * (1 - _s));
				}
				else if(h < 2)
				{
					_r = Math.round(255 * _v * (1 - _s * (h - 1)));
					_g = Math.round(255 * _v);
					_b = Math.round(255 * _v * (1 - _s));
				}
				else if(h < 3)
				{
					_r = Math.round(255 * _v * (1 - _s));
					_g = Math.round(255 * _v);
					_b = Math.round(255 * _v * (1 - _s * (3 - h)));
				}
				else if(h < 4)
				{
					_r = Math.round(255 * _v * (1 - _s));
					_g = Math.round(255 * _v * (1 - _s * (h - 3)));
					_b = Math.round(255 * _v);
				}
				else if(h < 5)
				{
					_r = Math.round(255 * _v * (1 - _s * (5 - h)));
					_g = Math.round(255 * _v * (1 - _s));
					_b = Math.round(255 * _v);
				}
				else
				{
					_r = Math.round(255 * _v);
					_g = Math.round(255 * _v * (1 - _s));
					_b = Math.round(255 * _v * (1 - _s * (h - 5)));
				}
			}
			else
			{
				_r = _g = _b = Math.round(255 * _v);
			}
		}

		/**
		 * Convert RGB to HSV
		 * @private
		 */
		private function updateRGBtoHSV():void
		{
			if(_r != _g || _r != _b)
			{
				if(_g > _b)
				{
					if(_r > _g)
					{ //r>g>b
						_v = _r / 255;
						_s = (_r - _b) / _r;
						_h = 60 * (_g - _b) / (_r - _b);
					}
					else if(_r < _b)
					{ //g>b>r
						_v = _g / 255;
						_s = (_g - _r) / _g;
						_h = 60 * (_b - _r) / (_g - _r) + 120;
					}
					else
					{ //g=>r=>b
						_v = _g / 255;
						_s = (_g - _b) / _g;
						_h = 60 * (_b - _r) / (_g - _b) + 120;
					}
				}
				else
				{
					if(_r > _b)
					{ // r>b=>g
						_v = _r / 255;
						_s = (_r - _g) / _r;
						_h = 60 * (_g - _b) / (_r - _g);
						if(_h < 0)
							_h += 360;
					}
					else if(_r < _g)
					{ //b=>g>r
						_v = _b / 255;
						_s = (_b - _r) / _b;
						_h = 60 * (_r - _g) / (_b - _r) + 240;
					}
					else
					{ //b=>r=>g
						_v = _b / 255;
						_s = (_b - _g) / _b;
						_h = 60 * (_r - _g) / (_b - _g) + 240;
					}
				}
			}
			else
			{
				_h = _s = 0;
				_v = _r / 255;
			}
		}
	}
}