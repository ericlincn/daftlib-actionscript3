package cn.daftlib.image
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public final class PNGEncoder
	{
		public function PNGEncoder(){}
		/**
		 * Encode bitmapData as PNG file
		 * @param $bitmapData
		 * @return
		 */
		public function encode(bitmapData:BitmapData):ByteArray
		{
			var crcTable:Array = initializeCRCTable();
			
			var pngWidth:int = bitmapData.width;
			var pngHeight:int = bitmapData.height;
			var transparent:Boolean = bitmapData.transparent;
			
			var sourceBitmapData:BitmapData = bitmapData;
			
			// Create output byte array
			var png:ByteArray = new ByteArray();
			
			// Write PNG signature
			png.writeUnsignedInt(0x89504E47);
			png.writeUnsignedInt(0x0D0A1A0A);
			
			// Build IHDR chunk
			var IHDR:ByteArray = new ByteArray();
			IHDR.writeInt(pngWidth);
			IHDR.writeInt(pngHeight);
			IHDR.writeByte(8); // bit depth per channel
			IHDR.writeByte(6); // color type: RGBA
			IHDR.writeByte(0); // compression method
			IHDR.writeByte(0); // filter method
			IHDR.writeByte(0); // interlace method
			writeChunk(png, 0x49484452, IHDR, crcTable);
			
			// Build IDAT chunk
			var IDAT:ByteArray = new ByteArray();
			for(var y:int = 0; y < pngHeight; y++)
			{
				IDAT.writeByte(0); // no filter
				
				var x:int;
				var pixel:uint;
				
				if(transparent == false)
				{
					for(x = 0; x < pngWidth; x++)
					{
						if(sourceBitmapData)
							pixel = sourceBitmapData.getPixel(x, y);
						
						IDAT.writeUnsignedInt(uint(((pixel & 0xFFFFFF) << 8) | 0xFF));
					}
				}
				else
				{
					for(x = 0; x < pngWidth; x++)
					{
						if(sourceBitmapData)
							pixel = sourceBitmapData.getPixel32(x, y);
						
						IDAT.writeUnsignedInt(uint(((pixel & 0xFFFFFF) << 8) | (pixel >>> 24)));
					}
				}
			}
			IDAT.compress();
			writeChunk(png, 0x49444154, IDAT, crcTable);
			
			// Build IEND chunk
			writeChunk(png, 0x49454E44, null, crcTable);
			
			// return PNG
			png.position = 0;
			return png;
		}
		private function initializeCRCTable():Array
		{
			var crcTable:Array = [];
			
			for(var n:uint = 0; n < 256; n++)
			{
				var c:uint = n;
				for(var k:uint = 0; k < 8; k++)
				{
					if(c & 1)
						c = uint(uint(0xedb88320) ^ uint(c >>> 1));
					else
						c = uint(c >>> 1);
				}
				crcTable[n] = c;
			}
			
			return crcTable;
		}
		private function writeChunk(png:ByteArray, type:uint, data:ByteArray, crcTable:Array):void
		{
			// Write length of data.
			var len:uint = 0;
			if(data != null)
				len = data.length;
			png.writeUnsignedInt(len);
			
			// Write chunk type.
			var typePos:uint = png.position;
			png.writeUnsignedInt(type);
			
			// Write data.
			if(data != null)
				png.writeBytes(data);
			
			// Write CRC of chunk type and data.
			var crcPos:uint = png.position;
			png.position = typePos;
			var crc:uint = 0xFFFFFFFF;
			for(var i:uint = typePos; i < crcPos; i++)
			{
				crc = uint(crcTable[(crc ^ png.readUnsignedByte()) & uint(0xFF)] ^ uint(crc >>> 8));
			}
			crc = uint(crc ^ uint(0xFFFFFFFF));
			png.position = crcPos;
			png.writeUnsignedInt(crc);
		}
	}
}