package cn.daftlib.three.uitls
{
	import cn.daftlib.three.geom.Face;
	import cn.daftlib.three.geom.Vertex;
	import cn.daftlib.three.objects.PointCamera;

	public class MaterialUtil
	{
		public static function getColor(color:int, face:Face, camera:PointCamera):Number 
		{
			// dynamic lighting
			var r:uint = color >> 16;
			var g:uint = color >> 8 & 0xFF;
			var b:uint = color & 0xFF;
			
			var lightVertex:Vertex = new Vertex(camera.x, camera.y, camera.z - camera.zOffset);
			
			var v1:Vertex = new Vertex(face.vertex1.x3d - face.vertex2.x3d, face.vertex1.y3d - face.vertex2.y3d, face.vertex1.z3d - face.vertex2.z3d);
			var v2:Vertex = new Vertex(face.vertex2.x3d - face.vertex3.x3d, face.vertex2.y3d - face.vertex3.y3d, face.vertex2.z3d - face.vertex3.z3d);
			
			var norm:Vertex = v1.cross(v2);
			
			var lightIntensity:Number = norm.dot(lightVertex);
			var normMag:Number = norm.length;
			var lightMag:Number = lightVertex.length;
			
			var factor:Number = (Math.acos(lightIntensity / (normMag * lightMag)) / Math.PI); 
			
			r *= factor;
			g *= factor;
			b *= factor;
			
			return (r << 16 | g << 8 | b);
		}
	}
}