package cn.daftlib.utils
{
	import flash.display.BitmapData;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	import cn.daftlib.image.PNGEncoder;

	public final class FileReferenceUtil
	{
		public static function getFileFilter($description:String, $fileExtensionVector:Vector.<String>):FileFilter
		{
			var extList:String = "";
			var i:int = $fileExtensionVector.length;
			while(i--)
			{
				var ext:String = $fileExtensionVector[i];
				var extIndex:int = ext.lastIndexOf('.');

				var ends:String = i == 0 ? "" : ";";

				if(extIndex == -1)
				{
					extList += "*." + ext + ends;
				}
				else
				{
					extList += "*." + ext.substr(extIndex + 1, ext.length).toLowerCase() + ends;
				}
			}

			return new FileFilter($description, extList);
		}
		public static function saveBitmapAsPNG($bmd:BitmapData, $fileNameWithoutExt:String):void
		{
			var file:FileReference = new FileReference();
			var encoder:PNGEncoder=new PNGEncoder();
			try
			{
				file.save(encoder.encode($bmd), $fileNameWithoutExt + ".png");
			}
			catch(error:Error)
			{
				trace(FileReferenceUtil, error);
			}
		}
	}
}