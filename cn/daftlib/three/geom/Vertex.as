package cn.daftlib.three.geom
{
	public class Vertex
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;

		public var screenX:Number;
		public var screenY:Number;
		
		public var x3d:Number;
		public var y3d:Number;
		public var z3d:Number;
		
		public var scale:Number;
		
		public function Vertex(x:Number, y:Number, z:Number)
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		public function dot(v:Vertex):Number 
		{
			return (x * v.x + y * v.y + v.z * z);
		}
		
		public function cross(v:Vertex):Vertex 
		{
			
			var tmpX:Number = (v.y * z) - (v.z * y);
			var tmpY:Number = (v.z * x) - (v.x * z);
			var tmpZ:Number = (v.x * y) - (v.y * x);
			
			return new Vertex(tmpX, tmpY, tmpZ);
		}
		
		public function get length():Number 
		{
			return Math.sqrt(x * x + y * y + z * z);
		}
	}
}