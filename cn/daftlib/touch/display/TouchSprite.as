package cn.daftlib.touch.display
{
	import flash.events.Event;
	import flash.utils.getTimer;

	import cn.daftlib.display.DaftSprite;
	import cn.daftlib.time.EnterFrame;
	import cn.daftlib.touch.TouchListener;
	import cn.daftlib.touch.events.FingerEvent;
	import cn.daftlib.touch.interfaces.ITouchCursorHandler;
	import cn.daftlib.touch.vo.TouchCursor;

	[Event(name = "fingerBegin", type = "cn.daftlib.touch.events.FingerEvent")]
	[Event(name = "fingerEnd", type = "cn.daftlib.touch.events.FingerEvent")]
	[Event(name = "fingerDown", type = "cn.daftlib.touch.events.FingerEvent")]
	[Event(name = "fingerUp", type = "cn.daftlib.touch.events.FingerEvent")]
	[Event(name = "fingerClick", type = "cn.daftlib.touch.events.FingerEvent")]
	[Event(name = "fingerHold", type = "cn.daftlib.touch.events.FingerEvent")]

	public class TouchSprite extends DaftSprite implements ITouchCursorHandler
	{
		private const HOLD_DELAY:uint = 300;

		protected const NONE:String = "none";

		// toggle if the FingerEvent/FingerGestureEvent dispatched to parent TouchSprite,
		// in case that a child TouchSprite within a nother father TouchSprite
		// then the child TouchSprite.bubbleEnabled must be set to true
		protected var __bubbleEnabled:Boolean = false;

		// works just like mouseEnabled
		private var __touchEnabled:Boolean = true;

		protected var __state:String = NONE;
		protected var __touchCursorCloneArr:Array = [];

		// Hold gesture related
		private var __holdTime:int;
		private var __gestureSequence:Array = [];

		public function TouchSprite()
		{
			super();
		}
		override public function destroy():void
		{
			EnterFrame.removeEventListener(onRenderTick);
			EnterFrame.removeEventListener(countHoldTime);

			super.destroy();

			__touchCursorCloneArr = null;
			__gestureSequence = null;
		}
		public function set touchEnabled(value:Boolean):void
		{
			__touchEnabled = value;
		}
		public function get touchEnabled():Boolean
		{
			return __touchEnabled;
		}
		public function get bubbleEnabled():Boolean
		{
			return __bubbleEnabled;
		}
		public function addTouchCursor(sessionID:uint):void
		{
			var tc:TouchCursor;
			var clone:TouchCursor;
			var i:uint = 0;
			while(i < __touchCursorCloneArr.length)
			{
				if(__touchCursorCloneArr[i].sessionID == sessionID)
					return;

				i++;
			}

			tc = TouchListener.getTouchCursor(sessionID);
			clone = getClone(tc);

			__touchCursorCloneArr.push(clone);

			if(__touchCursorCloneArr.length == 1)
			{
				EnterFrame.addEventListener(onRenderTick);
				handleTouchBegin(clone.x, clone.y);
			}

			__updateState();

			handleTouchDown(clone.x, clone.y);
		}
		private function checkTouchCursorAlive():void
		{
			var tc:TouchCursor;
			var clone:TouchCursor;
			var i:int = __touchCursorCloneArr.length;
			while(i--)
			{
				clone = __touchCursorCloneArr[i];
				tc = TouchListener.getTouchCursor(clone.sessionID);

				if(tc == null)
				{
					__touchCursorCloneArr.splice(i, 1);

					__updateState();

					handleTouchUp(clone.x, clone.y);
				}
				else
				{
					clone.update(tc.x, tc.y);
				}
			}

			if(__touchCursorCloneArr != null && __touchCursorCloneArr.length == 0) // destroy bugfix
			{
				EnterFrame.removeEventListener(onRenderTick);
				handleTouchEnd(clone.x, clone.y);
			}
		}
		protected function __updateState():void
		{

		}
		protected function __onTouchEnd():void
		{

		}
		protected function __onRenderTick():void
		{
			
		}
		protected function stopCountHoldTime(eventType:String, checkExist:Boolean = false):void
		{
			EnterFrame.removeEventListener(countHoldTime);

			if(checkExist == true)
			{
				if(__gestureSequence.indexOf(eventType) < 0)
					__gestureSequence.push(eventType);
			}
			else
				__gestureSequence.push(eventType);
		}
		/**
		 * dispatch gesture events
		 */
		private function handleTouchBegin(stageX:Number, stageY:Number):void
		{
			var event:FingerEvent = new FingerEvent(FingerEvent.FINGER_BEGIN);
			event.stageX = stageX;
			event.stageY = stageY;
			this.dispatchEvent(event);
		}
		private function handleTouchEnd(stageX:Number, stageY:Number):void
		{
			var event:FingerEvent = new FingerEvent(FingerEvent.FINGER_END);
			event.stageX = stageX;
			event.stageY = stageY;
			this.dispatchEvent(event);

			__onTouchEnd();
		}
		private function handleTouchDown(stageX:Number, stageY:Number):void
		{
			var event:FingerEvent = new FingerEvent(FingerEvent.FINGER_DOWN);
			event.stageX = stageX;
			event.stageY = stageY;
			this.dispatchEvent(event);

			__holdTime = getTimer();
			EnterFrame.addEventListener(countHoldTime);
			__gestureSequence.push(FingerEvent.FINGER_DOWN);
		}
		private function countHoldTime(e:Event):void
		{
			if(destroyed == true) // destroy bugfix
				return;

			if(__touchCursorCloneArr.length < 1)
				return;

			if((getTimer() - __holdTime) >= HOLD_DELAY)
			{
				var event:FingerEvent = new FingerEvent(FingerEvent.FINGER_HOLD);
				event.stageX = __touchCursorCloneArr[0].x;
				event.stageY = __touchCursorCloneArr[0].y;
				if(__touchEnabled == true)
				this.dispatchEvent(event);

				stopCountHoldTime(event.type);
			}
		}
		private function checkClickGestures(stageX:Number, stageY:Number):void
		{
			var sequeceStr:String = __gestureSequence.join("");

			if(sequeceStr == FingerEvent.FINGER_DOWN + FingerEvent.FINGER_UP)
			{
				var event:FingerEvent = new FingerEvent(FingerEvent.FINGER_CLICK);
				event.stageX = stageX;
				event.stageY = stageY;
				if(__touchEnabled == true)
				this.dispatchEvent(event);
			}
		}
		private function handleTouchUp(stageX:Number, stageY:Number):void
		{
			var event:FingerEvent = new FingerEvent(FingerEvent.FINGER_UP);
			event.stageX = stageX;
			event.stageY = stageY;
			if(__touchEnabled == true)
			this.dispatchEvent(event);

			stopCountHoldTime(event.type);

			checkClickGestures(stageX, stageY);

			__gestureSequence = [];
		}

		/**
		 * on render
		 */
		private function onRenderTick(e:Event):void
		{
			if(destroyed == true) // destroy bugfix
				return;

			checkTouchCursorAlive();
			
			__onRenderTick();
		}

		/**
		 * utils
		 */
		protected function getClone(target:TouchCursor):TouchCursor
		{
			return new TouchCursor(target.sessionID, target.x, target.y);
		}
		protected function isListening(eventType:String):Boolean
		{
			return this.hasEventListener(eventType);
		}
		private function get destroyed():Boolean
		{
			return __touchCursorCloneArr == null;
		}
	}
}