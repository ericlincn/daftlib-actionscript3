package cn.daftlib.platform
{
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	public final class JavaScript
	{
		public static function closeWindow():void
		{
			ExternalInterface.call(JSScripts.WINDOW_CLOSE);
		}
		public static function alert(message:String):void
		{
			ExternalInterface.call(JSScripts.ALERT, message);
		}
		public static function log(... parameters):void
		{
			var message:String = getTimer().toString() + "\n";

			var i:int = 0;
			while(i < parameters.length)
			{
				if(i == (parameters.length - 1))
					message += (parameters[i].toString());
				else
					message += (parameters[i].toString() + ",");

				i++;
			}

			ExternalInterface.call(JSScripts.LOG, message);
		}
		public static function getPageTitle():String
		{
			return ExternalInterface.call(JSScripts.GET_PAGE_TITLE);
		}
		public static function getPageURL():String
		{
			return ExternalInterface.call(JSScripts.GET_PAGE_URL);
		}

		/**
		 * checkJavaScriptIsReady
		 * @param $getJsReadyFunction
		 * @param $callback
		 *
		 * in html:
		 *
		 * <script type="text/javascript">
		 * var jsReady = false;
		 * function isJsReady(){ return jsReady; }
		 * function pageInit(){ jsReady = true; }
		 * </script>
		 *
		 * ......
		 *
		 * <body onload="pageInit();">
		 *
		 *
		 * in ActionScript:
		 *
		 * JavascriptUtil.checkJavaScriptIsReady("isJsReady", jsReadyHandler);
		 */
		public static function checkJavaScriptIsReady($getJsReadyFunction:String, $callback:Function):void
		{
			//if(ExternalInterface.available == false) return;

			if(getJavaScriptReady($getJsReadyFunction) == true)
			{
				if($callback != null)
					$callback.apply();
			}
			else
			{
				var readyTimer:Timer = new Timer(100, 0);
				readyTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
				{
					if(getJavaScriptReady($getJsReadyFunction) == true)
					{
						readyTimer.stop();
						if($callback != null)
							$callback.apply();
					}
				});
				readyTimer.start();
			}
		}
		private static function getJavaScriptReady($getJsReadyFunction:String):Boolean
		{
			var isReady:Boolean = ExternalInterface.call($getJsReadyFunction);
			return isReady;
		}
	}
}
class JSScripts
{

	public static var WINDOW_CLOSE:XML = <script><![CDATA[
		function close() { window.close(); }
		]]></script>;

	public static var ALERT:XML = <script><![CDATA[
		function alert(message) { window.alert(message); }
		]]></script>;

	public static var LOG:XML = <script><![CDATA[
		function log(message) { console.log(message); }
		]]></script>;

	public static var GET_PAGE_TITLE:XML = <script><![CDATA[
		function () { return document.title; }
		]]></script>;

	public static var GET_PAGE_URL:XML = <script><![CDATA[
		function () { return document.URL; }
		]]></script>;

	public static var GET_FLASH_ID:XML = <script><![CDATA[
		function(swfFullPath) {
			
			var getFileName = function(fullPath) {
				var ary =  fullPath.split("/");
				var fileName = ary[ary.length-1].split(".swf")[0];
				return fileName;
			}
			
			var ensureId = function(node) {
				if (node.attributes["id"] == null) {
					node.setAttribute("id",'swf'+new Date().getTime());
				}
			}
			
			var matchesTarget = function(fullPath) {
				return (getFileName(fullPath) == targetSwfName);
			}
			
			var targetSwfName = getFileName(swfFullPath);
			//Look through the embed nodes for one that matches our swf name
			var nodes = document.getElementsByTagName("embed");
			for (var i=0; i < nodes.length; i++) {
				//Parse just the SWF file name out of the whole src path and check if it matches
				if (matchesTarget(nodes[i].attributes["src"].nodeValue)) {
					ensureId(nodes[i]);
					return nodes[i].attributes["id"].nodeValue;
				}
			}
			
			
			//If we haven't found a matching embed, look through the object nodes
			nodes = document.getElementsByTagName("object");
			for (var j=0; j < nodes.length; j++) {
				//Check if the object tag has a data node
				if (nodes[j].attributes["data"] != null) {
					if (matchesTarget(nodes[j].attributes["data"].nodeValue)) {
						ensureId(nodes[j]);
						return nodes[j].attributes["id"].nodeValue;
					}
				}
				
				//Grab the param nodes out of this object, and look for one named "movie"
				var paramNodes = nodes[j].getElementsByTagName("param");
				for (var k=0; k < paramNodes.length; k++) {
					if (paramNodes[k].attributes["name"].nodeValue.toLowerCase() == "movie") {
						if (matchesTarget(paramNodes[k].attributes["value"].nodeValue)) {
							ensureId(nodes[j]);
							return nodes[j].attributes["id"].nodeValue;
						}
					}
				}
				
			}
			
			return null;
		}
		]]></script>;
}