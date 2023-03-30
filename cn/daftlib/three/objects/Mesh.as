package cn.daftlib.three.objects
{
	import flash.utils.Dictionary;
	
	import cn.daftlib.three.geom.Face;
	import cn.daftlib.three.geom.Object3D;
	import cn.daftlib.three.geom.Vertex;

	public class Mesh extends Object3D
	{
		protected var __faceList:Array;
		protected var __vertexList:Array;
		
		public function Mesh()
		{
			super();
			
			__faceList = [];
			__vertexList = [];
		}
		public function addFace(face:Face):void 
		{
			__faceList.push(face);
			__vertexList.push(face.vertex1, face.vertex2, face.vertex3);
		}

		public function get vertexList():Array
		{
			return __vertexList;
		}

		public function get faceList():Array
		{
			return __faceList;
		}
		
		protected function optimizeVertices(tolerance:Number = 1):void	
		{
			
			trace("before: " + vertexList.length);
			
			var i:uint;
			var uniqueList:Dictionary = new Dictionary();
			var v:Vertex;
			var uniqueV:Vertex;
			var f:Face;
			
			// fill unique listing
			for(i = 0;i < vertexList.length; i++) 
			{
				v = vertexList[i];
				uniqueList[v] = v;
			}
			
			// step through vertices and find duplicates vertices
			for(i = 0;i < vertexList.length; i++) 
			{
				
				v = vertexList[i];
				
				for each(uniqueV in uniqueList) 
				{
					
					if(	Math.abs(v.x - uniqueV.x) <= tolerance && Math.abs(v.y - uniqueV.y) <= tolerance && Math.abs(v.z - uniqueV.z) <= tolerance) 
					{
						
						uniqueList[v] = uniqueV; // replace vertice with unique one
					}
				}
			}
			
			__vertexList = [];
			
			for each(f in faceList)	
			{
				f.vertex1 = uniqueList[f.vertex1];
				f.vertex2 = uniqueList[f.vertex2];
				f.vertex3 = uniqueList[f.vertex3];
				
				vertexList.push(f.vertex1);
				vertexList.push(f.vertex2);
				vertexList.push(f.vertex3);
			}
			
			trace("after: " + vertexList.length);
		}
	}
}