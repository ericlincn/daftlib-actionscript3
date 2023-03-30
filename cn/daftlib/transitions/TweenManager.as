package cn.daftlib.transitions
{
	import flash.utils.Dictionary;

	/**
	 * Using the TweenManager to create an animated transition processing
	 *
	 * @example Transition a sprite to 500, and delay 0.3 seconds
	 *
	 *		<listing version="3.0">
	 *			TweenManager.to(sprite, .5, {x:600, delay:.3, onComplete:finished, onCompleteParams:[p1,p2]});
	 *
	 * 			//Destroy the unfinished Tween
	 * 			TweenManager.removeTweenForTarget(sprite);
	 *		</listing>
	 *
	 * @author Eric.lin
	 */
	public final class TweenManager
	{
		private static var __tweenMap:Dictionary = new Dictionary(true);

		public static function to(target:Object, duration:Number, vars:Object, ease:Function = null):void
		{
			var oldTween:Tween = __tweenMap[target];
			var newTween:Tween = new Tween(target, duration, vars, ease);

			if(oldTween != null)
			{
				oldTween.destroy();
				oldTween = null;
				delete __tweenMap[target];
			}

			newTween.start();
			__tweenMap[target] = newTween;

			//return newTween;
		}
		public static function from(target:Object, duration:Number, vars:Object, ease:Function = null):void
		{
			var oldTween:Tween = __tweenMap[target];
			var newTween:Tween = new Tween(target, duration, vars, ease, true);

			if(oldTween != null)
			{
				oldTween.destroy();
				oldTween = null;
				delete __tweenMap[target];
			}

			newTween.start();
			__tweenMap[target] = newTween;

			//return newTween;
		}
		public static function delayCall(delay:Number, func:Function, funcParams:Array = null):void
		{
			var oldTween:Tween = __tweenMap[func];
			var newTween:Tween = new Tween(func, 0, {delay:delay, onComplete:func, onCompleteParams:funcParams}, null);

			if(oldTween != null)
			{
				oldTween.destroy();
				oldTween = null;
				delete __tweenMap[func];
			}

			newTween.start();
			__tweenMap[func] = newTween;

			//return newTween;
		}

		public static function removeTweenForTarget(target:Object):void
		{
			var oldTween:Tween = __tweenMap[target];

			if(oldTween != null)
			{
				oldTween.destroy();
				oldTween = null;
				delete __tweenMap[target];
			}
		}
		public static function removeDelayCallForMethod(func:Function):void
		{
			removeTweenForTarget(func);
		}
		public static function removeAllTween():void
		{
			for(var key:* in __tweenMap)
			{
				//if(key)
				removeTweenForTarget(key);
			}
			__tweenMap = new Dictionary(true);
		}
	}
}