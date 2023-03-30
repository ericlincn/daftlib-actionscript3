package cn.daftlib.layout
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import cn.daftlib.errors.DuplicateDefinedError;

	/**
	 * Managements the layout
	 *
	 * @example Place the displayobjects
	 *
	 *		<listing version="3.0">
	 *			var sp1:Sprite=new Sprite();
	 *			var sp2:Sprite=new Sprite();
	 *			var sp3:Sprite=new Sprite();
	 *			var sp4:Sprite=new Sprite();
	 *
	 * 			AutoFit.setStage(StageReference.stage);
	 *
	 * 			//When the stage resized, the sprite scaled to cover the whole stage, just like background
	 *			AutoFit.register(sp1, AutoFit.SCALE);
	 *
	 * 			//When the stage resized, the sprite width always equles to stage width, like navigation background
	 * 			AutoFit.register(sp2, AutoFit.SCALEX);
	 *
	 * 			//When the stage resized, the sprite always placed at the center
	 * 			//If the Sprite size is 0, AutoFit thow a error, you should define the non-scale size manually
	 * 			//Set the $animation to true will make the fit processing animated
	 * 			AutoFit.register(sp3, AutoFit.CENTER, null, 300, 100, true);
	 *
	 * 			//When the stage resized, the sprite always placed at the bottom right coner
	 * 			//And the position offset is (-100, 20)
	 * 			AutoFit.register(sp4, AutoFit.BOTTOMRIGHT, new Point(-100, 20));
	 *		</listing>
	 *
	 * @author Eric.lin
	 *
	 */
	public final class AutoFit
	{
		private static var __stage:Stage;
		private static var __displayObjectMap:Dictionary = new Dictionary(true);

		public static const SCALE:Object = {x:0, y:0, scaleX:1, scaleY:1};
		public static const SCALEX:Object = {x:0, y:0, scaleX:1, scaleY:0};
		public static const SCALEY:Object = {x:0, y:0, scaleX:0, scaleY:1};
		public static const CENTER_SCALEX:Object = {x:.5, y:.5, scaleX:1, scaleY:0};
		public static const CENTER_SCALEY:Object = {x:.5, y:.5, scaleX:0, scaleY:1};

		public static const TOP_LEFT:Object = {x:0, y:0, scaleX:0, scaleY:0};
		public static const TOP_CENTER:Object = {x:.5, y:0, scaleX:0, scaleY:0};
		public static const TOP_RIGHT:Object = {x:1, y:0, scaleX:0, scaleY:0};
		public static const LEFT:Object = {x:0, y:.5, scaleX:0, scaleY:0};
		public static const CENTER:Object = {x:.5, y:.5, scaleX:0, scaleY:0};
		public static const RIGHT:Object = {x:1, y:.5, scaleX:0, scaleY:0};
		public static const BOTTOM_LEFT:Object = {x:0, y:1, scaleX:0, scaleY:0};
		public static const BOTTOM_CENTER:Object = {x:.5, y:1, scaleX:0, scaleY:0};
		public static const BOTTOM_RIGHT:Object = {x:1, y:1, scaleX:0, scaleY:0};

		public static function initialize(stage:Stage):void
		{
			if(__stage == null)
			{
				__stage = stage;
				__stage.addEventListener(Event.RESIZE, onResize);
			}
			else
				throw new DuplicateDefinedError(__stage.toString());
		}
		/**
		 * 注册一个需要自适应的DisplayObject.
		 * @param $do
		 * @param $fitMode
		 * @param $offsetPoint
		 * @param $originalWidth
		 * @param $originalHeight
		 * @param $animation
		 */
		public static function register(displayObject:DisplayObject, fitMode:Object, offsetPoint:Point = null, width:Number = 0, height:Number = 0):void
		{
			if(__stage == null)
				throw new Error('Please call "AutoFit.initialize" first.');

			if(offsetPoint == null)
				offsetPoint = new Point(0, 0);

			if(width == 0)
				width = displayObject.width;

			if(height == 0)
				height = displayObject.height;

			if(width == 0 || height == 0)
				width = height = 1;
			//throw new Error("Can't get the actual size of " + displayObject.toString() + ", please set a general value to $originalWidth & $originalHeight manually.");

			var info:FitInfo = new FitInfo();
			info.xPercent = fitMode.x;
			info.yPercent = fitMode.y;
			info.scaleXPercent = fitMode.scaleX;
			info.scaleYPercent = fitMode.scaleY;
			info.offsetX = offsetPoint.x;
			info.offsetY = offsetPoint.y;
			info.width = width;
			info.height = height;

			__displayObjectMap[displayObject] = info;

			fitOne(displayObject);
		}

		/**
		 * 注销掉一个已经注册的DisplayObject.
		 * @param $do
		 */
		public static function unRegister(displayObject:DisplayObject):void
		{
			if(__stage == null)
				throw new Error('Please call "AutoFit.initialize" first.');

			delete __displayObjectMap[displayObject];
		}

		private static function onResize(e:Event):void
		{
			for(var key:* in __displayObjectMap)
			{
				if(key.toString() != "null")
					fitOne(key);
			}
		}
		private static function fitOne(displayObject:DisplayObject):void
		{
			var stageWidth:uint = __stage.stageWidth;
			var stageHeight:uint = __stage.stageHeight;
			var info:FitInfo = __displayObjectMap[displayObject];
			var destX:Number = info.xPercent * stageWidth + info.offsetX;
			var destY:Number = info.yPercent * stageHeight + info.offsetY;

			displayObject.x = destX;
			displayObject.y = destY;

			var scaleX:Number = info.scaleXPercent * stageWidth / info.width;
			var scaleY:Number = info.scaleYPercent * stageHeight / info.height;

			// scaleX & scaleY, one of them is ZERO
			if((scaleX * scaleY == 0) && ((scaleX + scaleY) != 0))
				displayObject.scaleX = displayObject.scaleY = scaleX + scaleY;
			else
			{
				if(scaleX != 0)
					displayObject.scaleX = scaleX;
				if(scaleY != 0)
					displayObject.scaleY = scaleY;
			}
		}
	}
}
class FitInfo
{
	public var xPercent:Number;
	public var yPercent:Number;
	public var scaleXPercent:Number;
	public var scaleYPercent:Number;
	public var offsetX:Number;
	public var offsetY:Number;
	public var width:Number;
	public var height:Number;
	public function FitInfo()
	{
	}
}