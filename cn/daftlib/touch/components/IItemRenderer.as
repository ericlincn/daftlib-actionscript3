package cn.daftlib.touch.components
{
	public interface IItemRenderer
	{
		function get itemWidth():Number;
		function get itemHeight():Number;
		function set visible(value:Boolean):void;
		function get visible():Boolean;
	}
}