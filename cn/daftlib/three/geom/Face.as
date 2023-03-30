package cn.daftlib.three.geom
{
	import cn.daftlib.three.material.Material;

	public class Face
	{
		public var vertex1:Vertex;
		public var vertex2:Vertex;
		public var vertex3:Vertex;
		
		public var material:Material;
		public var uvMap:Array;
		
		public function Face(vertex1:Vertex, vertex2:Vertex, vertex3:Vertex, material:Material = null, uvMap:Array = null)
		{
			this.vertex1 = vertex1;
			this.vertex2 = vertex2;
			this.vertex3 = vertex3;
			
			this.material = material;
			this.uvMap = uvMap;
		}
	}
}