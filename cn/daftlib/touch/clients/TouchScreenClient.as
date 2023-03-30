package cn.daftlib.touch.clients
{
	import flash.display.Stage;
	import flash.events.TouchEvent;
	
	import cn.daftlib.touch.interfaces.ITouchListener;

	public final class TouchScreenClient
	{
		private var __stage:Stage;
		private var __listerner:ITouchListener;

		public function TouchScreenClient(listerner:ITouchListener, stage:Stage)
		{
			__listerner = listerner;
			__stage = stage;

			__stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
			__stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
			__stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler);
		}
		private function touchBeginHandler(e:TouchEvent):void
		{
			var id:int = e.touchPointID;
			var x:Number = e.stageX;
			var y:Number = e.stageY;
			__listerner.addTouchCursor(id, x, y);
		}
		private function touchMoveHandler(e:TouchEvent):void
		{
			var id:int = e.touchPointID;
			var x:Number = e.stageX;
			var y:Number = e.stageY;
			__listerner.updateTouchCursor(id, x, y);
		}
		private function touchEndHandler(e:TouchEvent):void
		{
			var id:int = e.touchPointID;
			__listerner.removeTouchCursor(id);
		}
	}
}