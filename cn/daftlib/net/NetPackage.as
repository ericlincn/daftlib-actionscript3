package cn.daftlib.net
{
	public final class NetPackage implements INetPackage
	{
		private var __body:Object;
		private var __time:uint;

		public function NetPackage($body:Object, $time:uint)
		{
			__time = $time;
			__body = $body;
		}
		public function get body():Object
		{
			return __body;
		}
		public function get time():uint
		{
			return __time;
		}
	}
}