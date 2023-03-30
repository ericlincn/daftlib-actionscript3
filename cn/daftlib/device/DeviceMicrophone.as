package cn.daftlib.device
{
	import flash.media.Microphone;

	public final class DeviceMicrophone
	{
		public static function getMicrophone($playBackInSpeaker:Boolean = false, $gain:Number = 60):Microphone
		{
			if(Microphone.isSupported == false)
			{
				return null;
			}

			var mic:Microphone = Microphone.getMicrophone(-1);
			mic.setLoopBack($playBackInSpeaker);
			mic.setUseEchoSuppression(true);
			mic.gain = $gain;

			return mic;
		}
		public static function printAllMicrophone():String
		{
			if(Microphone.isSupported == false)
			{
				return null;
			}

			if(Microphone.names.length <= 0)
			{
				return null;
			}

			return Microphone.names.join();
		}
	}
}