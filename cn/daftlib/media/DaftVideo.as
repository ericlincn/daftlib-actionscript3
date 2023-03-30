package cn.daftlib.media
{
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import cn.daftlib.arcane;
	import cn.daftlib.core.IDestroyable;
	import cn.daftlib.core.IRemovableEventDispatcher;
	import cn.daftlib.core.ListenerManager;
	import cn.daftlib.events.VideoEvent;

	[Event(name = "start", 		type = "cn.daftlib.events.VideoEvent")]
	[Event(name = "stop", 		type = "cn.daftlib.events.VideoEvent")]
	[Event(name = "metaData", 	type = "cn.daftlib.events.VideoEvent")]
	[Event(name = "bufferFull", type = "cn.daftlib.events.VideoEvent")]
	[Event(name = "bufferEmpty",type = "cn.daftlib.events.VideoEvent")]

	public final class DaftVideo extends Video implements IDestroyable, IRemovableEventDispatcher, IMedia
	{
		private var __connection:NetConnection;
		private var __stream:NetStream;

		private var __volume:Number = 1;
		private var __pan:Number = 0;
		private var __loop:Boolean = false;
		private var __totalTime:Number = 0;

		public function DaftVideo(width:int = 320, height:int = 240)
		{
			super(width, height);

			initConnection();
		}

		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			ListenerManager.arcane::registerEventListener(this, type, listener, useCapture);
		}
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			super.removeEventListener(type, listener, useCapture);
			ListenerManager.arcane::unregisterEventListener(this, type, listener, useCapture);
		}
		public function removeEventsForType(type:String):void
		{
			ListenerManager.arcane::removeEventsForType(this, type);
		}
		public function removeEventsForListener(listene:Function):void
		{
			ListenerManager.arcane::removeEventsForListener(this, listene);
		}
		public function removeEventListeners():void
		{
			ListenerManager.arcane::removeEventListeners(this);
		}

		override public function set x($value:Number):void
		{
			super.x = Math.round($value);
		}
		override public function set y($value:Number):void
		{
			super.y = Math.round($value);
		}
		/**
		 * Remove all event listeners for this object and remove this from display list.
		 * For completely destroy, you should set this object referrence to Null after call destroy().
		 */
		public function destroy():void
		{
			clearConnection();
			clearStream();

			this.clear();

			this.removeEventListeners();

			if(this.parent != null)
				this.parent.removeChild(this);
		}

		public function set source(url:String):void
		{
			clearStream();
			
			this.clear();

			if(url == null)
				return;

			__stream = new NetStream(__connection);
			__stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			__stream.client = getClient();
			__stream.play(url);

			applyTransform();
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
			ms = ms / 1000;

			if(__stream != null)
				__stream.seek(Math.round(ms * 100) / 100);
		}
		public function get totalTime():uint
		{
			return __totalTime;
		}
		public function get playingTime():Number
		{
			if(__stream != null)
				return __stream.time * 1000;

			return 0;
		}
		public function get playingPercent():Number
		{
			if(__totalTime != 0)
				return playingTime / __totalTime;

			return 0;
		}
		public function get loadingPercent():Number
		{
			if(__stream != null)
				return __stream.bytesLoaded / __stream.bytesTotal;

			return 0;
		}
		public function pause():void
		{
			if(__stream != null)
				__stream.pause();
		}
		public function resume():void
		{
			if(__stream != null)
				__stream.resume();
		}

		/**
		 * volume related
		 */
		private function applyTransform():void
		{
			if(__stream != null)
			{
				var transform:SoundTransform = __stream.soundTransform;
				transform.volume = __volume;
				transform.pan = __pan;
				__stream.soundTransform = transform;
			}
		}
		/**
		 * Initialize related
		 */
		private function initConnection():void
		{
			__connection = new NetConnection();
			__connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			__connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			__connection.connect(null);
		}
		private function netStatusHandler(event:NetStatusEvent):void
		{
			//trace("NetStatusEvent.info.code:	"+event.info.code);

			switch(event.info.code)
			{
				case "NetStream.Play.StreamNotFound":
					trace(this, "Stream not found");
					break;
				case "NetStream.Play.Start":
					this.attachNetStream(__stream);
					this.dispatchEvent(new VideoEvent(VideoEvent.START));
					break;
				case "NetStream.Play.Stop":
					this.dispatchEvent(new VideoEvent(VideoEvent.STOP));
					if(__loop == true)
						playingTime = 0;
					break;
				case "NetStream.Buffer.Empty":
					this.dispatchEvent(new VideoEvent(VideoEvent.BUFFER_EMPTY));
					break;
				case "NetStream.Buffer.Full":
					this.dispatchEvent(new VideoEvent(VideoEvent.BUFFER_FULL));
					break;
			}
		}
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace(this, event);
		}
		private function clearStream():void
		{
			if(__stream != null)
			{
				__stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				__stream.close();
				__stream = null;
			}
		}
		private function clearConnection():void
		{
			__connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			__connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}

		/**
		 * Meta related
		 */
		private function getClient():Object
		{
			var client:Object = {};
			client.onMetaData = this.onMetaData;
			client.onCuePoint = this.onCuePoint;
			client.onXMPData = this.onXMPData;

			return client;
		}
		private function onMetaData(info:Object):void
		{
			//trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
			var totalTime:Number = Number(info.duration);
			var frameRate:uint = uint(info.framerate);

			__totalTime = totalTime * 1000;

			var event:VideoEvent = new VideoEvent(VideoEvent.META_DATA);
			event.duration = Number(info.duration);
			event.framerate = uint(info.framerate);
			event.width = Number(info.width);
			event.height = Number(info.height);

			this.dispatchEvent(event);
		}
		private function onCuePoint(info:Object):void
		{
			//trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
		}
		private function onXMPData(info:Object):void
		{
			/*trace("onXMPData Fired\n");
			trace("raw XMP =\n");
			trace(info.data);
			var cuePoints:Array = new Array();
			var cuePoint:Object;
			var strFrameRate:String;
			var nTracksFrameRate:Number;
			var strTracks:String = "";
			var onXMPXML:XML = new XML(info.data);
			trace(onXMPXML)
			// Set up namespaces to make referencing easier
			var xmpDM:Namespace = new Namespace("http://ns.adobe.com/xmp/1.0/DynamicMedia/");
			var rdf:Namespace = new Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#");
			for each (var it:XML in onXMPXML..xmpDM::Tracks)
			{
			var strTrackName:String = it.rdf::Bag.rdf::li.rdf::Description.@xmpDM::trackName;
			var strFrameRateXML:String = it.rdf::Bag.rdf::li.rdf::Description.@xmpDM::frameRate;
			strFrameRate = strFrameRateXML.substr(1,strFrameRateXML.length);
	
			nTracksFrameRate = Number(strFrameRate);
	
			strTracks += it;
			}
			var onXMPTracksXML:XML = new XML(strTracks);
			var strCuepoints:String = "";
			for each (var item:XML in onXMPTracksXML..xmpDM::markers)
			{
			strCuepoints += item;
			}
			trace(strCuepoints); */
		}
	}
}