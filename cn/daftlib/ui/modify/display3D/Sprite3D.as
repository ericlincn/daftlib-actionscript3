package cn.daftlib.ui.modify.display3D
{
	/**
	 * A Stage3D-based sprite whose texture is packed with an ImagePacker
	 */
	public class Sprite3D
	{
		/** Vertex data for all sprites */
		private var __vertexData:Vector.<Number>;

		/** Index into the vertex data where the sprite's data is stored */
		private var __vertexDataIndex:int;

		/** X position of the sprite */
		private var __x:Number = 0;

		/** Y position of the sprite */
		private var __y:Number = 0;

		/** Rotation of the sprite in degrees */
		private var __rotation:Number = 0;

		/** Scale in the X direction */
		private var __scaleX:Number = 1;

		/** Scale in the Y direction */
		private var __scaleY:Number = 1;

		/** If the transform data needs updating */
		internal var needsUpdate:Boolean = true;

		/**
		 * Make the sprite data
		 * @param vertexData Vertex data for all sprites
		 * @param vertexDataIndex Index into the vertex data where the sprite's data is stored
		 * @param leftU U coordinate of the left side in the texture
		 * @param topV V coordinate of the top side in the texture
		 * @param rightU U coordinate of the right side in the texture
		 * @param bottomV V coordinate of the bottom side in the texture
		 */
		public function Sprite3D($vertexData:Vector.<Number>, $vertexDataIndex:int, 
												$leftU:Number, $topV:Number, $rightU:Number, $bottomV:Number)
		{
			__vertexData = $vertexData;
			__vertexDataIndex = $vertexDataIndex;

			// Add the vertices for the first vertex
			$vertexData[$vertexDataIndex++] = -1; // x
			$vertexData[$vertexDataIndex++] = -1; // y
			$vertexData[$vertexDataIndex++] = 0; // z
			$vertexData[$vertexDataIndex++] = $leftU; // u
			$vertexData[$vertexDataIndex++] = $bottomV; // v
			$vertexDataIndex += 6; // skip transform data

			// Add the vertices for the second vertex
			$vertexData[$vertexDataIndex++] = -1; // x
			$vertexData[$vertexDataIndex++] = 1; // y
			$vertexData[$vertexDataIndex++] = 0; // z
			$vertexData[$vertexDataIndex++] = $leftU; // u
			$vertexData[$vertexDataIndex++] = $topV; // v
			$vertexDataIndex += 6; // skip transform data

			// Add the vertices for the third vertex
			$vertexData[$vertexDataIndex++] = 1; // x
			$vertexData[$vertexDataIndex++] = 1; // y
			$vertexData[$vertexDataIndex++] = 0; // z
			$vertexData[$vertexDataIndex++] = $rightU; // u
			$vertexData[$vertexDataIndex++] = $topV; // v
			$vertexDataIndex += 6; // skip transform data

			// Add the vertices for the fourth vertex
			$vertexData[$vertexDataIndex++] = 1; // x
			$vertexData[$vertexDataIndex++] = -1; // y
			$vertexData[$vertexDataIndex++] = 0; // z
			$vertexData[$vertexDataIndex++] = $rightU; // u
			$vertexData[$vertexDataIndex++] = $bottomV; // v
		}
		/**
		 * X position of the sprite
		 */
		public function get x():Number
		{
			return __x;
		}
		public function set x(x:Number):void
		{
			__x = x;
			this.needsUpdate = true;
		}
		/**
		 * Y position of the sprite
		 */
		public function get y():Number
		{
			return __y;
		}
		public function set y(y:Number):void
		{
			__y = y;
			this.needsUpdate = true;
		}
		/**
		 * Rotation of the sprite in degrees
		 */
		public function get rotation():Number
		{
			return __rotation;
		}
		public function set rotation(rotation:Number):void
		{
			__rotation = rotation;
			this.needsUpdate = true;
		}
		/**
		 * Scale in the X direction
		 */
		public function get scaleX():Number
		{
			return __scaleX;
		}
		public function set scaleX(scaleX:Number):void
		{
			__scaleX = scaleX;
			this.needsUpdate = true;
		}
		/**
		 * Scale in the Y direction
		 */
		public function get scaleY():Number
		{
			return __scaleY;
		}
		public function set scaleY(scaleY:Number):void
		{
			__scaleY = scaleY;
			this.needsUpdate = true;
		}
		/**
		 * Tell the sprites collection that the sprite has been updated
		 */
		public function update():void
		{
			var radians:Number=rotation * (Math.PI / 180);
			var cosRotation:Number = Math.cos(radians);
			var sinRotation:Number = Math.sin(radians);

			var vertexDataIndex:int = __vertexDataIndex + 5; // skip x, y, z, u, v
			__vertexData[vertexDataIndex++] = __x;
			__vertexData[vertexDataIndex++] = __y;
			__vertexData[vertexDataIndex++] = __scaleX;
			__vertexData[vertexDataIndex++] = __scaleY;
			__vertexData[vertexDataIndex++] = cosRotation;
			__vertexData[vertexDataIndex++] = sinRotation;

			// Add the vertices for the second vertex
			vertexDataIndex += 5; // skip x, y, z, u, v
			__vertexData[vertexDataIndex++] = __x;
			__vertexData[vertexDataIndex++] = __y;
			__vertexData[vertexDataIndex++] = __scaleX;
			__vertexData[vertexDataIndex++] = __scaleY;
			__vertexData[vertexDataIndex++] = cosRotation;
			__vertexData[vertexDataIndex++] = sinRotation;

			// Add the vertices for the third vertex
			vertexDataIndex += 5; // skip x, y, z, u, v
			__vertexData[vertexDataIndex++] = __x;
			__vertexData[vertexDataIndex++] = __y;
			__vertexData[vertexDataIndex++] = __scaleX;
			__vertexData[vertexDataIndex++] = __scaleY;
			__vertexData[vertexDataIndex++] = cosRotation;
			__vertexData[vertexDataIndex++] = sinRotation;

			// Add the vertices for the fourth vertex
			vertexDataIndex += 5; // skip x, y, z, u, v
			__vertexData[vertexDataIndex++] = __x;
			__vertexData[vertexDataIndex++] = __y;
			__vertexData[vertexDataIndex++] = __scaleX;
			__vertexData[vertexDataIndex++] = __scaleY;
			__vertexData[vertexDataIndex++] = cosRotation;
			__vertexData[vertexDataIndex++] = sinRotation;
			
			this.needsUpdate = false;
		}
	}
}