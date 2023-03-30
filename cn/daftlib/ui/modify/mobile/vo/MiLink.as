package cn.daftlib.ui.modify.mobile.vo
{
	import cn.daftlib.arcane;
	import cn.daftlib.ui.modify.mobile.MiApplication;

	public final class MiLink
	{
		public static const SELF:String = "_self";
		public static const BLANK:String = "_blank";

		private var __type:String;
		private var __url:String;

		public function MiLink($url:String, $type:String)
		{
			__url = $url;
			__type = $type;
		}
		public function get type():String
		{
			return __type;
		}
		public function get url():String
		{
			return __url;
		}
		public function go():void
		{
			MiApplication.arcane::handleMiLink(this);
		}
		public function toString():String
		{
			return "url:" + __url + " type:" + __type;
		}
		public function equals($link:MiLink):Boolean
		{
			return __url == $link.url && __type == $link.type;
		}
	}
}