package cn.daftlib.touch.vo
{
	public final class TouchCursor
	{
		private var __sessionID:uint;
		private var __x:Number;
		private var __y:Number;
		
		private var __startX:Number;
		private var __startY:Number;
		private var __speedX:Number = 0;
		private var __speedY:Number = 0;
		
		/**
		 * TouchCursor is holded by DaftTouch & TouchSprite
		 * @param $sessionID
		 * @param $x
		 * @param $y
		 */
		public function TouchCursor(_sessionID:uint, _x:Number, _y:Number)
		{
			__sessionID = _sessionID;
			__startX = _x;
			__startY = _y;
			__x = _x;
			__y = _y;
		}
		public function get sessionID():uint
		{
			return __sessionID;
		}
		public function get x():Number
		{
			return __x;
		}
		public function get y():Number
		{
			return __y;
		}
		public function get startX():Number
		{
			return __startX;
		}
		public function get startY():Number
		{
			return __startY;
		}
		public function get offsetX():Number
		{
			return __x - __startX;
		}
		public function get offsetY():Number
		{
			return __y - __startY;
		}
		public function get speedX():Number
		{
			return __speedX;
		}
		public function get speedY():Number
		{
			return __speedY;
		}
		public function update(_x:Number, _y:Number):void
		{
			__speedX = _x - __x;
			__speedY = _y - __y;
			
			__x = _x;
			__y = _y;
		}
		public function toString():String
		{
			var out:String = "";
			out += "TouchCursor(";
			out += "sessionID: " + __sessionID;
			out += ", x: " + __x;
			out += ", y: " + __y;
			out += ")";
			
			return out;
		}
	}
}