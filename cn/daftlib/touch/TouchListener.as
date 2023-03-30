package cn.daftlib.touch
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import cn.daftlib.touch.interfaces.ITouchCursorHandler;
	import cn.daftlib.touch.interfaces.ITouchListener;
	import cn.daftlib.touch.utils.TouchUtil;
	import cn.daftlib.touch.vo.TouchCursor;
	import cn.daftlib.touch.vo.TouchObject;
	
	public final class TouchListener implements ITouchListener
	{
		private var __stage:Stage;
		
		private static var __touchCursorMap:Dictionary = new Dictionary();
		private static var __touchObjectMap:Dictionary = new Dictionary();
		
		public function TouchListener(stage:Stage)
		{
			__stage=stage;
		}
		public static function getTouchCursor(sessionID:uint):TouchCursor
		{
			if(__touchCursorMap[sessionID] != undefined)
			{
				return __touchCursorMap[sessionID];
			}
			return null;
		}
		
		public function addTouchObject(classID:uint, x:Number, y:Number, angle:Number):void
		{
			//Profiler.log("add: "+touchObject);
			__touchObjectMap[classID] = new TouchObject(classID, x, y, angle);
		}
		public function updateTouchObject(classID:uint, x:Number, y:Number, angle:Number):void
		{
			//Profiler.log("update: "+touchObject);
			if(__touchObjectMap[classID] != undefined)
			{
				var to:TouchObject = __touchObjectMap[classID];
				to.update(x, y, angle);
			}
		}
		public function removeTouchObject(classID:uint):void
		{
			//Profiler.log("remove: "+touchObject);
			if(__touchObjectMap[classID] != undefined)
			{
				delete __touchObjectMap[classID];
			}
		}
		
		public function addTouchCursor(sessionID:uint, x:Number, y:Number):void
		{
			//Profiler.log("add: "+touchCursor);
			if(__touchCursorMap[sessionID] != undefined) return;
			
			__touchCursorMap[sessionID] = new TouchCursor(sessionID, x, y);
			
			var target:ITouchCursorHandler = TouchUtil.getDeepestTouchSpriteUnderPoint(new Point(x, y), __stage);
			
			if(target != null)
			{
				addTouchCursorToHolder(target, sessionID);
			}
		}
		public function updateTouchCursor(sessionID:uint, x:Number, y:Number):void
		{
			//Profiler.log("update: "+touchCursor);
			if(__touchCursorMap[sessionID] != undefined)
			{
				var tc:TouchCursor = __touchCursorMap[sessionID];
				tc.update(x, y);
			}
		}
		public function removeTouchCursor(sessionID:uint):void
		{
			//Profiler.log("remove: "+touchCursor);
			if(__touchCursorMap[sessionID] != undefined)
			{
				delete __touchCursorMap[sessionID];
			}
		}
		private function addTouchCursorToHolder(target:ITouchCursorHandler, sessionID:uint):void
		{
			target.addTouchCursor(sessionID);
			
			if(target.bubbleEnabled == true)
			{
				var parentTouchSprite:ITouchCursorHandler = TouchUtil.getFirstEnabledParentTouchSprite(target as DisplayObject);
				if(parentTouchSprite != null)
				{
					addTouchCursorToHolder(parentTouchSprite, sessionID);
				}
			}
		}
	}
}