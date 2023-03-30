package cn.daftlib.touch.components
{
	import flash.geom.Point;
	
	import cn.daftlib.touch.display.RotateScaleTouchSprite;
	import cn.daftlib.touch.events.FingerEvent;
	import cn.daftlib.touch.events.FingerGestureEvent;
	import cn.daftlib.utils.DisplayObjectUtil;

	public class FreeTouchSprite extends RotateScaleTouchSprite
	{
		private var __startPosition:Point;
		private var __startScale:Number;
		private var __startRotation:Number;

		public function FreeTouchSprite()
		{
			super();

			__singleDirectionPan = false;

			this.addEventListener(FingerEvent.FINGER_DOWN, downHandler);
			this.addEventListener(FingerEvent.FINGER_UP, upHandlder);
			this.addEventListener(FingerGestureEvent.GESTURE_PAN, panHandler);
			this.addEventListener(FingerGestureEvent.GESTURE_ROTATE_SCALE, rotateScaleHandler);
		}
		private function rotateScaleHandler(e:FingerGestureEvent):void
		{
			DisplayObjectUtil.setPropertyByRegistration(this, new Point(e.registeX, e.registeY), "scaleX", __startScale * e.scaleRatio);
			DisplayObjectUtil.setPropertyByRegistration(this, new Point(e.registeX, e.registeY), "scaleY", __startScale * e.scaleRatio);
			DisplayObjectUtil.setPropertyByRegistration(this, new Point(e.registeX, e.registeY), "rotation", __startRotation + e.rotationDelta);
		}
		private function panHandler(e:FingerGestureEvent):void
		{
			if(e.registeX == 0 && e.registeY == 0)
			{
				this.x = __startPosition.x + e.offsetX;
				this.y = __startPosition.y + e.offsetY;
			}
			else
			{
				DisplayObjectUtil.setPropertyByRegistration(this, new Point(e.registeX, e.registeY), "x", e.stageX);
				DisplayObjectUtil.setPropertyByRegistration(this, new Point(e.registeX, e.registeY), "y", e.stageY);
			}
		}
		private function upHandlder(e:FingerEvent):void
		{
			__startPosition = new Point(this.x, this.y);
			__startScale = this.scaleX;
			__startRotation = this.rotation;
		}
		private function downHandler(e:FingerEvent):void
		{
			__startPosition = new Point(this.x, this.y);
			__startScale = this.scaleX;
			__startRotation = this.rotation;
		}
	}
}