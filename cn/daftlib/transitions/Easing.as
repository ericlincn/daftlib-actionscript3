/*
TERMS OF USE - EASING EQUATIONS
---------------------------------------------------------------------------------
Open source under the BSD License.

Copyright © 2001 Robert Penner All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer. Redistributions in binary
form must reproduce the above copyright notice, this list of conditions and
the following disclaimer in the documentation and/or other materials provided
with the distribution. Neither the name of the author nor the names of
contributors may be used to endorse or promote products derived from this
software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------------
*/

package cn.daftlib.transitions
{
	public final class Easing
	{
		private static const PI:Number = 3.141592653589793;
		private static const PI_M2:Number = PI * 2;
		private static const PI_D2:Number = PI / 2;

		/*
		Linear
		---------------------------------------------------------------------------------
		*/
		public static function linearEaseNone(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * t / d + b;
		}

		/*
		Sine
		---------------------------------------------------------------------------------
		*/
		public static function sineEaseIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * Math.cos(t / d * PI_D2) + c + b;
		}
		public static function sineEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * Math.sin(t / d * PI_D2) + b;
		}
		public static function sineEaseInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c / 2 * (Math.cos(PI * t / d) - 1) + b;
		}

		/*
		Quintic
		---------------------------------------------------------------------------------
		*/
		public static function quintEaseIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * (t /= d) * t * t * t * t + b;
		}
		public static function quintEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
		}
		public static function quintEaseInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if((t /= d / 2) < 1)
				return c / 2 * t * t * t * t * t + b;
			return c / 2 * ((t -= 2) * t * t * t * t + 2) + b;
		}

		/*
		Quartic
		---------------------------------------------------------------------------------
		*/
		public static function quartEaseIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * (t /= d) * t * t * t + b;
		}
		public static function quartEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * ((t = t / d - 1) * t * t * t - 1) + b;
		}
		public static function quartEaseInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if((t /= d / 2) < 1)
				return c / 2 * t * t * t * t + b;
			return -c / 2 * ((t -= 2) * t * t * t - 2) + b;
		}

		/*
		Quadratic
		---------------------------------------------------------------------------------
		*/
		public static function quadEaseIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * (t /= d) * t + b;
		}
		public static function quadEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * (t /= d) * (t - 2) + b;
		}
		public static function quadEaseInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if((t /= d / 2) < 1)
				return c / 2 * t * t + b;
			return -c / 2 * ((--t) * (t - 2) - 1) + b;
		}

		/*
		Exponential
		---------------------------------------------------------------------------------
		*/
		public static function expoEaseIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return (t == 0) ? b : c * Math.pow(2, 10 * (t / d - 1)) + b;
		}
		public static function expoEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return (t == d) ? b + c : c * (-Math.pow(2, -10 * t / d) + 1) + b;
		}
		public static function expoEaseInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if(t == 0)
				return b;
			if(t == d)
				return b + c;
			if((t /= d / 2) < 1)
				return c / 2 * Math.pow(2, 10 * (t - 1)) + b;
			return c / 2 * (-Math.pow(2, -10 * --t) + 2) + b;
		}

		/*
		Elastic
		---------------------------------------------------------------------------------
		*/
		public static function elasticEaseIn(t:Number, b:Number, c:Number, d:Number, a:Number = undefined, p:Number = undefined):Number
		{
			var s:Number;
			if(t == 0)
				return b;
			if((t /= d) == 1)
				return b + c;
			if(!p)
				p = d * .3;
			if(!a || a < Math.abs(c))
			{
				a = c;
				s = p / 4;
			}
			else
				s = p / PI_M2 * Math.asin(c / a);
			return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * PI_M2 / p)) + b;
		}
		public static function elasticEaseOut(t:Number, b:Number, c:Number, d:Number, a:Number = undefined, p:Number = undefined):Number
		{
			var s:Number;
			if(t == 0)
				return b;
			if((t /= d) == 1)
				return b + c;
			if(!p)
				p = d * .3;
			if(!a || a < Math.abs(c))
			{
				a = c;
				s = p / 4;
			}
			else
				s = p / PI_M2 * Math.asin(c / a);
			return (a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * PI_M2 / p) + c + b);
		}
		public static function elasticEaseInOut(t:Number, b:Number, c:Number, d:Number, a:Number = undefined, p:Number = undefined):Number
		{
			var s:Number;
			if(t == 0)
				return b;
			if((t /= d / 2) == 2)
				return b + c;
			if(!p)
				p = d * (.3 * 1.5);
			if(!a || a < Math.abs(c))
			{
				a = c;
				s = p / 4;
			}
			else
				s = p / PI_M2 * Math.asin(c / a);
			if(t < 1)
				return -.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * PI_M2 / p)) + b;
			return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t * d - s) * PI_M2 / p) * .5 + c + b;
		}

		/*
		Circular
		---------------------------------------------------------------------------------
		*/
		public static function circularEaseIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * (Math.sqrt(1 - (t /= d) * t) - 1) + b;
		}
		public static function circularEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * Math.sqrt(1 - (t = t / d - 1) * t) + b;
		}
		public static function circularEaseInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if((t /= d / 2) < 1)
				return -c / 2 * (Math.sqrt(1 - t * t) - 1) + b;
			return c / 2 * (Math.sqrt(1 - (t -= 2) * t) + 1) + b;
		}

		/*
		Back
		---------------------------------------------------------------------------------
		*/
		public static function backEaseIn(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
		{
			return c * (t /= d) * t * ((s + 1) * t - s) + b;
		}
		public static function backEaseOut(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
		{
			return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
		}
		public static function backEaseInOut(t:Number, b:Number, c:Number, d:Number, s:Number = 1.70158):Number
		{
			if((t /= d / 2) < 1)
				return c / 2 * (t * t * (((s *= (1.525)) + 1) * t - s)) + b;
			return c / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2) + b;
		}

		/*
		Bounce
		---------------------------------------------------------------------------------
		*/
		public static function bounceEaseIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c - bounceEaseOut(d - t, 0, c, d) + b;
		}
		public static function bounceEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if((t /= d) < (1 / 2.75))
			{
				return c * (7.5625 * t * t) + b;
			}
			else if(t < (2 / 2.75))
			{
				return c * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + b;
			}
			else if(t < (2.5 / 2.75))
			{
				return c * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + b;
			}
			else
			{
				return c * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + b;
			}
		}
		public static function bounceEaseInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if(t < d / 2)
				return bounceEaseIn(t * 2, 0, c, d) * .5 + b;
			else
				return bounceEaseOut(t * 2 - d, 0, c, d) * .5 + c * .5 + b;
		}

		/*
		Cubic
		---------------------------------------------------------------------------------
		*/
		public static function cubicEaseIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * (t /= d) * t * t + b;
		}
		public static function cubicEaseOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * ((t = t / d - 1) * t * t + 1) + b;
		}
		public static function cubicEaseInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if((t /= d / 2) < 1)
				return c / 2 * t * t * t + b;
			return c / 2 * ((t -= 2) * t * t + 2) + b;
		}
	}
}