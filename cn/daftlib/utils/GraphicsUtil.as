package cn.daftlib.utils
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public final class GraphicsUtil
	{
		public static function simpleLinearGradient(g:Graphics, color:uint, color2:uint, angle:Number, width:Number, height:Number):void
		{
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [color, color2];
			var alphas:Array = [1, 1];
			var ratios:Array = [0x00, 0xFF];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(width, height, angle * Math.PI / 180, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
		}
		/**
		 * 画虚线
		 * @param $graphics 要draw的Graphics对象
		 * @param $pt1 起始点
		 * @param $pt2 截止点
		 * @param $length 线段长度
		 * @param $gap 线段间隔
		 */
		public static function drawDashed(g:Graphics, pt1:Point, pt2:Point, len:Number = 5, gap:Number = 5):void
		{
			var dist:Number = Point.distance(pt1, pt2);
			var pt3:Point;
			var pt4:Point;

			var i:Number = 0;
			while(i < dist)
			{
				pt3 = Point.interpolate(pt1, pt2, i / dist);
				i += len;

				if(i > dist)
					i = dist;

				pt4 = Point.interpolate(pt1, pt2, i / dist);

				g.moveTo(pt3.x, pt3.y);
				g.lineTo(pt4.x, pt4.y);

				i += gap;
			}
		}

		/**
		 * 画扇型
		 * @param $graphics 要draw的Graphics对象
		 * @param $center 圆心
		 * @param $r 半径
		 * @param $angle 扇型角度
		 * @param $startAngle 扇形开始的角度
		 */
		public static function drawCircularSector(g:Graphics, center:Point, radius:Number, angle:Number, startAngle:Number):void
		{
			var a:Number = (Math.abs(angle) > 360) ? 360 : angle;
			var n:Number = Math.ceil(Math.abs(a) / 45);
			var angleDelta:Number = a / n;
			angleDelta = angleDelta * Math.PI / 180;
			var sa:Number = startAngle * Math.PI / 180;

			g.moveTo(center.x, center.y);
			g.lineTo(center.x + radius * Math.cos(sa), center.y + radius * Math.sin(sa));

			var i:uint = 0;
			while(i < n)
			{
				sa += angleDelta;
				var angleMid:Number = sa - angleDelta / 2;
				var bx:Number = center.x + radius / Math.cos(angleDelta / 2) * Math.cos(angleMid);
				var by:Number = center.y + radius / Math.cos(angleDelta / 2) * Math.sin(angleMid);
				var cx:Number = center.x + radius * Math.cos(sa);
				var cy:Number = center.y + radius * Math.sin(sa);
				g.curveTo(bx, by, cx, cy);

				i++;
			}

			if(a != 360)
				g.lineTo(center.x, center.y);
		}

		/**
		 * 画封闭弧形
		 * @param $graphics 要draw的Graphics对象
		 * @param $center 圆心
		 * @param $r 半径
		 * @param $angle 扇型角度
		 * @param $startAngle 扇形开始的角度
		 */
		public static function drawCircularSegment(g:Graphics, center:Point, radius:Number, angle:Number, startAngle:Number, close:Boolean = false):void
		{
			var a:Number = (Math.abs(angle) > 360) ? 360 : angle;
			var n:Number = Math.ceil(Math.abs(a) / 45);
			var angleDelta:Number = a / n;
			angleDelta = angleDelta * Math.PI / 180;
			var sa:Number = startAngle * Math.PI / 180;

			g.moveTo(center.x + radius * Math.cos(sa), center.y + radius * Math.sin(sa));

			var i:uint = 0;
			while(i < n)
			{
				sa += angleDelta;
				var angleMid:Number = sa - angleDelta / 2;
				var bx:Number = center.x + radius / Math.cos(angleDelta / 2) * Math.cos(angleMid);
				var by:Number = center.y + radius / Math.cos(angleDelta / 2) * Math.sin(angleMid);
				var cx:Number = center.x + radius * Math.cos(sa);
				var cy:Number = center.y + radius * Math.sin(sa);
				g.curveTo(bx, by, cx, cy);

				i++;
			}

			if(a != 360 && close == true)
				g.lineTo(center.x + radius * Math.cos(startAngle * Math.PI / 180), center.y + radius * Math.sin(startAngle * Math.PI / 180));
		}

		/**
		 * 画缺角扇形
		 * @param $graphics 要draw的Graphics对象
		 * @param $center 圆心
		 * @param $r 外半径
		 * @param $r2 内半径
		 * @param $angle 扇型角度
		 * @param $startAngle  扇形开始的角度
		 */
		public static function drawScarceCircularSector(g:Graphics, center:Point, radius:Number, radius2:Number, angle:Number, startAngle:Number):void
		{
			var a:Number = (Math.abs(angle) > 360) ? 360 : angle;
			var n:Number = Math.ceil(Math.abs(a) / 45);
			var angleDelta:Number = a / n;
			angleDelta = angleDelta * Math.PI / 180;
			var sa:Number = startAngle * Math.PI / 180;
			
			var minRadius:Number=Math.min(radius, radius2);
			var maxRadius:Number=Math.max(radius, radius2);
			radius=maxRadius;
			radius2=minRadius;

			var startX:Number = center.x + radius2 * Math.cos(sa);
			var startY:Number = center.y + radius2 * Math.sin(sa);

			g.moveTo(startX, startY);
			g.lineTo(center.x + radius * Math.cos(sa), center.y + radius * Math.sin(sa));

			var angleMid:Number;
			var bx:Number;
			var by:Number;
			var cx:Number;
			var cy:Number;

			var i:uint = 0;
			while(i < n)
			{
				sa += angleDelta;
				angleMid = sa - angleDelta / 2;
				bx = center.x + radius / Math.cos(angleDelta / 2) * Math.cos(angleMid);
				by = center.y + radius / Math.cos(angleDelta / 2) * Math.sin(angleMid);
				cx = center.x + radius * Math.cos(sa);
				cy = center.y + radius * Math.sin(sa);
				g.curveTo(bx, by, cx, cy);

				i++;
			}

			g.lineTo(center.x + radius2 * Math.cos(sa), center.y + radius2 * Math.sin(sa));

			i = 0;
			while(i < n)
			{
				sa -= angleDelta;
				angleMid = sa + angleDelta / 2;
				bx = center.x + radius2 / Math.cos(angleDelta / 2) * Math.cos(angleMid);
				by = center.y + radius2 / Math.cos(angleDelta / 2) * Math.sin(angleMid);
				cx = center.x + radius2 * Math.cos(sa);
				cy = center.y + radius2 * Math.sin(sa);
				g.curveTo(bx, by, cx, cy);

				i++;
			}

			if(a != 360)
				g.lineTo(startX, startY);
		}

		/**
		 * 画正多边形
		 * @param $graphics
		 * @param $x
		 * @param $y
		 * @param $sides 边数
		 * @param $sideLength 每个边的长度
		 * @param $startAngle 开始绘制的角度
		 */
		public static function drawRegularPolygon(g:Graphics, center:Point, sides:uint, sideLength:Number, startAngle:Number):void
		{
			if(sides < 3)
				return;

			startAngle = startAngle * Math.PI / 180;

			// The angle formed between the segments from the polygon's center as shown in 
			// Figure 4-5. Since the total angle in the center is 360 degrees (2p radians),
			// each segment's angle is 2p divided by the number of sides.
			var angleDelta:Number = (2 * Math.PI) / sides;

			// Calculate the length of the radius that circumscribes the polygon (which is
			// also the distance from the center to any of the vertices).
			var radius:Number = (sideLength / 2) / Math.sin(angleDelta / 2);

			// The starting point of the polygon is calculated using trigonometry where 
			// radius is the hypotenuse and $rotation is the angle.
			var px:Number = (Math.cos(startAngle) * radius) + center.x;
			var py:Number = (Math.sin(startAngle) * radius) + center.y;

			// Move to the starting point without yet drawing a line.
			g.moveTo(px, py);

			// Draw each side. Calculate the vertex coordinates using the same trigonometric
			// ratios used to calculate px and py earlier.
			for(var i:Number = 1; i <= sides; i++)
			{
				px = (Math.cos((angleDelta * i) + startAngle) * radius) + center.x;
				py = (Math.sin((angleDelta * i) + startAngle) * radius) + center.y;
				g.lineTo(px, py);
			}
		}

		/**
		 * 画星星
		 * @param $graphics
		 * @param $x
		 * @param $y
		 * @param $points 星星的角数
		 * @param $innerRadius 内半径
		 * @param $outerRadius 外半径
		 * @param $rotation
		 */
		public static function drawStar(g:Graphics, center:Point, points:uint, radius:Number, radius2:Number, startAngle:Number):void
		{
			if(points < 3)
				return;

			var angleDelta:Number = (Math.PI * 2) / points;
			startAngle = Math.PI * (startAngle) / 180;

			var angle:Number = startAngle;
			
			var minRadius:Number=Math.min(radius, radius2);
			var maxRadius:Number=Math.max(radius, radius2);
			radius2=maxRadius;
			radius=minRadius;

			var px:Number = center.x + Math.cos(angle + angleDelta / 2) * radius;
			var py:Number = center.y + Math.sin(angle + angleDelta / 2) * radius;

			g.moveTo(px, py);

			angle += angleDelta;

			for(var i:Number = 0; i < points; i++)
			{
				px = center.x + Math.cos(angle) * radius2;
				py = center.y + Math.sin(angle) * radius2;
				g.lineTo(px, py);
				px = center.x + Math.cos(angle + angleDelta / 2) * radius;
				py = center.y + Math.sin(angle + angleDelta / 2) * radius;
				g.lineTo(px, py);
				angle += angleDelta;
			}
		}

		/**
		 * 画圆角多边形
		 * @param $graphics
		 * @param $pointsVec
		 * @param $ellipseSize
		 */
		public static function drawRoundShape(g:Graphics, pointsVec:Vector.<Point>, ellipseSize:Number, cubicCurve:Boolean = true):void
		{
			if(pointsVec.length < 3)
				return;

			var px:Number;
			var py:Number;

			var i:uint = 0;
			while(i < pointsVec.length)
			{
				var index0:uint = i;
				var index1:uint = i + 1;
				var index2:uint = i + 2;

				index1 = index1 >= pointsVec.length ? index1 - pointsVec.length : index1;
				index2 = index2 >= pointsVec.length ? index2 - pointsVec.length : index2;

				var p0:Point = pointsVec[index0];
				var p1:Point = pointsVec[index1];
				var p2:Point = pointsVec[index2];

				var distA:Number = Point.distance(p0, p1);
				var distB:Number = Point.distance(p1, p2);

				var f1:Number = ellipseSize / distA;
				var f2:Number = ellipseSize / distB;

				var pen0:Point = Point.interpolate(p0, p1, 1 - f1);
				var pen1:Point = Point.interpolate(p0, p1, f1);
				var pen2:Point = Point.interpolate(p1, p2, 1 - f2);

				var control0:Point = Point.interpolate(p0, p1, f1 * .5);
				var control1:Point = Point.interpolate(p1, p2, 1 - f2 * .5);

				if(cubicCurve == false)
					control0 = p1;

				if(i == 0)
					g.moveTo(pen0.x, pen0.y);

				g.lineTo(pen1.x, pen1.y);

				if(cubicCurve == true)
					g.cubicCurveTo(control0.x, control0.y, control1.x, control1.y, pen2.x, pen2.y);
				else
					g.curveTo(control0.x, control0.y, pen2.x, pen2.y);

				i++;
			}
		}
	}
}