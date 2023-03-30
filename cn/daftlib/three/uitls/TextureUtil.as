package cn.daftlib.three.uitls
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import cn.daftlib.three.geom.Face;
	import cn.daftlib.three.geom.Vertex;
	import cn.daftlib.three.material.Material;

	public class TextureUtil
	{
		/**
		 * renders a textured triangle (original code by Andre Michelle, www.andre-michelle.com)
		 * @param graphics object
		 * @param material
		 * @param face 1st vertex
		 * @param face 2nd vertex
		 * @param face 3rd vertex
		 * @param array of 3 UV-map instances
		 * @param between 0 and 1, defines the strength of the light
		 * @param ambient color
		 */
		public static function renderUV(canvas:Sprite, material:Material, face:Face, colorFactor:Number, ambientColor:uint):void 
		{
			var a:Vertex=face.vertex1;
			var b:Vertex=face.vertex2;
			var c:Vertex=face.vertex3;
			var uvMap:Array=face.uvMap;
			
			var x0:Number = a.screenX;
			var y0:Number = a.screenY;
			var x1:Number = b.screenX;
			var y1:Number = b.screenY;
			var x2:Number = c.screenX;
			var y2:Number = c.screenY;
			
			var texture:BitmapData = material.texture;
			
			var w:Number = texture.width;
			var h:Number = texture.height;
			
			var u0:Number = uvMap[0].u * w;
			var v0:Number = uvMap[0].v * h;
			var u1:Number = uvMap[1].u * w;
			var v1:Number = uvMap[1].v * h;
			var u2:Number = uvMap[2].u * w;
			var v2:Number = uvMap[2].v * h;
			
			var sMat:Matrix = new Matrix();
			var tMat:Matrix = new Matrix();
			
			tMat.tx = u0;
			tMat.ty = v0;
			
			tMat.a = (u1 - u0) / w;
			tMat.b = (v1 - v0) / w;
			tMat.c = (u2 - u0) / h;
			tMat.d = (v2 - v0) / h;
			
			sMat.a = (x1 - x0) / w;
			sMat.b = (y1 - y0) / w;
			sMat.c = (x2 - x0) / h;
			sMat.d = (y2 - y0) / h;
			
			sMat.tx = x0;
			sMat.ty = y0;
			
			tMat.invert();
			tMat.concat(sMat);
			
			var smoothing:Boolean = material.smoothed;
			// check if points are not to close to each other, disable smoothing
			// beginBitmapFill draw bug?!
			if(smoothing) 
			{ 
				var dx:Number = x1 - x0;
				var dx2:Number = x2 - x1;
				var dy:Number = y1 - y0;
				var dy2:Number = y2 - y1;
				
				if(Math.abs(dx / dy - dx2 / dy2) < 1) 
				{
					smoothing = false;
				}
			}
			
			var gfx:Graphics = canvas.graphics;
			
			gfx.beginBitmapFill(texture, tMat, false, smoothing);
			gfx.moveTo(x0, y0);
			gfx.lineTo(x1, y1);
			gfx.lineTo(x2, y2);
			gfx.lineTo(x0, y0);
			gfx.endFill();
			
			if(material.calculateLights && colorFactor < 1) 
			{
				gfx.beginFill(ambientColor, 1 - colorFactor);
				gfx.moveTo(x0, y0);
				gfx.lineTo(x1, y1);
				gfx.lineTo(x2, y2);
				gfx.lineTo(x0, y0);
				gfx.endFill();
			}
		}
	}
}