package cn.daftlib.utils
{
	public final class ArrayUtil
	{
		/**
		 * 打乱数组顺序，改变原数组
		 * @param target
		 */		
		public static function shuffle(target:Array):void
		{
			for(var i:uint=0; i<target.length; i++)
			{
				var j:int = Math.floor(target.length * Math.random());
				var a:* = target[i];
				var b:* = target[j];
				target[i] = b;
				target[j] = a;
			}
		}
		
		/**
		 * Quicksort, usage: ArrayUtil.quicksortByProperty(depthList, 0, depthList.length-1, "z");
		 * @param target
		 * @param lo
		 * @param hi
		 * @param propertyName
		 */		
		public static function quicksortByProperty(target:Array, lo:int, hi:int, propertyName:String):void
		{
			var i:int = lo;
			var j:int = hi;
			var buf:Array = target;
			var p:* = buf[(lo + hi) >> 1][propertyName];
			
			while( i <= j )
			{
				while( target[i][propertyName] > p ) i++;
				while( target[j][propertyName] < p ) j--;
				if( i <= j )
				{
					var t:* = buf[i];
					buf[i++] = buf[j];
					buf[j--] = t;
				}
			}
			if( lo < j ) quicksortByProperty(target, lo, j, propertyName);
			if( i < hi ) quicksortByProperty(target, i, hi, propertyName);
		}

		/**
		 * 交换数组元素位置
		 * @param $arr
		 * @param $indexA
		 * @param $indexB
		 */
		public static function switchElements(target:Array, indexA:uint, indexB:uint):void
		{
			var a:* = target[indexA];
			var b:* = target[indexB];
			target.splice(indexA, 1, b);
			target.splice(indexB, 1, a);
		}

		/**
		 * 数组去重，不修改原数组，返回去重后的新数组
		 * @param $arr
		 * @return
		 */
		public static function distinct(target:Array):Array
		{
			var obj:Object = {};
			return target.filter(function(item:*, index:int, array:Array):Boolean
			{
				return !obj[item] ? obj[item] = true : false
			});

			//该方法的实现过程是 对于"aa"来讲 obj["aa"]的值为undefined 
			//而!undefined为true,就会返回该成员，然后 将obj["aa"]的值设为true
			//下一次遇到obj["aa"]时，obj["aa"]的值为true，!obj["aa"]的值就为false
			//就不返回该成员。
		}

		/**
		 * 取得某一长度的数组内，索引A，索引B之间的最短距离
		 * @param startIndex
		 * @param targetIndex
		 * @param length
		 * @return
		 */
		public static function getShortDistance(startIndex:uint, targetIndex:uint, length:uint):int
		{
			var min:Number = Math.min(startIndex, targetIndex);
			var max:Number = Math.max(startIndex, targetIndex);
			
			if(max >= length)
				return int.MAX_VALUE;

			var dist:int = targetIndex - startIndex;
			if(Math.abs(dist) <= (length / 2))
				return dist;
			else
				return -dist / Math.abs(dist) * (min + length - max);
		}
	}
}