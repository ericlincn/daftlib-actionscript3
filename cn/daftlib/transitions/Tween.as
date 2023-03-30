package cn.daftlib.transitions
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import cn.daftlib.time.EnterFrame;

	/**
	 * Used by TweenManager.
	 * Generally, using the TweenManager instead of using Tween directly.
	 *
	 * @example Destroy a Tween immediately
	 *
	 *		<listing version="3.0">
	 *			var t:Tween=TweenManager.go(sprite, .5, {x:600});
	 * 			t.destroy();
	 *		</listing>
	 *
	 * @author Eric.lin
	 */

	public final class Tween
	{
		private var __target:Object;
		private var __duration:Number;
		private var __vars:Object;
		private var __ease:Function;
		private var __delay:Number;
		private var __reverse:Boolean;

		private var __tweenInfoArr:Array = [];
		private var __startTime:Number = NaN;

		private var __onComplete:Function;
		private var __onCompleteParams:Array;
		private var __onUpdate:Function;
		private var __onUpdateParams:Array;

		public function Tween(target:Object, duration:Number, vars:Object, ease:Function, reverse:Boolean = false)
		{
			__target = target;
			// Easing equations don't work when the duration is zero.
			__duration = duration || 0.001;
			__duration = Math.max(0.001, duration) * 1000;
			__vars = vars;
			__delay = vars.delay || 0;
			__delay = Math.max(0, __delay) * 1000;
			__reverse = reverse;

			__onComplete = vars.onComplete || null;
			__onCompleteParams = vars.onCompleteParams || null;

			__onUpdate = vars.onUpdate || null;
			__onUpdateParams = vars.onUpdateParams || null;

			if(ease == null)
				__ease = easeOut;
			else
				__ease = ease;

			initTweenInfo();
		}
		internal function start():void
		{
			EnterFrame.addEventListener(render);
		}
		internal function destroy():void
		{
			EnterFrame.removeEventListener(render);

			__target = null;
			__vars = null;
			__ease = null;
			__tweenInfoArr = null;

			__onComplete = null;
			__onCompleteParams = null;

			__onUpdate = null;
			__onUpdateParams = null;
		}

		private function initTweenInfo():void
		{
			for(var property:String in __vars)
			{
				//check property is invaild
				if(__target.hasOwnProperty(property) == true)
				{
					__tweenInfoArr.push(new TweenInfo(__target, property, __target[property], __vars[property] - __target[property]));
				}
			}

			if(__reverse == true)
			{
				var i:int = __tweenInfoArr.length;
				while(i--)
				{
					var ti:TweenInfo = __tweenInfoArr[i];
					ti.start += ti.change;
					ti.change *= -1;

					//render at beginning, because __duration is always forced to be at least 0.001 since easing equations can't handle zero.
					ti.target[ti.property] = ti.start;
				}
			}
		}
		private function render(e:Event):void
		{
			//for destroy fix
			if(__tweenInfoArr == null)
				return;

			//time related
			if(isNaN(__startTime))
				__startTime = getTimer() + __delay;
			var currentTime:Number = getTimer() - __startTime;

			//calculate factor
			var factor:Number = 1;
			if(currentTime < 0)
			{
				//for delay
				factor = 0;
			}
			else if(currentTime >= __duration)
			{
				//for complete
				currentTime = __duration;
			}
			else
			{
				factor = this.__ease.apply(null, [currentTime, 0, 1, __duration]);
			}

			//Tween the property
			var i:int = __tweenInfoArr.length;
			while(i--)
			{
				var ti:TweenInfo = __tweenInfoArr[i];
				var targetValue:Number = ti.start + factor * ti.change;
				ti.target[ti.property] = targetValue;
			}

			//on Update method
			if(__onUpdate != null)
				__onUpdate.apply(null, __onUpdateParams);

			//on Complete
			if(currentTime == __duration)
			{
				if(__onComplete != null)
					__onComplete.apply(null, __onCompleteParams);

				TweenManager.removeTweenForTarget(__target);
			}
		}
		private static function easeOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return 1 - (t = 1 - (t / d)) * t;
		}
	}
}

class TweenInfo
{
	public var target:Object;
	public var property:String;
	public var start:Number;
	public var change:Number;

	public function TweenInfo(t:Object, p:String, s:Number, c:Number)
	{
		this.target = t;
		this.property = p;
		this.start = s;
		this.change = c;
	}
}