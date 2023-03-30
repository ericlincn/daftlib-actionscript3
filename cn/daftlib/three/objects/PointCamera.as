package cn.daftlib.three.objects
{
	import cn.daftlib.three.geom.Object3D;
	import cn.daftlib.utils.GeomUtil;

	public class PointCamera extends Object3D
	{
		public var zOffset:Number = 0;
		
		private var __zoom:Number;
		private var __focalLength:Number;
		
		private var __vanishingPointX:Number;
		private var __vanishingPointY:Number;
		
		public function PointCamera(vanishingPointX:Number, vanishingPointY:Number, fov:Number=75, zoom:Number=1)
		{
			super();
			
			__vanishingPointX = vanishingPointX;
			__vanishingPointY = vanishingPointY;
			//__focalLength = focalLength;
			__zoom = zoom;
			
			this.fov=75;
		}

		public function get focalLength():Number
		{
			return __focalLength;
		}

		public function get vanishingPointX():Number
		{
			return __vanishingPointX;
		}

		public function get vanishingPointY():Number
		{
			return __vanishingPointY;
		}

		private function maintainAngle(angle:Number):Number 
		{
			if(Math.abs(angle) >= GeomUtil.PI) 
			{
				if(angle < 0) 
				{
					angle += GeomUtil.PI * 2;
				}
				else 
				{
					angle -= GeomUtil.PI * 2;
				}
			}
			
			return angle;
		}
		public function follow(target:Object3D, speed:Number, turnSpeed:Number):void
		{
			var diffZ:Number = (target.rotationX - this.rotationZ);
			var diffY:Number = (-target.rotationY - this.rotationY + GeomUtil.degreesToRadians(90));
			var diffX:Number = (target.rotationZ - this.rotationX);
			
			// avoid large gaps from -180 to 180, dirrrty test...
			diffZ = maintainAngle(diffZ);
			diffY = maintainAngle(diffY);
			diffX = maintainAngle(diffX);
			
			this.rotationZ += diffZ * turnSpeed;
			this.rotationY += diffY * turnSpeed;
			this.rotationX += diffX * turnSpeed;
			
			// limit to 0 - 360 ... the gap thing
			this.rotationZ = this.rotationZ % (GeomUtil.PI * 2);
			this.rotationY = this.rotationY % (GeomUtil.PI * 2);
			this.rotationX = this.rotationX % (GeomUtil.PI * 2);
			
			x += (target.x - x) * speed;
			y += (target.y - y) * speed;
			z += (target.z - z) * speed;
		}
		
		public function set fov(degrees:Number):void
		{
			var tx	:Number = 0;
			var ty	:Number = 0;
			var tz	:Number = 0;
			
			//var vx	:Number = this.x - tx;
			//var vy	:Number = this.y - ty;
			//var vz	:Number = this.z - tz;
			
			var h:Number = __vanishingPointY;
			//var d:Number = Math.sqrt(vx*vx + vy*vy + vz*vz) + this.focus;
			//var r:Number = 180 / Math.PI;
			
			var vfov:Number = (degrees/2) * (Math.PI/180);
			
			__focalLength = (h / Math.tan(vfov)) / __zoom;
		}
		public function get fov():Number
		{
			var tx	:Number = 0;
			var ty	:Number = 0;
			var tz	:Number = 0;
			
			var vx	:Number = this.x - tx;
			var vy	:Number = this.y - ty;
			var vz	:Number = this.z - tz;
			
			var f	:Number = __focalLength;
			var z	:Number = __zoom;
			var d	:Number = Math.sqrt(vx*vx + vy*vy + vz*vz) + f;	// distance along camera's z-axis
			var h	:Number = __vanishingPointY;
			var r	:Number = (180/Math.PI);
			
			return Math.atan((((d / f) / z) * h) / d) * r * 2;
		}

	}
}