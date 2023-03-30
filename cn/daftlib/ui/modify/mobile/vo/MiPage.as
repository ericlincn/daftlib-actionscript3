package cn.daftlib.ui.modify.mobile.vo
{
	public final class MiPage
	{
		private var __link:MiLink;
		private var __classType:Class;

		public function MiPage($link:MiLink, $classType:Class)
		{
			__link = $link;
			__classType = $classType;
		}
		public function get link():MiLink
		{
			return __link;
		}
		public function get classType():Class
		{
			return __classType;
		}
	}
}