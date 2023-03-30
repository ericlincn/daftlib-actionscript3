package cn.daftlib.touch.osc
{
	import flash.events.DatagramSocketDataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.DatagramSocket;
	import flash.utils.ByteArray;

	public final class OSCSocket extends EventDispatcher
	{
		private var __datagramSocket:DatagramSocket = new DatagramSocket();

		public function OSCSocket()
		{
		}
		public function connect(host:String, port:int):void
		{
			__datagramSocket.bind(port, host);
			__datagramSocket.addEventListener(DatagramSocketDataEvent.DATA, dataReceived);
			__datagramSocket.addEventListener(Event.CLOSE, closeHandler);
			__datagramSocket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			__datagramSocket.receive();
			trace(this, "Bound to: " + __datagramSocket.localAddress + ":" + __datagramSocket.localPort);
		}
		public function close():void
		{
			if(__datagramSocket != null)
				__datagramSocket.close();

			trace(this, "Try to close");
		}
		private function dataReceived(e:DatagramSocketDataEvent):void
		{
			var bytes:ByteArray = e.data;

			while(bytes.bytesAvailable > 0)
			{
				var path:String = readString(bytes);

				if(path != "")
				{
					if(path == "#bundle")
					{
						bytes.position += 8;
						var bundlelength:int = bytes.readInt();
						path = readString(bytes);
					}

					try
					{
						var datatypes:String = readString(bytes);
					}
					catch(e:Error)
					{
						trace(this, "Not connected");
						return;
					}

					var data:Array = new Array();
					data.push(path);
					for(var i:int = 1; i < datatypes.length; i++)
					{
						switch(datatypes.charAt(i))
						{
							case "s":
								data.push(readString(bytes));
								break;
							case "i":
								data.push(bytes.readInt());
								break;
							case "f":
								data.push(bytes.readFloat());
								break;
						}
					}
					this.dispatchEvent(new OSCMessageEvent(OSCMessageEvent.MESSAGE_RECEIVED, true, true, data));
				}
			}
		}
		private function readString(byteArray:ByteArray):String
		{
			var str:String = "";
			while(byteArray.readByte() != 0)
			{
				byteArray.position -= 1;
				str += byteArray.readUTFBytes(1);
			}
			byteArray.position += 3 - (str.length % 4)
			return str;
		}
		private function closeHandler(e:Event):void
		{
			trace(this, "Connection closed");
		}
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			trace(this, e);
		}
	}
}