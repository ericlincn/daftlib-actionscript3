package cn.daftlib.three.uitls
{
	import cn.daftlib.three.geom.Face;
	import cn.daftlib.three.geom.Vertex;
	import cn.daftlib.three.objects.Mesh;
	import cn.daftlib.three.objects.PointCamera;
	import cn.daftlib.utils.GeomUtil;

	public class ProjectionUtil
	{
		public static function project(meshList:Array, camera:PointCamera):Array 
		{
			var camRotoX:Number=GeomUtil.degreesToRadians(camera.rotationX);
			var camRotoY:Number=GeomUtil.degreesToRadians(camera.rotationY);
			var camRotoZ:Number=GeomUtil.degreesToRadians(camera.rotationZ);
			
			// cam rotation
			var cosZ:Number = Math.cos(camRotoZ);
			var sinZ:Number = Math.sin(camRotoZ);
			var cosY:Number = Math.cos(camRotoY);
			var sinY:Number = Math.sin(camRotoY);
			var cosX:Number = Math.cos(camRotoX);
			var sinX:Number = Math.sin(camRotoX);
			/*
			// the quarternion way...			
			var tmpQuat:Quaternion = new Quaternion();
			tmpQuat.eulerToQuaternion(-cam.deltaAngleX, -cam.deltaAngleY, -cam.deltaAngleZ);
			cam.quaternion.concat(tmpQuat);
			cam.deltaAngleX = 0;
			cam.deltaAngleY = 0;
			cam.deltaAngleZ = 0;
			*/
			// local rotation
			/**/
			var cosZMesh:Number;
			var sinZMesh:Number;
			var cosYMesh:Number;
			var sinYMesh:Number;
			var cosXMesh:Number;
			var sinXMesh:Number;
			
			var i:uint = meshList.length;
			var j:uint;
			var curMesh:Mesh;
			var curVertex:Vertex;
			var x:Number;
			var y:Number;
			var x1:Number;
			var x2:Number;
			var x3:Number;
			var x4:Number;
			var y1:Number;
			var y2:Number;
			var y3:Number;
			var y4:Number;
			var z1:Number;
			var z2:Number;
			var z3:Number;
			var z4:Number;
			var scale:Number;
			var faceList:Array = [];
			var vertexList:Array = [];
			
			var meshRotoX:Number;
			var meshRotoY:Number;
			var meshRotoZ:Number;
			
			while(--i > -1) 
			{ 
				// step through meshes
				
				curMesh = meshList[i];
				
				faceList = faceList.concat(curMesh.faceList);
				vertexList = curMesh.vertexList;
				
				j = vertexList.length;
				
				meshRotoX = GeomUtil.degreesToRadians(curMesh.rotationX);
				meshRotoY = GeomUtil.degreesToRadians(curMesh.rotationY);
				meshRotoZ = GeomUtil.degreesToRadians(curMesh.rotationZ);
				
				cosZMesh = Math.cos(meshRotoZ);
				sinZMesh = Math.sin(meshRotoZ);
				cosYMesh = Math.cos(meshRotoY);
				sinYMesh = Math.sin(meshRotoY);
				cosXMesh = Math.cos(meshRotoX);
				sinXMesh = Math.sin(meshRotoX);
				
				/*
				// rotation
				// the quarternion way...
				tmpQuat = new Quaternion();
				tmpQuat.eulerToQuaternion(curMesh.deltaAngleX, curMesh.deltaAngleY, curMesh.deltaAngleZ);
				curMesh.quaternion.concat(tmpQuat);
				curMesh.deltaAngleX = 0;
				curMesh.deltaAngleY = 0;
				curMesh.deltaAngleZ = 0;
				*/
				while(--j > -1) 
				{ 
					// step through vertexlist
					
					curVertex = vertexList[j];
					/*					
					// the quarternion way...
					tmpVertex = curVertex.clone();
					tmpVertex = curVertex.rotatePoint(curMesh.quaternion);
					x2 = tmpVertex.x;
					y2 = tmpVertex.y;
					z2 = tmpVertex.z;
					*/					
					// local coordinate rotation x,y,z					
					// z axis
					x1 = (curVertex.x * curMesh.scaleX) * cosZMesh - (curVertex.y * curMesh.scaleY) * sinZMesh;
					y1 = (curVertex.y * curMesh.scaleY) * cosZMesh + (curVertex.x * curMesh.scaleX) * sinZMesh;
					// y axis
					x2 = x1 * cosYMesh - (curVertex.z * curMesh.scaleZ) * sinYMesh;
					z1 = (curVertex.z * curMesh.scaleZ) * cosYMesh + x1 * sinYMesh;
					// x axis
					y2 = y1 * cosXMesh - z1 * sinXMesh;
					z2 = z1 * cosXMesh + y1 * sinXMesh;
					
					// local coordinate movement
					x2 += curMesh.x;
					y2 += curMesh.y;
					z2 += curMesh.z;
					
					// camera movement -minus because we must get to 0,0,0
					x2 -= camera.x;
					y2 -= camera.y;
					z2 -= camera.z;
					
					// camera view rotation x,y,z
					x3 = x2 * cosZ - y2 * sinZ;
					y3 = y2 * cosZ + x2 * sinZ;
					
					x4 = x3 * cosY - z2 * sinY;
					z3 = z2 * cosY + x3 * sinY;
					
					y4 = y3 * cosX - z3 * sinX;
					z4 = z3 * cosX + y3 * sinX;
					/*
					// the quarternion way...
					tmpVertex = new Vertex(x2, y2, z2);
					tmpVertex = tmpVertex.rotatePoint(cam.quaternion);
					x4 = tmpVertex.x;
					y4 = tmpVertex.y;
					z4 = tmpVertex.z;
					*/					
					// final screen coordinates (3d to 2d)
					scale = camera.focalLength / (camera.focalLength + z4 + camera.zOffset);
					x = camera.vanishingPointX + x4 * scale;
					y = camera.vanishingPointY + y4 * scale;
					
					curVertex.screenX = x;
					curVertex.screenY = y;
					// for texture
					curVertex.scale = scale;
					
					// for lighting
					curVertex.x3d = x4;
					curVertex.y3d = y4;
					curVertex.z3d = z4;
				}
			}
			
			// sort
			faceList = faceList.sort(faceZSort);
			
			return faceList;
		}
		private static function faceZSort(fa:Face, fb:Face):int 
		{
			var za:Number = (fa.vertex1.z3d + fa.vertex2.z3d + fa.vertex3.z3d) / 3;
			var zb:Number = (fb.vertex1.z3d + fb.vertex2.z3d + fb.vertex3.z3d) / 3;
			
			if(za > zb) 
			{
				return -1;
			}
			else 
			{
				return 1;
			}
		}
	}
}