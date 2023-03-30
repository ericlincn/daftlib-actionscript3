package cn.daftlib.media
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import cn.daftlib.core.RemovableEventDispatcher;

	[Event(name = "soundComplete", type = "flash.events.Event")]
	[Event(name = "id3", type = "flash.events.Event")]
	[Event(name = "complete", type = "flash.events.Event")]

	public final class DaftSound extends RemovableEventDispatcher implements IMedia
	{
		private var __sound:Sound;
		private var __channel:SoundChannel;

		private var __volume:Number = 1;
		private var __pan:Number = 0;
		private var __loop:Boolean = true;

		private var __paused:Boolean = false;
		private var __pausedTime:Number = 0;
		private var __id3:ID3Info = null;

		public function DaftSound()
		{
			super(null);
		}

		override public function destroy():void
		{
			super.destroy();

			clearChannel();
			clearSound();
		}
		public function get id3():ID3Info
		{
			return __id3;
		}
		public function set source(url:String):void
		{
			__id3 = null;

			clearChannel();
			clearSound();

			if(url == null)
				return;

			__sound = new Sound();
			__sound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			__sound.addEventListener(Event.ID3, id3Handler);
			__sound.addEventListener(Event.COMPLETE, completeHandler);
			__sound.load(new URLRequest(url));

			playSound();
		}
		public function set loop(value:Boolean):void
		{
			__loop = value;
		}
		public function set volume(value:Number):void
		{
			__volume = Math.max(0.0, Math.min(1.0, value));

			applyTransform();
		}
		public function set pan(value:Number):void
		{
			__pan = Math.max(-1.0, Math.min(1.0, value));

			applyTransform();
		}
		public function set playingTime(ms:Number):void
		{
			playSound(ms);
		}
		public function get totalTime():uint
		{
			if(__sound == null)
				return 0;

			if(loadingPercent == 0)
				return 0;

			return Math.ceil(__sound.length / loadingPercent);
		}
		public function get playingTime():Number
		{
			if(__channel == null)
				return 0;

			return __channel.position;
		}
		public function get playingPercent():Number
		{
			if(totalTime != 0)
				return playingTime / totalTime;

			return 0;
		}
		public function get loadingPercent():Number
		{
			if(__sound == null)
				return 0;

			return __sound.bytesLoaded / __sound.bytesTotal;
		}
		public function pause():void
		{
			if(__channel != null)
			{
				__pausedTime = __channel.position;
				__channel.stop();
				__paused = true;
			}
		}
		public function resume():void
		{
			if(__paused == true)
			{
				__paused = false;
				playSound(__pausedTime);
			}
		}

		/**
		 * start play
		 */
		private function playSound(startTime:Number = 0):void
		{
			if(__paused == true)
				return;
			if(__sound == null)
				return;

			clearChannel();
			
			__channel = __sound.play(startTime, 1);
			__channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);

			applyTransform();
		}
		private function applyTransform():void
		{
			if(__channel != null)
			{
				var transform:SoundTransform = __channel.soundTransform;
				transform.volume = __volume;
				transform.pan = __pan;
				__channel.soundTransform = transform;
			}
		}
		private function clearChannel():void
		{
			if(__channel != null)
			{
				__channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				__channel.stop();
				__channel = null;
			}
		}
		private function clearSound():void
		{
			if(__sound != null)
			{
				//__sound.close();
				__sound.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				__sound.removeEventListener(Event.ID3, id3Handler);
				__sound = null;
			}
		}
		private function soundCompleteHandler(e:Event):void
		{
			this.dispatchEvent(new Event(Event.SOUND_COMPLETE));

			if(__loop == true)
				playSound();
		}
		private function id3Handler(e:Event):void
		{
			__id3 = new ID3Info();

			__id3.album = encodeUTF8(__sound.id3.album);
			__id3.artist = encodeUTF8(__sound.id3.artist);
			__id3.comment = encodeUTF8(__sound.id3.comment);
			__id3.genre = encodeUTF8(__sound.id3.genre);
			__id3.songName = encodeUTF8(__sound.id3.songName);
			__id3.track = encodeUTF8(__sound.id3.track);
			__id3.year = encodeUTF8(__sound.id3.year);

			this.dispatchEvent(e);
		}
		private function completeHandler(e:Event):void
		{
			this.dispatchEvent(e);
		}
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			trace(this, e);
		}
		/**
		 * utils
		 */
		private function encodeUTF8(str:String):String
		{
			if(str == null)
				return null;

			var messy:Boolean = false;
			var origBA:ByteArray = new ByteArray();
			origBA.writeUTFBytes(str);
			var tempBA:ByteArray = new ByteArray();

			for(var i:uint = 0; i < origBA.length; i++)
			{
				if(origBA[i] == 194)
				{
					tempBA.writeByte(origBA[i + 1]);
					messy = true;
					i++;
				}
				else if(origBA[i] == 195)
				{
					tempBA.writeByte(origBA[i + 1] + 64);
					messy = true;
					i++;
				}
				else
				{
					tempBA.writeByte(origBA[i]);
				}
			}
			tempBA.position = 0;

			if(messy)
				return tempBA.readMultiByte(tempBA.bytesAvailable, "gb2312");
			else
				return tempBA.readMultiByte(tempBA.bytesAvailable, "utf-8");
		}
	}
}