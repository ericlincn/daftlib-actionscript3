package cn.daftlib.ui.modify
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	
	import cn.daftlib.utils.StageReference;

	public final class PerspectiveProjectionUtil
	{
		private static var __root:DisplayObject;

		public static function autoCorrection($do:DisplayObject):void
		{
			__root = $do.root;
			StageReference.stage.addEventListener(Event.RESIZE, resizedHandler);
			resizedHandler(null);
		}
		private static function resizedHandler(e:Event):void
		{
			var pp:PerspectiveProjection = new PerspectiveProjection();
			pp.projectionCenter = new Point(StageReference.stageWidth / 2, StageReference.stageHeight / 2);

			__root.transform.perspectiveProjection = pp;
		}
	}
}