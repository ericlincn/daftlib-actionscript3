package cn.daftlib.utils
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.media.SoundTransform;
	
	import cn.daftlib.core.IDestroyable;

	public final class DisplayObjectUtil
	{
		public static function setVolume(target:Sprite, volume:Number):void
		{
			var transform:SoundTransform = target.soundTransform;
			transform.volume = volume;
			target.soundTransform = transform;
		}
		public static function setTint(target:DisplayObject, color:uint):void
		{
			var ct:ColorTransform = target.transform.colorTransform;
			ct.color = color;
			target.transform.colorTransform = ct;
		}
		public static function destroyAllChildrenIn(container:DisplayObjectContainer):void
		{
			while(container.numChildren > 0)
			{
				if((container.getChildAt(0) is IDestroyable))
					(container.getChildAt(0) as IDestroyable).destroy();
				else
				{
					if((container.getChildAt(0) is Loader))
						(container.getChildAt(0) as Loader).unloadAndStop();

					container.removeChildAt(0);
				}
			}
		}
		public static function smoothAllChildrenIn(container:DisplayObjectContainer, recursive:Boolean = false):void
		{
			var i:int = container.numChildren;
			while(i--)
			{
				var d:DisplayObject = container.getChildAt(i);
				if(d is Bitmap)
					Bitmap(d).smoothing = true;

				if(recursive == true && d is DisplayObjectContainer)
				{
					smoothAllChildrenIn(d as DisplayObjectContainer, true);
				}
			}
		}
		public static function setPropertyByRegistration(target:DisplayObject, regPoint:Point, prop:String, value:Number):void
		{
			var A:Point = target.parent.globalToLocal(target.localToGlobal(regPoint));

			if(prop == "x" || prop == "y")
			{
				target[prop] += value - A[prop];
			}
			else if(prop == "scaleX" || prop == "scaleY" || prop == "rotation")
			{
				target[prop] = value;
				//执行旋转等属性后，再重新计算全局坐标
				var B:Point = target.parent.globalToLocal(target.localToGlobal(regPoint));
				//把注册点从B点移到A点
				target.x += A.x - B.x;
				target.y += A.y - B.y;
			}
		}
		public static function getTopDisplayObjectUnderPoint(point:Point, stage:DisplayObjectContainer):DisplayObject
		{
			var targets:Array = stage.getObjectsUnderPoint(point);
			var item:DisplayObject = (targets.length > 0) ? targets[targets.length - 1] : stage;

			return item;
		}
		public static function flipHorizontal(target:DisplayObject):void
		{
			var matrix:Matrix = target.transform.matrix;
			matrix.a = -1;
			matrix.tx = target.width + target.x;
			target.transform.matrix = matrix;
		}
		public static function flipVertical(target:DisplayObject):void
		{
			var matrix:Matrix = target.transform.matrix;
			matrix.d = -1;
			matrix.ty = target.height + target.y;
			target.transform.matrix = matrix;
		}
		public static function fadein(target:DisplayObject, step:Number = .1, destAlpha:Number = 1):void
		{
			if(target.alpha < destAlpha)
				target.alpha = Math.min(destAlpha, target.alpha + step);
		}
		public static function fadeout(target:DisplayObject, step:Number = .1, destAlpha:Number = 0):void
		{
			if(target.alpha > destAlpha)
				target.alpha = Math.max(destAlpha, target.alpha - step);
		}
		public static function sortAllChildrenByZ(container:DisplayObjectContainer):void
		{
			if(container.numChildren <= 0)
				return;

			var arr:Array = [];
			var i:int = container.numChildren;
			while(i--)
			{
				arr.push(container.getChildAt(i));
			}

			arr.sortOn("z", Array.NUMERIC | Array.DESCENDING);

			i = container.numChildren;
			while(i--)
			{
				container.setChildIndex(arr[i], i);
			}
		}
		public static function printAllChildrenIn(container:DisplayObjectContainer, recursive:Boolean = false):String
		{
			var outStr:String = "";
			var i:int = container.numChildren;
			while(i--)
			{
				var d:DisplayObject = container.getChildAt(i);
				outStr += "DisplayObject: " + d + "	Depth: " + i + "	Name: " + d.name;
				outStr += "	Width: " + d.width + "	Height: " + d.height + "	Parent: " + d.parent;
				if(d is InteractiveObject)
					outStr += "	MouseEnabled: " + InteractiveObject(d).mouseEnabled;
				if(d is DisplayObjectContainer)
					outStr += "	MouseChildren: " + DisplayObjectContainer(d).mouseChildren;
				if(i > 0)
					outStr += "\n";

				if(recursive == true && d is DisplayObjectContainer)
				{
					outStr += printAllChildrenIn(d as DisplayObjectContainer, true);
				}
			}
			return outStr == "" ? null : outStr;
		}
		public static function setProjectionCenter(target:DisplayObject, center:Point):void
		{
			var pp:PerspectiveProjection = new PerspectiveProjection();
			pp.projectionCenter = center;

			target.transform.perspectiveProjection = pp;
		}
	}
}