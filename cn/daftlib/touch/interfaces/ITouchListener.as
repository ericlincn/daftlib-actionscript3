package cn.daftlib.touch.interfaces
{
	public interface ITouchListener
	{
		function addTouchObject(classID:uint, x:Number, y:Number, angle:Number):void;
		function updateTouchObject(classID:uint, x:Number, y:Number, angle:Number):void;
		function removeTouchObject(classID:uint):void;
		function addTouchCursor(sessionID:uint, x:Number, y:Number):void;
		function updateTouchCursor(sessionID:uint, x:Number, y:Number):void;
		function removeTouchCursor(sessionID:uint):void;
	}
}