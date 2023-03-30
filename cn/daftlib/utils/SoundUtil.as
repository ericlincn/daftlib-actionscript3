package cn.daftlib.utils
{
	import flash.utils.ByteArray;

	public final class SoundUtil
	{
		/*
		* usage:
		* var b:ByteArray = bytesToByteArray(Base64.decode(SoundUtil.SILENT_SOUND_BASE64));
		* b.position = 0;
		* var snd:Sound = new Sound();
		* snd.loadCompressedDataFromByteArray(b, b.length);
		* snd.play();
		*/
		public static function get SILENT_SOUND_BASE64():String
		{
			var str:String = "UklGRooWAABXQVZFZm10IBAAAAABAAEAIlYAAESsAAACABAAZGF0YWYW";
			var i:int = str.length;
			while(i<7704)
			{
				str += "A";
				i++;
			}
			
			return str;
		}
		public static function convert32bitAudioStreamTo16bit(bytes:ByteArray, volume:Number = 1):ByteArray
		{
			var ba:ByteArray = new ByteArray();

			bytes.position = 0;
			while(bytes.bytesAvailable)
			{
				ba.writeShort(bytes.readFloat() * (0x7fff * volume));
			}

			return ba;
		}
	}
}