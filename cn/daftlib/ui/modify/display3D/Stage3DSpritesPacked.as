package cn.daftlib.ui.modify.display3D
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.utils.ByteArray;
	
	/**
	 * Stage3D-based 2D sprites. Each has its own texture packed into a larger texture.
	 */
	public class Stage3DSpritesPacked
	{
		/** Cached static lookup of Context3DVertexBufferFormat.FLOAT_3 */
		private static const FLOAT3_FORMAT:String = Context3DVertexBufferFormat.FLOAT_3;
		
		/** Cached static lookup of Context3DVertexBufferFormat.FLOAT_4 */
		private static const FLOAT4_FORMAT:String = Context3DVertexBufferFormat.FLOAT_4;
		
		/** Temporary AGAL assembler to avoid allocation */
		private static const tempAssembler:AGALMiniAssembler = new AGALMiniAssembler();
		
		/** Vertex shader program AGAL bytecode */
		private static var vertexProgram:ByteArray;
		
		/** Fragment shader program AGAL bytecode */
		private static var fragmentProgram:ByteArray;
		
		// Static initializer to create vertex and fragment programs
		{
			// VA
			//  0 - posX, posY, posZ, {unused}
			//  1 - U, V, translationX, translationY
			//  2 - scaleX, scaleY, cos(rotation), sin(rotation)
			// VC
			// FC
			// V
			//  0 - U, V, {unused}, {unused}
			tempAssembler.assemble(
				Context3DProgramType.VERTEX,
				// Initial position
				"mov vt0, va0\n" +
				
				// Rotate (about Z, like this...)
				//   x' = x*cos(rot) - y*sin(rot)
				//   y' = x*sin(rot) + y*cos(rot)
				"mul vt1.xy, vt0.xy, va2.zw\n" + // x*cos(rot), y*sin(rot)
				"sub vt0.x, vt1.x, vt1.y\n" + // x*cos(rot) - y*sin(rot)
				"mul vt1.xy, vt0.xy, va2.wz\n" + // x*sin(rot), y*cos(rot)
				"add vt0.y, vt1.x, vt1.y\n" + // x*sin(rot) + y*cos(rot)
				
				// Scale
				"mul vt0.xy, vt0.xy, va2.xy\n" +
				
				// Translate
				"add vt0.xy, vt0.xy, va1.zw\n" +
				
				// Output position
				"mov op, vt0\n" +
				
				// Copy texture coordinate to varying
				"mov v0, va1\n"
			);
			vertexProgram = tempAssembler.agalcode;
			
			tempAssembler.assemble(
				Context3DProgramType.FRAGMENT,
				"tex oc, v0, fs0 <2d,linear,mipnone,clamp>"
			);
			fragmentProgram = tempAssembler.agalcode;
		}
		
		/** 3D context to use for drawing */
		private var __context3D:Context3D;
		
		/** Cache of positions Program3D per Context3D */
		private var program:Program3D;
		
		/** 3D texture to use for drawing */
		private var texture:Texture;
		
		/** Width of the created texture */
		private var textureWidth:uint;
		
		/** Height of the created texture */
		private var textureHeight:uint;
		
		/** Fragment shader constants: U scale, V scale, {unused}, {unused} */
		private var fragConsts:Vector.<Number> = new <Number>[1, 1, 1, 1];
		
		/** Data about the contained sprites */
		private var spriteData:Vector.<Sprite3D> = new <Sprite3D>[];
		
		/** Number of sprites */
		private var numSprites:int;
		
		/** Triangle index data */
		private var indexData:Vector.<uint> = new <uint>[];
		
		/** Vertex data for all sprites */
		private var vertexData:Vector.<Number> = new <Number>[];
		
		/** Vertex buffer for all sprites */
		private var vertexBuffer:VertexBuffer3D;
		
		/** Indx buffer for all sprites */
		private var indexBuffer:IndexBuffer3D;
		
		/** If the vertex and index buffers need to be uploaded */
		private var needUpload:Boolean;
		
		public function Stage3DSpritesPacked($context3D:Context3D, $viewportWidth:Number, $viewportHeight:Number, $antiAlias:int=0, $enableDepthAndStencil:Boolean=true)
		{
			__context3D = $context3D;
			__context3D.configureBackBuffer($viewportWidth, $viewportHeight, $antiAlias, $enableDepthAndStencil);
			
			// Create the shader program
			program = $context3D.createProgram();
			program.upload(vertexProgram, fragmentProgram);
		}
		
		/**
		 *   Set a BitmapData to use as a texture
		 *   @param bmd BitmapData to use as a texture
		 */
		public function set bitmapData(bmd:BitmapData): void
		{
			// Create a new texture if we need to
			var width:int = bmd.width;
			var height:int = bmd.height;
			
			if (!texture || textureWidth != width || textureHeight != height)
			{
				texture = __context3D.createTexture(
					width,
					height,
					Context3DTextureFormat.BGRA,
					false
				);
				textureWidth = width;
				textureHeight = height;
			}
			
			// Upload new BitmapData to the texture
			texture.uploadFromBitmapData(bmd);
		}
		
		/**
		 *   Add a sprite
		 *   @param leftU U coordinate of the left side in the texture
		 *   @param topV V coordinate of the top side in the texture
		 *   @param rightU U coordinate of the right side in the texture
		 *   @param bottomV V coordinate of the bottom side in the texture
		 *   @return The added sprite
		 */
		public function addChild(
			leftU:Number,
			topV:Number,
			rightU:Number,
			bottomV:Number
		): Sprite3D
		{
			if (vertexBuffer)
			{
				vertexBuffer.dispose();
				indexBuffer.dispose();
			}
			
			// Add the triangle indices for the sprite
			indexData.length += 6;
			var index:int = numSprites*6;
			var base:int = numSprites*4;
			indexData[index++] = base;
			indexData[index++] = base+1;
			indexData[index++] = base+2;
			indexData[index++] = base+2;
			indexData[index++] = base+3;
			indexData[index++] = base;
			
			// Add the sprite
			vertexData.length += 44;
			var spr:Sprite3D = new Sprite3D(
				vertexData,
				numSprites*44,
				leftU,
				topV,
				rightU,
				bottomV
			);
			spriteData.push(spr);
			
			numSprites++;
			
			vertexBuffer = __context3D.createVertexBuffer(numSprites*4, 11);
			indexBuffer = __context3D.createIndexBuffer(numSprites*6);
			needUpload = true;
			
			return spr;
		}
		
		/**
		 *   Remove all added sprites
		 */
		public function removeAllSprites(): void
		{
			numSprites = 0;
			vertexData.length = 0;
			indexData.length = 0;
			spriteData.length = 0;
			if (vertexBuffer)
			{
				vertexBuffer.dispose();
				indexBuffer.dispose();
			}
		}
		
		/**
		 *   Render the sprite to the 3D context
		 */
		public function render(): void
		{
			if (numSprites)
			{
				var needUpload:Boolean;
				for each (var data:Sprite3D in spriteData)
				{
					if (data.needsUpdate)
					{
						data.update();
						needUpload = true;
					}
				}
				
				if (needUpload)
				{
					vertexBuffer.uploadFromVector(vertexData, 0, numSprites*4);
					indexBuffer.uploadFromVector(indexData, 0, numSprites*6);
					needUpload = false;
				}
				
				// shader program for all sprites
				__context3D.setProgram(program);
				
				// texture of all sprites
				__context3D.setTextureAt(0, texture);
				
				// x, y, z, {unused}
				__context3D.setVertexBufferAt(0, vertexBuffer, 0, FLOAT3_FORMAT);
				
				// u, v, translationX, translationY
				__context3D.setVertexBufferAt(1, vertexBuffer, 3, FLOAT4_FORMAT);
				
				// scaleX, scaleY, cos(rotation), sin(rotation)
				__context3D.setVertexBufferAt(2, vertexBuffer, 7, FLOAT4_FORMAT);
				
				// draw all sprites
				__context3D.drawTriangles(indexBuffer, 0, numSprites*2);
			}
		}
		
		/**
		 *   Dispose of this sprite's resources
		 */
		public function dispose(): void
		{
			if (texture)
			{
				texture.dispose();
				texture = null;
			}
		}
	}
}