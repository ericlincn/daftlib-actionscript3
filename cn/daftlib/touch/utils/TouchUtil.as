package cn.daftlib.touch.utils
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;

	import cn.daftlib.touch.interfaces.ITouchCursorHandler;

	public final class TouchUtil
	{
		public static function getDeepestTouchSpriteUnderPoint(point:Point, stage:Stage):ITouchCursorHandler
		{
			var doTargets:Array = stage.getObjectsUnderPoint(point);
			var touchTargets:Array = [];

			var i:uint = 0;
			while(i < doTargets.length)
			{
				var parentTS:ITouchCursorHandler = getFirstEnabledParentTouchSprite(doTargets[i]);

				if(doTargets[i] is ITouchCursorHandler)
				{
					var pushed:Boolean = pushEnabledTarget(doTargets[i], touchTargets);

					if(pushed == false)
					{
						pushEnabledTarget(parentTS, touchTargets);
					}
				}
				else if(parentTS != null)
				{
					pushEnabledTarget(parentTS, touchTargets);
				}

				i++;
			}

			var item:ITouchCursorHandler = null;
			//trace("touchTargets", touchTargets)
			if(touchTargets.length > 0)
				item = touchTargets[touchTargets.length - 1];

			/*if(touchTargets.length > 0)
				item = touchTargets[0];*/

			return item;
		}
		private static function pushEnabledTarget(target:ITouchCursorHandler, arr:Array):Boolean
		{
			if(target == null)
				return false;

			if(target.touchEnabled == true)
			{
				if(arr.indexOf(target) < 0)
				{
					arr.push(target);

					return true;
				}
			}

			return false;
		}
		public static function getFirstEnabledParentTouchSprite(displayObject:DisplayObject):ITouchCursorHandler
		{
			var ts:ITouchCursorHandler = null;

			if(displayObject.parent != null)
			{
				if(displayObject.parent is ITouchCursorHandler)
				{
					if(ITouchCursorHandler(displayObject.parent).touchEnabled == true)
						ts = displayObject.parent as ITouchCursorHandler;
				}

				if(ts == null)
				{
					ts = getFirstEnabledParentTouchSprite(displayObject.parent);
				}
			}

			return ts;
		}
		/*public static function getFirstParentTouchSprite($do:DisplayObject):ITouchCursorHolder
		{
			var ts:ITouchCursorHolder = null;

			if($do.parent != null)
			{
				if($do.parent is ITouchCursorHolder)
				{
					ts = $do.parent as ITouchCursorHolder;
				}
				else
				{
					ts = getFirstParentTouchSprite($do.parent);
				}
			}

			return ts;
		}*/
		private static var GRAD_PI:Number = 180 / Math.PI;

		public static function getAngleTrig(vx:Number, vy:Number):Number
		{
			if(vx == 0.0)
			{
				if(vy < 0.0)
					return 270;
				else
					return 90;
			}
			else if(vy == 0)
			{
				if(vx < 0)
					return 180;
				else
					return 0;
			}

			if(vy > 0.0)
				if(vx > 0.0)
					return Math.atan(vy / vx) * GRAD_PI;
				else
					return 180.0 - Math.atan(vy / -vx) * GRAD_PI;
			else if(vx > 0.0)
				return 360.0 - Math.atan(-vy / vx) * GRAD_PI;
			else
				return 180.0 + Math.atan(-vy / -vx) * GRAD_PI;
		}
	}
}