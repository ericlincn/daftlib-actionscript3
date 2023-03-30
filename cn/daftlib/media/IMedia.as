package cn.daftlib.media
{
	public interface IMedia
	{
		function set source(url:String):void;
		function set loop(value:Boolean):void;
		function set volume(value:Number):void;
		function set pan(value:Number):void;
		function set playingTime(ms:Number):void;

		function get totalTime():uint;
		function get playingTime():Number;
		function get playingPercent():Number;
		function get loadingPercent():Number;

		function pause():void;
		function resume():void;
	}
}