package cn.daftlib.touch.clients
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import cn.daftlib.touch.interfaces.ITouchListener;

	public final class MouseClient
	{
		private var __stage:Stage;
		private var __listerner:ITouchListener;

		public function MouseClient(listerner:ITouchListener, stage:Stage)
		{
			__listerner = listerner;
			__stage = stage;

			__stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		private function mouseDownHandler(e:MouseEvent):void
		{
			__stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			__stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

			__listerner.addTouchCursor(0, e.stageX, e.stageY);
		}
		private function mouseMoveHandler(e:MouseEvent):void
		{
			__listerner.updateTouchCursor(0, e.stageX, e.stageY);
		}
		private function mouseUpHandler(e:MouseEvent):void
		{
			__stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			__stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

			__listerner.removeTouchCursor(0);
		}
	}
}