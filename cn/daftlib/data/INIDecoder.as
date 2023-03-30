package cn.daftlib.data
{
	public final class INIDecoder
	{
		public function INIDecoder(){}
		public function decode(str:String):Object
		{
			var obj:Object = {};
			var sectionKey:String = null;

			var lines:Array = str.split(/\r?\n/);
			var i:uint = 0;
			while(i < lines.length)
			{
				var line:String = lines[i];
				if(isComments(line))
				{
					//do nothing
				}
				else if(isSection(line))
				{
					sectionKey=getSection(line);
				}
				else if(isKey(line))
				{
					var key:String=getKey(line)[0];
					var value:String=getKey(line)[1];
					if(value.length == 0)
						value = null;
					
					if(sectionKey == null)
					{
						obj[key]=value;
					}
					else
					{
						if(obj[sectionKey] == undefined)
							obj[sectionKey] = {};
						
						obj[sectionKey][key] = value;
					}
					
					//trace(i, "-----", sectionKey,"-----", key, "-----",value);
				}

				i++;
			}

			return obj;
		}
		private function isComments(line:String):Boolean
		{
			var whiteLess:String=removeWhitespace(line);
			return whiteLess.indexOf(";")==0;
		}
		private function isSection(line:String):Boolean
		{
			var whiteLess:String=removeWhitespace(line);
			return whiteLess.indexOf("[")==0 && whiteLess.indexOf("]")>1;
		}
		private function isKey(line:String):Boolean
		{
			var whiteLess:String=removeWhitespace(line);
			return whiteLess.indexOf("=")>1;
		}
		private function getSection(line:String):String
		{
			var section:String=removeWhitespace(line);
			var firstIndex:int=section.indexOf("[");
			var lastIndex:int=section.lastIndexOf("]");
			section = section.substring(firstIndex+1, lastIndex);
			return section;
		}
		private function getKey(line:String):Array
		{
			var out:Array=[];
			var firstIndex:int=line.indexOf("=");
			var key:String=line.substr(0, firstIndex);
			out.push(removeWhitespace(key));
			out.push(line.substr(firstIndex+1, line.length));
			return out;
		}
		private function simpleRemove(target:String, remove:String):String
		{
			if(target.indexOf(remove) < 0)
				return target;

			return target.split(remove).join("");
		}
		private function removeWhitespace(source:String):String
		{
			var pattern:RegExp = new RegExp('[ \n\t\r]', 'g');
			return source.replace(pattern, '');
		}
	}
}