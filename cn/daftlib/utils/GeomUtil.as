package cn.daftlib.utils
{
	import flash.geom.Point;

	public final class GeomUtil
	{
		public static const PI:Number = 3.141592653589793;
		public static const HALF_PI:Number = PI / 2 ;
		public static const TWO_PI:Number = PI * 2 ;
		
		public static const toRADIANS:Number = PI / 180;
		public static const toDEGREES:Number = 180 / PI;
		
		/**
		 * Calculates a scale value to maintain aspect ratio and fill the required
		 * bounds (with the possibility of cutting of the edges a bit).
		 */
		public static function getScaleRatioToFill(originalWidth:Number, originalHeight:Number, targetWidth:Number, targetHeight:Number):Number
		{
			var widthRatio:Number = targetWidth / originalWidth;
			var heightRatio:Number = targetHeight / originalHeight;
			return Math.max(widthRatio, heightRatio);
		}
		/**
		 * Calculates a scale value to maintain aspect ratio and fit inside the
		 * required bounds (with the possibility of a bit of empty space on the edges).
		 */
		public static function getScaleRatioToFit(originalWidth:Number, originalHeight:Number, targetWidth:Number, targetHeight:Number):Number
		{
			var widthRatio:Number = targetWidth / originalWidth;
			var heightRatio:Number = targetHeight / originalHeight;
			return Math.min(widthRatio, heightRatio);
		}
		/**
		 * Converts degrees to radians.
		 * @param $degrees
		 * @return
		 */
		public static function degreesToRadians(degrees:Number):Number
		{
			return degrees * toRADIANS;
		}

		/**
		 * Converts radians to degrees.
		 * @param $radians
		 * @return
		 */
		public static function radiansToDegrees(radians:Number):Number
		{
			return radians * toDEGREES;
		}

		/**
		 * 得到(椭)圆上点的坐标
		 * @param $center
		 * @param $angleInDegrees
		 * @param $radius
		 * @return
		 */
		public static function getPositionOnCircle(centerX:Number, centerY:Number, angleInDegrees:Number, radiusX:Number, radiusY:Number):Point
		{
			var radians:Number = degreesToRadians(angleInDegrees);

			return new Point(centerX + Math.cos(radians) * radiusX, centerY + Math.sin(radians) * radiusY);
		}
		
		/**
		 * 求圆心(0, 0)正圆点上的坐标；将角速度分解；将角加速分解
		 * @param angleInDegrees
		 * @param length
		 * @return 
		 */		
		public static function getResolutionByVector(angleInDegrees:Number, length:Number):Point
		{
			return getPositionOnCircle(0, 0, angleInDegrees, length, length);
		}

		/**
		 * 取得两点中点
		 * @param $point1
		 * @param $point2
		 * @return
		 */
		public static function getMiddlePoint(point1:Point, point2:Point):Point
		{
			return Point.interpolate(point1, point2, .5);
		}

		/**
		 * 取得线的角度
		 * @param $point1
		 * @param $point2
		 * @return
		 */
		public static function getAngle(point1:Point, point2:Point):Number
		{
			var offsetX:Number = point2.x - point1.x;
			var offsetY:Number = point1.y - point2.y;
			var angle:Number = Math.atan2(offsetY, offsetX) * (180 / Math.PI);

			return angle;
		}

		/**
		 * Take a degree measure and make sure it is between 0..360.
		 * @param $degrees
		 * @return
		 */
		public static function unwrapDegrees(degrees:Number):Number
		{
			while(degrees > 360)
				degrees -= 360;
			while(degrees < 0)
				degrees += 360;

			return degrees;
		}

		/**
		 * Return the shortest distance to get from from to to, in degrees.
		 * @param $from
		 * @param $to
		 * @return
		 */
		public static function getDegreesShortDelta(from:Number, to:Number):Number
		{
			// Unwrap both from and to.
			from = unwrapDegrees(from);
			to = unwrapDegrees(to);

			// Calc delta.
			var delta:Number = to - from;

			// Make sure delta is shortest path around circle.
			if(delta > 180)
				delta -= 360;
			if(delta < -180)
				delta += 360;

			return delta;
		}

		/**
		 * 判断两线段是否相交
		 * @param $point1
		 * @param $point2
		 * @param $point3
		 * @param $point4
		 * @return
		 */
		public static function getIntersect(point1:Point, point2:Point, point3:Point, point4:Point):Point
		{
			var v1:Point = new Point();
			var v2:Point = new Point();
			var d:Number;
			var intersectPoint:Point = new Point();

			v1.x = point2.x - point1.x;
			v1.y = point2.y - point1.y;
			v2.x = point4.x - point3.x;
			v2.y = point4.y - point3.y;

			d = v1.x * v2.y - v1.y * v2.x;
			if(d == 0)
			{
				//points are collinear
				return null;
			}

			var a:Number = point3.x - point1.x;
			var b:Number = point3.y - point1.y;
			var t:Number = (a * v2.y - b * v2.x) / d;
			var s:Number = (b * v1.x - a * v1.y) / -d;
			if(t < 0 || t > 1 || s < 0 || s > 1)
			{
				//line segments don't intersect
				return null;
			}

			intersectPoint.x = point1.x + v1.x * t;
			intersectPoint.y = point1.y + v1.y * t;
			return intersectPoint;
		}
		/**
		 * 获取两正圆公切线,返回值可能为null或2条外切线或2条外切线+2条内切线
		 * @param x1
		 * @param y1
		 * @param radius1
		 * @param x2
		 * @param y2
		 * @param radius2
		 * @return 
		 */		
		public static function getTangents(x1:Number, y1:Number, radius1:Number, x2:Number, y2:Number, radius2:Number):Array
		{
			var dsq:Number = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
			if (dsq <= (radius1 - radius2) * (radius1 - radius2)) return null;
			
			var d:Number = Math.sqrt(dsq);
			var vx:Number = (x2 - x1) / d;
			var vy:Number = (y2 - y1) / d;
			
			var result:Array = [];
			var i:int = 0;
			
			// Let A, B be the centers, and C, D be points at which the tangent
			// touches first and second circle, and n be the normal vector to it.
			//
			// We have the system:
			//   n * n = 1          (n is a unit vector)          
			//   C = A + r1 * n
			//   D = B +/- r2 * n
			//   n * CD = 0         (common orthogonality)
			//
			// n * CD = n * (AB +/- r2*n - r1*n) = AB*n - (r1 -/+ r2) = 0,  <=>
			// AB * n = (r1 -/+ r2), <=>
			// v * n = (r1 -/+ r2) / d,  where v = AB/|AB| = AB/d
			// This is a linear equation in unknown vector n.
			
			//for (var sign1:int = +1; sign1 >= -1; sign1 -= 2)
			var sign1:int = 1;
			while(sign1 >= -1)
			{
				var c:Number = (radius1 - sign1 * radius2) / d;
				
				// Now we're just intersecting a line with a circle: v*n=c, n*n=1
				
				if (c * c > 1.0)
				{
					sign1 -= 2;
					continue;
				}
				
				var h:Number = Math.sqrt(Math.max(0.0, 1.0 - c*c));
				
				var sign2:int = 1;
				//for (var sign2:int = +1; sign2 >= -1; sign2 -= 2)
				while(sign2 >= -1)
				{
					var nx:Number = vx * c - sign2 * h * vy;
					var ny:Number = vy * c + sign2 * h * vx;
					
					var a:Array = result[i++] = [];
					a[0] = new Point(x1 + radius1 * nx, y1 + radius1 * ny);
					a[1] = new Point(x2 + sign1 * radius2 * nx, y2 + sign1 * radius2 * ny);
					
					sign2 -= 2;
				}
				
				sign1 -= 2;
			}
			
			return result;
		}
	}
}