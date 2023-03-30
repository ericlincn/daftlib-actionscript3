package cn.daftlib.ui.modify.mobile
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	import cn.daftlib.arcane;
	import cn.daftlib.ui.modify.mobile.vo.MiLink;
	import cn.daftlib.ui.modify.mobile.vo.MiPage;

	use namespace arcane

	public final class MiApplication
	{
		private static var __urlPageMap:Dictionary = new Dictionary();
		private static var __currentLink:MiLink = null;
		private static var __container:Sprite;
		private static var __pageUpdateHandler:Function = null;

		private static var __currentPageView:MiPageView = null;
		private static var __backgroundPageView:MiPageView = null;
		private static var __linkHistory:Array = [];

		private static const WEB:String = "web";
		private static const APP:String = "app";
		private static var __historyType:String = APP;

		private static var __urlIndexArr:Array = [];
		private static var __urlOffset:int = 0;

		public static function initialize($stage:Stage, $container:Sprite, $pageUpdateHandler:Function):void
		{
			__container = $container;
			__pageUpdateHandler = $pageUpdateHandler;

			$stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		public static function set keepAwake($value:Boolean):void
		{
			if($value == true)
			{
				trace(MiApplication, 'Flag <uses-permission android:name="android.permission.WAKE_LOCK"/> must be added in the application descriptor.');
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			}
			else
				NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
		}
		public static function get linkOffset():int
		{
			return __urlOffset;
		}
		public static function registerPage($url:String, $type:String, $pageViewClassType:Class):void
		{
			var link:MiLink = new MiLink($url, $type);
			var page:MiPage = new MiPage(link, $pageViewClassType);

			__urlPageMap[link.url] = page;

			__urlIndexArr.push(link.url);
		}
		public static function back():void
		{
			__linkHistory.pop();

			//traceLinkHistory();

			handleMiLink(__linkHistory[__linkHistory.length - 1], false);
		}

		// For MobileLink only
		arcane static function handleMiLink($link:MiLink, $updateHistory:Boolean = true):void
		{
			var url:String = $link.url;

			// doesn't exist
			if(__urlPageMap[url] == undefined)
				return;

			var page:MiPage = __urlPageMap[url];

			// link argus are wrong
			if(page.link.equals($link) == false)
				return;

			// equals current link
			if(__currentLink != null)
			{
				if(__currentLink.equals($link))
					return;
			}

			if(__currentLink != null)
				__urlOffset = getUrlIndex(url) > getUrlIndex(__currentLink.url) ? 1 : -1;

			updatePage(url);

			__currentLink = $link;

			if($updateHistory == true)
				updateHistory($link);

			__pageUpdateHandler.apply(null, [$link]);
		}
		private static function updateHistory($link:MiLink):void
		{
			if(__historyType == WEB)
			{
				__linkHistory.push($link);
			}
			else if(__historyType == APP)
			{
				var inHistory:Boolean = false;
				var i:uint = 0;
				while(i < __linkHistory.length)
				{
					if(__linkHistory[i].url == $link.url)
					{
						inHistory = true;
						break;
					}
					i++;
				}

				if(inHistory == true)
					__linkHistory = __linkHistory.slice(0, i);

				__linkHistory.push($link);
			}

			//traceLinkHistory();
		}
		private static function onKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.BACK)
			{
				e.preventDefault();
				
				if(__linkHistory.length <= 1)
				{
					__container = null;
					e.target.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					NativeApplication.nativeApplication.exit();
				}
				else
				{
					back();
				}
			}
		}
		private static function traceLinkHistory():void
		{
			var out:Array = [];
			var i:uint = 0;
			while(i < __linkHistory.length)
			{
				out.push(__linkHistory[i].url);
				i++;
			}
			trace(out);
		}
		private static function getUrlIndex($url:String):int
		{
			return __urlIndexArr.indexOf($url);
		}
		private static function updatePage($url:String):void
		{
			var pageData:MiPage = __urlPageMap[$url];
			var PageClass:Class = pageData.classType;
			var frontPage:MiPageView;

			var backLinkType:String = __currentLink == null ? null : __currentLink.type;
			var frontLinkType:String = pageData.link.type;

			// front page is page, current page is page
			if((backLinkType == null || backLinkType == MiLink.SELF) && frontLinkType == MiLink.SELF)
			{
				if(__currentPageView != null)
					__currentPageView.transitionOut();

				frontPage = new PageClass(pageData);
				frontPage.transitionIn();
				__container.addChild(frontPage);
				__currentPageView = frontPage;
			}

			// front page is popup, current page is page
			else if(backLinkType == MiLink.SELF && frontLinkType == MiLink.BLANK)
			{
				if(__currentPageView != null)
					__currentPageView.deactive();

				__backgroundPageView = __currentPageView;

				frontPage = new PageClass(pageData);
				frontPage.transitionIn();
				__container.addChild(frontPage);
				__currentPageView = frontPage;
			}

			// front page is page, current page is popup
			else if(backLinkType == MiLink.BLANK && frontLinkType == MiLink.SELF)
			{
				if(__currentPageView != null)
					__currentPageView.transitionOut();

				frontPage = __backgroundPageView;
				frontPage.active();
				__container.addChildAt(frontPage, 0);
				__currentPageView = frontPage;

				__backgroundPageView = null;
			}

			//trace(__pageViewContainer.numChildren);
		}
	}
}