package cn.daftlib.load
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import cn.daftlib.core.RemovableEventDispatcher;
	import cn.daftlib.errors.InvalidTypeError;
	import cn.daftlib.events.LoadEvent;

	[Event(name = "start", 			type = "cn.daftlib.events.LoadEvent")]
	[Event(name = "progress", 		type = "cn.daftlib.events.LoadEvent")]
	[Event(name = "complete", 		type = "cn.daftlib.events.LoadEvent")]
	[Event(name = "itemComplete", 	type = "cn.daftlib.events.LoadEvent")]

	/**
	 * Queue loader for multi-files
	 * @author Eric.lin
	 */
	public final class MultiLoader extends RemovableEventDispatcher
	{
		private const IMAGE_EXTENSIONS:Array = ["swf", "jpg", "jpeg", "gif", "png"];
		private const TEXT_EXTENSIONS:Array 	= ["txt", "js", "xml", "php", "asp", "aspx"];
		
		public static const IMAGE:String = "image";
		public static const TEXT:String  = URLLoaderDataFormat.TEXT;
		public static const BINARY:String  = URLLoaderDataFormat.BINARY;
		public static const VARIABLES:String  = URLLoaderDataFormat.VARIABLES;

		private var __loaded:Dictionary;
		private var __itemsLoaded:int;
		private var __items:Array;

		private var __currentDispatcher:IEventDispatcher;
		
		public function MultiLoader()
		{
			super(null);

			clear();
		}

		/**
		 * Add a file to loading queue
		 * @param $url
		 * @param $type If the target url is dymanic pages or unusual data format, set this value as MultiLoader.TYPE_TEXT manually
		 * @param $bytesTotal
		 * @param $context
		 */
		public function add(url:String, type:String = null, context:LoaderContext = null, bytesTotal:Number = 0):void
		{
			var loadingItem:LoadingItem = new LoadingItem();
			loadingItem.request = new URLRequest(url);

			if(context != null)
				loadingItem.context = context;
			if(type != null)
				loadingItem.type = type;

			loadingItem.bytesTotal = bytesTotal;

			if(loadingItem.type == null)
				loadingItem.type = getType(url);

			__items.push(loadingItem);
		}

		/**
		 * Start loading all added files
		 */
		public function start():void
		{
			if(__items.length <= 0)
				throw new Error('Non loading task has been added.');

			__itemsLoaded = 0;
			load(__itemsLoaded);

			this.dispatchEvent(new LoadEvent(LoadEvent.START));
		}
		/**
		 * Gets loaded items by key
		 * @param $key
		 * @return
		 */
		public function get(key:String):*
		{
			if(__loaded[key] != undefined)
			{
				return __loaded[key];
			}

			return null;
		}
		/**
		 * Stop the loading sequece and clear all loading queue
		 */
		public function clear():void
		{
			if(this.hasEventListener(LoadEvent.COMPLETE))
				this.removeEventsForType(LoadEvent.COMPLETE);

			if(__currentDispatcher != null)
			{
				__currentDispatcher.removeEventListener(Event.COMPLETE, completeHandler);
				__currentDispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
				__currentDispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				__currentDispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				__currentDispatcher = null;
			}

			__loaded = new Dictionary();
			__items = [];
		}
		override public function destroy():void
		{
			clear();

			super.destroy();
		}

		private function loadImage(url:URLRequest, context:LoaderContext):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			try
			{
				loader.load(url, context);
			}
			catch(err:Error)
			{
				trace(this, err);
			}

			__currentDispatcher = loader.contentLoaderInfo;
		}
		private function loadText(url:URLRequest, type:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat=type;
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			try
			{
				loader.load(url);
			}
			catch(err:Error)
			{
				trace(this, err);
			}

			__currentDispatcher = loader;
		}
		private function completeHandler(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, completeHandler);
			e.target.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			e.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

			var item:LoadingItem = __items[__itemsLoaded];
			if(e.target is LoaderInfo)
				__loaded[item.request.url]=(e.target as LoaderInfo).content;
			else if(e.target is URLLoader)
				__loaded[item.request.url]=(e.target as URLLoader).data;
			
			var event:LoadEvent = new LoadEvent(LoadEvent.ITEM_COMPLETE);
			event.url = item.request.url;
			this.dispatchEvent(event);

			__itemsLoaded++;
			if(__itemsLoaded >= __items.length)
			{
				this.dispatchEvent(new LoadEvent(LoadEvent.COMPLETE));
				__currentDispatcher = null;
			}
			else
				load(__itemsLoaded);
		}
		private function progressHandler(e:ProgressEvent):void
		{
			var singlePercent:Number = e.bytesLoaded / e.bytesTotal;
			var item:LoadingItem = __items[__itemsLoaded];

			if(e.bytesTotal <= 0)
			{
				if(item.bytesTotal != 0)
					singlePercent = e.bytesLoaded / item.bytesTotal;
				else
					singlePercent = 1;
			}

			var percentLoaded:Number = singlePercent + __itemsLoaded;
			var percentTotal:uint = __items.length;
			var event:LoadEvent = new LoadEvent(LoadEvent.PROGRESS);
			event.url = item.request.url;
			event.percent = percentLoaded / percentTotal;
			event.itemsLoaded = __itemsLoaded;
			event.itemsTotal = __items.length;
			this.dispatchEvent(event);
		}
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			//throw e;
			trace(this, e);
		}
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			//throw e;
			trace(this, e);
		}
		private function load(index:uint):void
		{
			var item:LoadingItem = __items[index];

			if(item.type == IMAGE)
				loadImage(item.request, item.context);
			else if(item.type == TEXT || item.type == BINARY || item.type == VARIABLES)
				loadText(item.request, item.type);
		}
		private function getType(url:String):String
		{
			var i:int;
			var extension:String;
			var n:int;
			var result:String = "";

			i = 0;
			n = IMAGE_EXTENSIONS.length;

			while(i < n)
			{
				extension = IMAGE_EXTENSIONS[i];
				if(extension == url.substr(-extension.length).toLowerCase())
				{
					result = IMAGE;
					break;
				}

				i++;
			}

			if(result != "")
				return result;

			i = 0;
			n = TEXT_EXTENSIONS.length;
			while(i < n)
			{
				extension = TEXT_EXTENSIONS[i];
				if(extension == url.substr(-extension.length).toLowerCase())
				{
					result = TEXT;
					break;
				}

				i++;
			}

			if(result != "")
				return result;
			else
				throw new InvalidTypeError(url.substr(-extension.length).toLowerCase());
		}
	}
}
import flash.net.URLRequest;
import flash.system.LoaderContext;

class LoadingItem
{
	public var request:URLRequest;
	public var type:String;
	public var context:LoaderContext;
	public var bytesTotal:Number;

	public function LoadingItem(){}
}