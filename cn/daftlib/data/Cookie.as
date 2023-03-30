package cn.daftlib.data
{
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;

	public final class Cookie
	{
		private const UPDATE_TIME:String = "updateTime";

		private var __name:String;
		
		public function Cookie(name:String)
		{
			__name = name;
		}
		public function setValue(key:String, data:*):void
		{
			if(key == UPDATE_TIME)
				throw new Error('$key couldnt be "updateTime".');

			var so:SharedObject = SharedObject.getLocal(__name, "/");
			tryToSetValue(so, key, data);
		}
		public function getValue(key:String):Object
		{
			var so:SharedObject = SharedObject.getLocal(__name, "/");
			return isExist(so, key) ? so.data[key] : null;
		}
		public function getUpdateTime():Object
		{
			return getValue(UPDATE_TIME);
		}
		public function removeValue(key:String):void
		{
			var so:SharedObject = SharedObject.getLocal(__name, "/");
			if(isExist(so, key))
			{
				delete so.data[key];
				tryToFlush(so);
			}
		}
		public function printAllValue():String
		{
			var so:SharedObject = SharedObject.getLocal(__name, "/");
			var outStr:String = "";
			var n:uint = getKeyNumber(so.data);
			for(var key:String in so.data)
			{
				try
				{
					outStr += key + ": " + so.data[key];
					if(n > 1)
						outStr += "\n";
				}
				catch(e:Error)
				{
					trace(Cookie, e);
				}
				n--;
			}
			return outStr == "" ? null : outStr;
		}
		public function clear():void
		{
			var so:SharedObject = SharedObject.getLocal(__name, "/");
			so.clear();
		}
		private function tryToSetValue(so:SharedObject, key:String, data:*):void
		{
			try
			{
				so.data[key] = data;
				so.data[UPDATE_TIME] = new Date().getTime();
			}
			catch(e:Error)
			{
				trace(Cookie, e);
			}
		}
		private function isExist(so:SharedObject, key:String):Boolean
		{
			try
			{
				return so.data[key] != undefined;
			}
			catch(e:Error)
			{
				trace(Cookie, e);
			}
			return false;
		}
		private function tryToFlush(so:SharedObject):void
		{
			var flushStatus:String = null;
			try
			{
				flushStatus = so.flush();
			}
			catch(e:Error)
			{
				trace(Cookie, e);
			}

			if(flushStatus != null)
			{
				switch(flushStatus)
				{
					/*
					如果此方法返回 SharedObjectFlushStatus.PENDING，则 Flash Player 将显示一个对话框，
					要求用户增加磁盘空间量以供此域中的对象使用。要允许将来保存共享对象时其空间能够增长，从而避免返回值 PENDING，
					请为 minDiskSpace 传递一个值。当 Flash Player 尝试写入文件时，它将查找传递给 minDiskSpace 的字节数，
					而不是查找足够的空间以共享对象的当前大小来保存共享对象。

					例如，如果预期共享对象增长到最大为 500 个字节，则即使它开始时要小得多，也为 minDiskSpace 传递 500。
					如果 Flash 要求用户为该共享对象分配磁盘空间，它将要求 500 个字节。在用户分配了请求的空间量之后，
					当以后尝试对齐该对象时（只要其大小不超过 500 个字节），Flash 将无需要求更多的空间。

					在用户响应此对话框后，则会再次调用此方法。将调度 netStatus 事件，
					code 属性值为 SharedObject.Flush.Success 或 SharedObject.Flush.Failed。
					*/

					case SharedObjectFlushStatus.PENDING:
						so.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
						break;
					case SharedObjectFlushStatus.FLUSHED:
						//trace(Cookie, "Flush success.");
						break;
				}
			}
		}
		private function getKeyNumber(object:Object):uint
		{
			var n:uint = 0;
			for(var key:String in object)
			{
				n++;
			}
			return n;
		}
		private function onFlushStatus(e:NetStatusEvent):void
		{
			trace(Cookie, e.info.code);
		}
	}
}