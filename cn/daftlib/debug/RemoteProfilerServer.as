package cn.daftlib.debug
{
	import com.adobe.crypto.SHA1;
	
	import flash.display.Stage;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	import cn.daftlib.errors.DuplicateDefinedError;

	public class RemoteProfilerServer
	{
		private static const WEBSOCKET_MAGIC_KEY:String = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

		private static var __tcpSocket:ServerSocket = new ServerSocket();
		private static var __clientSocket:Socket;
		private static var __stage:Stage;
		private static var __logger:Logger;

		public static function initialize(stage:Stage, port:int = 22222):void
		{
			if(__stage == null)
			{
				__stage = stage;
				__logger = new Logger(__stage.stageWidth, __stage.stageHeight);
				__stage.addChild(__logger);

				initializeSocket(port);
			}
			else
				throw new DuplicateDefinedError(__stage.toString());
		}
		private static function initializeSocket(port:int):void
		{
			var networkInfo:NetworkInfo = NetworkInfo.networkInfo;
			var interfaces:Vector.<NetworkInterface> = networkInfo.findInterfaces();
			var localIP:String = null;

			if(interfaces != null)
			{
				//trace("Interface count: " + interfaces.length);
				for each(var interfaceObj:NetworkInterface in interfaces)
				{
					/*trace("\nname: " + interfaceObj.name);
					trace("display name: " + interfaceObj.displayName);
					trace("mtu: " + interfaceObj.mtu);
					trace("active?: " + interfaceObj.active);
					trace("parent interface: " + interfaceObj.parent);
					trace("hardware address: " + interfaceObj.hardwareAddress);

					if(interfaceObj.subInterfaces != null)
					{
						trace("# subinterfaces: " + interfaceObj.subInterfaces.length);
					}
					trace("# addresses: " + interfaceObj.addresses.length);*/

					if(interfaceObj.active == true)
						__logger.log("[Class RemoteProfilerServer] " + interfaceObj.displayName);

					for each(var address:InterfaceAddress in interfaceObj.addresses)
					{
						/*trace("  type: " + address.ipVersion);
						trace("  address: " + address.address);
						trace("  broadcast: " + address.broadcast);
						trace("  prefix length: " + address.prefixLength);*/

						if(interfaceObj.active == true)
							__logger.log("[Class RemoteProfilerServer] " + address.address);

						if(interfaceObj.active == true && interfaceObj.mtu > 0 && localIP == null 
							&& interfaceObj.displayName.toLowerCase().indexOf('loopback') < 0 
							&& interfaceObj.displayName.toLowerCase().indexOf('bluetooth') < 0)
							localIP = address.address;
					}
				}
			}

			if(__tcpSocket.bound)
			{
				__tcpSocket.close();
				__tcpSocket = new ServerSocket();

			}
			__tcpSocket.bind(port, localIP);
			__tcpSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
			__tcpSocket.listen();
			__logger.log("[Class RemoteProfilerServer] " + "Bound to: " + __tcpSocket.localAddress + ":" + __tcpSocket.localPort);
		}
		private static function onConnect(e:ServerSocketConnectEvent):void
		{
			__clientSocket = e.socket;
			__clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, onClientSocketData);
			__logger.log("[Class RemoteProfilerServer] " + "Connection from " + __clientSocket.remoteAddress + ":" + __clientSocket.remotePort);
		}
		private static function onClientSocketData(e:ProgressEvent):void
		{
			var buffer:ByteArray = new ByteArray();
			__clientSocket.readBytes(buffer, 0, __clientSocket.bytesAvailable);

			var str:String = buffer.toString();

			if(str.indexOf("GET") == 0)
				readServerHandshake(buffer.toString());
			else
				__logger.log(buffer.toString());
		}
		private static function readServerHandshake(str:String):void
		{
			var acceptKey:String;
			var origin:String;
			var host:String;
			var lines:Array = str.split(/\r?\n/);
			var i:uint = 0;
			while(i < lines.length)
			{
				var header:Object = parseHTTPHeader(lines[i]);

				if(header)
				{
					var lcName:String = header.name.toLocaleLowerCase();
					if(lcName == 'sec-websocket-key')
					{
						acceptKey = header.value + WEBSOCKET_MAGIC_KEY;
					}
					if(lcName == 'origin')
					{
						origin = header.value;
					}
					if(lcName == 'host')
					{
						host = header.value;
					}
				}
				i++;
			}

			var base64hash:String = SHA1.hashToBase64(acceptKey);
			var requestedURL:String;
			var arr:Array = lines[0].split(" ");
			if(arr.length > 1)
			{
				requestedURL = arr[1];
			}

			var response:String = "HTTP/1.1 101 Switching Protocols\r\n" +
				"Upgrade: WebSocket\r\n" + 
				"Connection: Upgrade\r\n" + 
				"Sec-WebSocket-Accept: " + base64hash + "\r\n" + 
				"Sec-WebSocket-Origin: " + origin + "\r\n" + 
				"Sec-WebSocket-Location: ws://" + host + requestedURL + "\r\n" + 
				"\r\n";
			var responseBytes:ByteArray = new ByteArray();
			responseBytes.writeUTFBytes(response);
			responseBytes.position = 0;
			__clientSocket.writeBytes(responseBytes);
			__clientSocket.flush();
		}
		private static function parseHTTPHeader(line:String):Object
		{
			var header:Array = line.split(/\: +/);
			return header.length === 2 ? {name:header[0], value:header[1]} : null;
		}
	}
}