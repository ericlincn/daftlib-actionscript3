package cn.daftlib.net
{
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;

	import cn.daftlib.core.RemovableEventDispatcher;
	import cn.daftlib.events.ConnectionEvent;

	[Event(name = "netStatusInfo", type = "cn.daftlib.events.ConnectionEvent")]
	[Event(name = "packageReceive", type = "cn.daftlib.events.ConnectionEvent")]

	public final class P2PLanConnection extends RemovableEventDispatcher
	{
		// also "225.225.0.1:30000", "239.254.254.2:30304"
		private const IP_MULTICAST_ADDRESS:String = "239.254.254.1:30303";

		private var __groupName:String;
		private var __nc:NetConnection;
		private var __ng:NetGroup;
		private var __id:String = null;
		private var __connectedNeighbor:String = null;

		public function P2PLanConnection(groupName:String)
		{
			super(null);

			if(groupName == null)
				throw new ArgumentError("The Argument $groupName must not be null.");

			__groupName = groupName;

			__nc = new NetConnection();
			__nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			__nc.connect("rtmfp:");
		}
		override public function destroy():void
		{
			if(__ng != null)
			{
				__ng.close();
				__ng.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				__ng = null;
			}

			if(__nc != null)
			{
				__nc.close();
				__nc.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				__nc = null;
			}

			super.destroy();
		}
		public function sendPackage(body:Object):void
		{
			if(__ng != null)
			{
				var obj:Object = {};
				obj.body = body;
				obj.time = new Date().time;
				__ng.sendToAllNeighbors(obj);
			}
		}
		private function setupGroup():void
		{
			var gs:GroupSpecifier = new GroupSpecifier(__groupName);
			gs.ipMulticastMemberUpdatesEnabled = true;
			gs.multicastEnabled = true;
			gs.postingEnabled = true;
			gs.routingEnabled = true;
			gs.addIPMulticastAddress(IP_MULTICAST_ADDRESS);

			__ng = new NetGroup(__nc, gs.groupspecWithAuthorizations());
			__ng.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		private function onNetStatus(e:NetStatusEvent):void
		{
			//trace(this, $e.info.code);
			var infoEvent:ConnectionEvent = new ConnectionEvent(ConnectionEvent.NET_STATUS_INFO);
			infoEvent.infoCode = e.info.code;
			this.dispatchEvent(infoEvent);

			switch(e.info.code)
			{
				case "NetConnection.Connect.Success":
					setupGroup();
					break;
				case "NetGroup.Connect.Success":
					__id = __ng.convertPeerIDToGroupAddress(__nc.nearID);
					break;
				case "NetGroup.Neighbor.Connect":
					__connectedNeighbor = e.info.neighbor;
					break;
				case "NetGroup.Neighbor.Disconnect":
					__connectedNeighbor = null;
					break;
				case "NetGroup.Posting.Notify": // e.info.message, e.info.messageID
					break;
				case "NetGroup.SendTo.Notify": // e.info.message, e.info.from, e.info.fromLocal
					//trace($e.info.message.body)
					var event:ConnectionEvent = new ConnectionEvent(ConnectionEvent.PACKAGE_RECEIVE);
					var p:NetPackage = new NetPackage(e.info.message.body, e.info.message.time);
					event.netPackage = p;
					this.dispatchEvent(event);
					break;
			}
		}
	}
}