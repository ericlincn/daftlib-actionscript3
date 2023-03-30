package cn.daftlib.touch.vo
{
	public final class TouchObject
	{
		private var __classID:uint;
		private var __x:Number;
		private var __y:Number;
		private var __a:Number;

		/**
		 * TouchObject is holded by DaftTouch & PatternSprite
		 * @param $classID
		 * @param $x
		 * @param $y
		 * @param $angle
		 */
		public function TouchObject(_classID:uint, _x:Number, _y:Number, _angle:Number)
		{
			__classID = _classID;

			update(_x, _y, _angle);
		}
		public function update(_x:Number, _y:Number, _angle:Number):void
		{
			__x = _x;
			__y = _y;
			__a = _angle;
		}
		public function get classID():uint
		{
			return __classID;
		}
		public function get x():Number
		{
			return __x;
		}
		public function get y():Number
		{
			return __y;
		}
		public function get angle():Number
		{
			return __a;
		}
		public function toString():String
		{
			var out:String = "";
			out += "TouchObject(";
			out += "classID: " + __classID;
			out += ", x: " + __x;
			out += ", y: " + __y;
			out += ", angle: " + __a;
			out += ")";

			return out;
		}
	}
}