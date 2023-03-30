package cn.daftlib.touch.display
{
	import cn.daftlib.touch.events.FingerGestureEvent;

	[Event(name = "gesturePan", type = "cn.daftlib.touch.events.FingerGestureEvent")]

	public class SlideTouchSprite extends TouchSprite
	{
		private const MIN_OFFSET:uint = 15;

		protected const SLIDE:String = "slide";

		// related to oneDirectionPan
		private const HORIZONTAL:String = "horizontal";
		private const VERTICAL:String = "vertical";
		protected const FREE:String = "free";

		// toggle if the pan is single direction, for example,
		// when instance is a scroll list singleDirectionPan must be set to true
		// when instance is a dragging image singleDirectionPan must be set to false
		protected var __singleDirectionPan:Boolean = true;
		protected var __currentPanDirection:String = null;

		//private var __panFix:Point=null;

		public function SlideTouchSprite()
		{
			super();
		}
		override protected function __updateState():void
		{
			var prevState:String = __state;

			if(__touchCursorCloneArr.length >= 1)
			{
				__state = SLIDE;
			}
			else
			{
				__state = NONE;
			}

			//if(__state != prevState)
			{
				var i:uint = 0;
				while(i < __touchCursorCloneArr.length)
				{
					__touchCursorCloneArr[i] = getClone(__touchCursorCloneArr[i]);

					i++;
				}
			}
		}
		override protected function __onTouchEnd():void
		{
			// reset currentPanDirection
			__currentPanDirection = null;
			//__panFix=null;
		}
		protected function handlePan(stageX:Number, stageY:Number, offsetX:Number, offsetY:Number, speedX:Number, speedY:Number, registeX:Number = 0, registeY:Number = 0):void
		{
			if(Math.abs(offsetX) > MIN_OFFSET || Math.abs(offsetY) > MIN_OFFSET || __currentPanDirection != null)
			{
				/*if(__panFix==null && __currentPanDirection==null)
				{
					__panFix=new Point(offsetX, offsetY);
				}

				if(__panFix!=null)
				{
					offsetX-=__panFix.x;
					offsetY-=__panFix.y;
				}*/

				if(isListening(FingerGestureEvent.GESTURE_PAN) == true)
				{
					var event:FingerGestureEvent = new FingerGestureEvent(FingerGestureEvent.GESTURE_PAN);
					event.offsetX = offsetX;
					event.offsetY = offsetY;
					event.speedX = speedX;
					event.speedY = speedY;
					event.registeX = registeX;
					event.registeY = registeY;
					event.stageX = stageX;
					event.stageY = stageY;

					// lock currentPanDirection
					if(__singleDirectionPan == true && __currentPanDirection == null)
					{
						if(Math.abs(offsetX) > Math.abs(offsetY))
							__currentPanDirection = HORIZONTAL;
						else if(Math.abs(offsetX) < Math.abs(offsetY))
							__currentPanDirection = VERTICAL;
					}
					else if(__singleDirectionPan == false && __currentPanDirection == null)
					{
						__currentPanDirection = FREE;
					}

					// filter the x/y offset based on the currentPanDirection 
					if(__currentPanDirection == HORIZONTAL)
						event.offsetY = event.speedY = 0;
					else if(__currentPanDirection == VERTICAL)
						event.offsetX = event.speedX = 0;

					this.dispatchEvent(event);
				}

				stopCountHoldTime(FingerGestureEvent.GESTURE_PAN, true);
			}
		}
		override protected function __onRenderTick():void
		{
			if(__state == SLIDE)
			{
				handlePan(__touchCursorCloneArr[0].x, __touchCursorCloneArr[0].y, __touchCursorCloneArr[0].offsetX, __touchCursorCloneArr[0].offsetY, __touchCursorCloneArr[0].speedX, __touchCursorCloneArr[0].speedY);
			}
		}
	}
}