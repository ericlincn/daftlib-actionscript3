package cn.daftlib.three.geom
{
	public class Object3D
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var z:Number = 0;
		
		private var __angleX:Number = 0;
		private var __angleY:Number = 0;
		private var __angleZ:Number = 0;
		
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var scaleZ:Number = 1;
		
		public function Object3D(){}
		
		public function set rotationX(angle:Number):void 
		{
			__angleX = angle;
		}
		public function get rotationX():Number 
		{
			return __angleX;
		}
		public function set rotationY(angle:Number):void 
		{
			__angleY = angle;
		}
		public function get rotationY():Number 
		{
			return __angleY;
		}
		public function set rotationZ(angle:Number):void 
		{
			__angleZ = angle;
		}
		public function get rotationZ():Number 
		{
			return __angleZ;
		}
	}
}