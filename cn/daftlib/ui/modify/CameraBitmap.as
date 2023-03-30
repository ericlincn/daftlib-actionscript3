package cn.daftlib.ui.modify
{
	import flash.display.BitmapData;
	import flash.events.ActivityEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.Timer;

	import cn.daftlib.display.DaftBitmap;
	import cn.daftlib.events.DeviceEvent;

	[Event(name = "render", type = "cn.daftlib.events.DeviceEvent")]
	[Event(name = "muted", type = "cn.daftlib.events.DeviceEvent")]

	public final class CameraBitmap extends DaftBitmap
	{
		private var __cam:Camera;
		private var __video:Video;
		private var __timer:Timer;
		private var __flipMatrix:Matrix = null;

		public function CameraBitmap($camera:Camera, $width:Number = 320, $height:Number = 240, $refreshRate:uint = 15, $mirro:Boolean = false)
		{
			super(null, "auto", false);

			this.bitmapData = new BitmapData($width, $height, false, 0x0);

			__cam = $camera;

			if(__cam != null)
			{
				__cam.setMode($width, $height, $refreshRate, true);
				//default is 50, 2000
				__cam.setMotionLevel(10, 800);
				__cam.addEventListener(ActivityEvent.ACTIVITY, onCameraActivity);
				//will not dispatch in Air
				__cam.addEventListener(StatusEvent.STATUS, onCameraStatus);

				__video = new Video($width, $height);
				__video.attachCamera(__cam);

				if($mirro == true)
				{
					__flipMatrix = new Matrix();
					__flipMatrix.a = -1;
					__flipMatrix.tx = $width;
				}

				__timer = new Timer(uint(1000 / $refreshRate));

				start();
			}
		}
		public function stop():void
		{
			__timer.removeEventListener(TimerEvent.TIMER, render);
		}
		public function start():void
		{
			if(__timer.hasEventListener(TimerEvent.TIMER) == false)
				__timer.addEventListener(TimerEvent.TIMER, render);
		}
		override public function destroy():void
		{
			if(__timer != null)
			{
				__timer.removeEventListener(TimerEvent.TIMER, render);
				__timer = null;
			}

			if(__video != null)
			{
				__video.clear();
				__video = null;
			}

			if(__cam != null)
			{
				__cam.removeEventListener(ActivityEvent.ACTIVITY, onCameraActivity);
				__cam.removeEventListener(StatusEvent.STATUS, onCameraStatus);
				__cam = null;
			}

			super.destroy();
		}
		private function onCameraActivity(e:ActivityEvent):void
		{
			if(e.activating == true)
				__timer.start();
			else
				__timer.stop();
		}
		private function onCameraStatus(e:StatusEvent):void
		{
			if(__cam.muted == true)
				this.dispatchEvent(new DeviceEvent(DeviceEvent.MUTED));
			else
				__timer.stop();
		}
		private function render(e:TimerEvent):void
		{
			this.bitmapData.draw(__video, __flipMatrix);
			this.dispatchEvent(new DeviceEvent(DeviceEvent.RENDER));
		}
	}
}