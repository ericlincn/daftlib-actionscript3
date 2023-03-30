package cn.daftlib.data
{
	//import flash.utils.Proxy;
	//import flash.utils.flash_proxy;

	public final dynamic class PaginatedArray extends Array
	{
		private var __pageSize:uint = 1;
		private var __totalPages:uint;
		private var __currentPage:int = 0;

		public function PaginatedArray(... parameters)
		{
			//super(parameters);
			super();

			if(parameters is Array)
			{
				for each(var item:* in parameters)
				{
					this.push(item);
				}
			}
		}
		override AS3 function concat(... parameters):Array
		{
			var out:Array = super.concat.apply(this, parameters);
			updateArrayLength();
			return out;
		}
		override AS3 function push(... parameters):uint
		{
			var len:uint = super.push.apply(this, parameters);
			updateArrayLength();
			return len;
		}
		override AS3 function pop():*
		{
			var out:* = super.pop.apply(this);
			updateArrayLength();
			return out;
		}
		override AS3 function shift():*
		{
			var out:* = super.shift.apply(this);
			updateArrayLength();
			return out;
		}
		override AS3 function splice(... parameters):*
		{
			var out:* = super.splice.apply(this, parameters);
			updateArrayLength();
			return out;
		}
		override AS3 function unshift(... parameters):uint
		{
			var out:* = super.unshift.apply(this, parameters);
			updateArrayLength();
			return out;
		}
		public function set pageSize(value:uint):void
		{
			if(value < 1)
			{
				throw new ArgumentError("$pageSize can't be less than 1.");
				return;
			}

			__pageSize = value;

			updateArrayLength();
		}
		public function get totalPages():uint
		{
			return __totalPages;
		}
		public function get currentPage():uint
		{
			return __currentPage;
		}
		public function gotoPage(pageIndex:uint):Array
		{
			if(pageIndex >= __totalPages)
			{
				throw new ArgumentError("$pageIndex should be less than totalPages.");
				return null;
			}
			__currentPage = pageIndex;

			var outArr:Array = [];
			var startIndex:uint = __pageSize * __currentPage;
			var edgeIndex:uint = __pageSize * __currentPage + __pageSize;
			if(edgeIndex > this.length)
				edgeIndex = this.length;
			while(startIndex < edgeIndex)
			{
				outArr.push(this[startIndex]);

				startIndex++;
			}
			return outArr;
		}
		public function gotoFirstPage():Array
		{
			return gotoPage(0);
		}
		public function gotoLastPage():Array
		{
			return gotoPage(__totalPages - 1);
		}
		public function gotoNextPage():Array
		{
			if(__currentPage >= __totalPages - 1)
				return null;
			else
				return gotoPage(__currentPage + 1);
		}
		public function gotoPrevPage():Array
		{
			if(__currentPage <= 0)
				return null;
			else
				return gotoPage(__currentPage - 1);
		}
		private function updateArrayLength():void
		{
			__totalPages = Math.ceil(this.length / __pageSize);
		}
		/*override flash_proxy function callProperty($methodName:*, ...parameters):*
		{
			var res:*;
			switch ($methodName.toString())
			{
				case 'clear':
					__array = new Array();
					break;
				case 'sum':
					var sum:Number = 0;
					for each (var i:* in _item)
					{
						// ignore non-numeric values
						if (!isNaN(i)) {
							sum += i;
						}
					}
					res = sum;
					break;
				default:
					res = __array[$methodName].apply(__array, parameters);
					break;
			}
			return res;
		}
		override flash_proxy function getProperty(name:*):*
		{
			return __array[name];
		}
		override flash_proxy function setProperty(name:*, value:*):void
		{
			__array[name]=value;
		}*/
	}
}