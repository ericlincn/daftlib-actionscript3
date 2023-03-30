package cn.daftlib.observer
{
	/**
	 * @author Eric.lin
	 */
	public interface IObserver
	{
		function handlerNotification(notification:INotification):void;
	}
}