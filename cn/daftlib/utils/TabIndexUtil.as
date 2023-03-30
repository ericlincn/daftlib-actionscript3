package cn.daftlib.utils
{
	import flash.display.InteractiveObject;

	public final class TabIndexUtil
	{
		public static function sequenceInteractiveObjects($interactiveObjectsVector:Vector.<InteractiveObject>):void
		{
			var i:uint = 0;
			while(i < $interactiveObjectsVector.length)
			{
				var io:InteractiveObject = $interactiveObjectsVector[i];
				io.tabIndex = i;

				i++;
			}
		}
	}
}