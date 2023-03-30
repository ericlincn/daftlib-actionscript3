package cn.daftlib.touch.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import cn.daftlib.touch.display.SlideTouchSprite;
	import cn.daftlib.touch.events.FingerEvent;
	import cn.daftlib.touch.events.FingerGestureEvent;
	import cn.daftlib.touch.interfaces.ITouchCursorHandler;
	import cn.daftlib.utils.DisplayObjectUtil;
	import cn.daftlib.utils.NumberUtil;

	public class TouchList extends SlideTouchSprite
	{
		private var __list:Sprite;
		private var __listSize:Number = 0;
		private var __listStartPosition:Number = 0; // initial list position on touch 
		private var __listDownPosition:Number = 0;
		private var __viewportWidth:Number = 0;
		private var __scrollSpeed:Number = 0;
		private var __targetY:Number = 0;

		private var __isTouching:Boolean = false;
		private var __viewportHeight:Number = 0;
		private var __inertia:Number = 0; // fraction or slide speed, take in charge when mouseUp
		//private var __offsetRevise:Number = 0;
		
		private var __touchEnabledMap:Dictionary = new Dictionary();
		private var __listHitArea:Bitmap;

		public function TouchList(viewportWidth:Number, viewportHeight:Number)
		{
			super();

			__viewportWidth = viewportWidth;
			__viewportHeight = viewportHeight;

			this.addEventListener(FingerEvent.FINGER_BEGIN, onBegin);
			this.addEventListener(FingerEvent.FINGER_END, onEnd);
			this.addEventListener(FingerEvent.FINGER_DOWN, onMouseDown);
			this.addEventListener(FingerEvent.FINGER_UP, onMouseUp);
			this.addEventListener(FingerGestureEvent.GESTURE_PAN, onMouseMove);
			this.addEventListener(Event.ENTER_FRAME, onRenderTick);

			creatList();
			updateViewSize();
		}
		override public function destroy():void
		{
			DisplayObjectUtil.destroyAllChildrenIn(__list);

			super.destroy();

			__list = null;
		}
		public function addItem(item:IItemRenderer):void
		{
			DisplayObject(item).y = __listSize;
			__listSize += item.itemHeight;
			__list.addChild(DisplayObject(item));
		}
		public function get viewportWidth():Number
		{
			return __viewportWidth;
		}
		public function get viewportHeight():Number
		{
			return __viewportHeight;
		}
		public function set viewportWidth(value:Number):void
		{
			__viewportWidth = value;
			updateViewSize();
		}
		public function set viewportHeight(value:Number):void
		{
			__viewportHeight = value;
			updateViewSize();
		}
		private function creatList():void
		{
			__listHitArea = new Bitmap(null);
			this.addChild(__listHitArea);

			//var maskArea:Bitmap = new Bitmap(transparentBMD);
			//this.addChild(maskArea);

			__list = new Sprite();
			//__list.mask = maskArea;
			this.addChild(__list);
		}
		private function updateViewSize():void
		{
			__listHitArea.bitmapData = new BitmapData(__viewportWidth, __viewportHeight, true, 0x0);
			this.scrollRect = new Rectangle(0, 0, __viewportWidth, __viewportHeight);
		}
		private function onBegin(e:FingerEvent):void
		{
			__listStartPosition = __list.y;
			__scrollSpeed = 0;

			//reset inertia
			__inertia = 0;
			//__offsetRevise=0;

			__targetY = __list.y;
		}
		private function onEnd(e:FingerEvent):void
		{
			__isTouching = false;
		}
		private function onMouseDown(e:FingerEvent):void
		{
			__listDownPosition = __targetY;
		}
		private function onMouseUp(e:FingerEvent):void
		{
			__listDownPosition = __targetY;
		}
		private function onMouseMove(e:FingerGestureEvent):void
		{
			__isTouching = true;

			__scrollSpeed = e.speedY;
			__inertia = NumberUtil.abs(e.speedY);
			__inertia = NumberUtil.min(__inertia, 150);
			__targetY = __listDownPosition + e.offsetY;

			var offset:Number = __targetY - __listStartPosition;

			var cannotScrollDown:Boolean = __targetY > 0;
			var cannotScrollUp:Boolean = (__listSize >= __viewportHeight && __targetY < __viewportHeight - __listSize) || (__listSize < __viewportHeight && __targetY < 0);
			var isShortList:Boolean = __listSize < __viewportHeight;

			if(cannotScrollDown == true && offset >= 0)
			{
				__inertia = Math.sqrt(__targetY - 0) * 3;
				__list.y = __inertia;
			}
			else if(cannotScrollUp == true && offset <= 0)
			{
				if(isShortList == true)
				{
					__inertia = Math.sqrt(0 - __targetY) * 3;
					__list.y = -__inertia;
				}
				else
				{
					__inertia = Math.sqrt(__viewportHeight - __listSize - __targetY) * 3;
					__list.y = __viewportHeight - __listSize - __inertia;
				}
			}
			else
			{
				__list.y = __targetY;
			}

			//trace(e.offsetY, __offsetRevise, offset, __list.y);

			//tryToDisableTouch();
		}
		private function onRenderTick(e:Event):void
		{
			// scroll the list on mouse up
			if(!__isTouching)
			{
				var cannotScrollDown:Boolean = __targetY > 0;
				var cannotScrollUp:Boolean = (__listSize >= __viewportHeight && __targetY < __viewportHeight - __listSize) || (__listSize < __viewportHeight && __targetY < 0);
				var isShortList:Boolean = __listSize < __viewportHeight;

				if(cannotScrollDown == true)
				{
					__inertia *= .8;

					__targetY = __inertia;

					__scrollSpeed = 0;
				}
				else if(cannotScrollUp == true)
				{
					if(isShortList == true)
					{
						__inertia *= .8;

						__targetY = -__inertia;
					}
					else
					{
						__inertia *= .8;

						__targetY = __viewportHeight - __listSize - __inertia;
					}

					__scrollSpeed = 0;
				}
				else
				{
					__inertia *= .95;

					__targetY += __scrollSpeed;

					__scrollSpeed *= .95;
				}
				__list.y = __targetY;

				/*if(__scrollSpeed < 10)
					tryToEnableTouch();*/
			}
		}
		private function tryToDisableTouch():void
		{
			if(__touchEnabledMap == null)
			{
				__touchEnabledMap = new Dictionary();
				var i:int = __list.numChildren;
				while(i--)
				{
					if(__list.getChildAt(i) is ITouchCursorHandler)
					{
						__touchEnabledMap[__list.getChildAt(i)] = ITouchCursorHandler(__list.getChildAt(i)).touchEnabled;
						ITouchCursorHandler(__list.getChildAt(i)).touchEnabled = false;
					}
				}
			}
		}
		private function tryToEnableTouch():void
		{
			if(__touchEnabledMap != null)
			{
				for(var key:DisplayObject in __touchEnabledMap)
				{
					ITouchCursorHandler(key).touchEnabled = __touchEnabledMap[key];
				}
				__touchEnabledMap = null;
			}
		}
	}
}