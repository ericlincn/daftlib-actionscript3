package cn.daftlib.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public final class FileUtil
	{
		public static function readFile(filePath:String):ByteArray
		{
			var file:File = File.applicationStorageDirectory.resolvePath(filePath);
			if(file.exists == false)
				return null;
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var bytes:ByteArray = new ByteArray;
			stream.readBytes(bytes, 0, stream.bytesAvailable);
			stream.close();
			return bytes;
		}
		public static function writeFile(filePath:String, bytes:ByteArray):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath(filePath);
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeBytes(bytes);
			
			stream.close();
		}
		public static function getFilesURL(dir:File, recursive:Boolean = false):Array
		{
			if(dir.isDirectory == true)
			{
				var files:Array = dir.getDirectoryListing();
				var out:Array = [];
				
				for each(var file:File in files)
				{
					if(file.isDirectory == false)
					{
						out.push(file.url);
					}
					else if(recursive == true)
					{
						out = out.concat(getFilesURL(file));
					}
				}
				
				return out;
			}
			
			return null;
		}
	}
}