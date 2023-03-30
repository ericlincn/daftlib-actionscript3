package cn.daftlib.core
{
	/**
	 * @author Eric.lin
	 */
	public interface IRemovableEventDispatcher
	{
		function removeEventsForType(type:String):void;
		function removeEventsForListener(listener:Function):void;
		function removeEventListeners():void;
	}
}