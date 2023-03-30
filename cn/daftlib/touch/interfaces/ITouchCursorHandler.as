package cn.daftlib.touch.interfaces
{
	public interface ITouchCursorHandler
	{
		function set touchEnabled(value:Boolean):void;
		function get touchEnabled():Boolean;
		function get bubbleEnabled():Boolean;
		function addTouchCursor(sessionID:uint):void;
	}
}