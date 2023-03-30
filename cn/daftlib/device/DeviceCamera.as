package cn.daftlib.device
{
	import flash.media.Camera;
	import flash.media.CameraPosition;
	import flash.system.Capabilities;

	public final class DeviceCamera
	{
		public static function getCamera($preferFront:Boolean = false):Camera
		{
			if(Camera.isSupported == false)
			{
				return null;
			}

			trace(DeviceCamera, 'Flag <uses-permission android:name="android.permission.CAMERA" /> <uses-feature android:name="android.hardware.camera.autofocus"/> must be added in the application descriptor.');

			var numCameras:int = Camera.names.length;
			var cam:Camera = Camera.getCamera();

			if($preferFront == true && Capabilities.playerType == "Desktop")
			{
				var i:int = numCameras;
				while(i--)
				{
					//cam = Camera.getCamera(Camera.names[i]);
					cam = Camera.getCamera(i.toString());

					if(cam.position == CameraPosition.FRONT)
						return cam;
				}
			}

			return cam;
		}
		public static function printAllCamera():String
		{
			if(Camera.isSupported == false)
			{
				return null;
			}

			if(Camera.names.length <= 0)
			{
				return null;
			}

			return Camera.names.join();
		}
	}
}