package cn.daftlib.utils
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public final class TextFieldUtil
	{
		/**
		 * 在固定尺寸里面生成一个具有文本的TextField， 这个TextField拥有尽可能大的字号，同时确保不超出固定尺寸
		 * @param $text
		 * @param $font 字体
		 * @param $maxWidth 固定尺寸的宽度
		 * @param $maxHeight 固定尺寸的最大高度
		 * @return
		 */
		public static function getMaxSizedTextField($text:String, $font:String, $maxWidth:Number, $maxHeight:Number):TextField
		{
			var opTF:TextField = new TextField();
			opTF.autoSize = TextFieldAutoSize.LEFT;
			opTF.width = $maxWidth;
			opTF.wordWrap = true;

			var format:TextFormat = new TextFormat();
			format.font = $font;

			var enter:String = "\n";
			var fontSizeResult:uint;
			var fontSize:uint = 1;

			while(fontSize < uint.MAX_VALUE)
			{
				format.size = fontSize;
				opTF.defaultTextFormat = format;
				opTF.text = $text;

				if(opTF.height > $maxHeight)
				{
					fontSizeResult = (fontSize - 1);
					if(fontSizeResult == 0)
						return null;

					format.size = fontSizeResult;
					opTF.defaultTextFormat = format;
					opTF.text = $text;
					//trace(fontSizeResult, opTF.height)

					var resultStr:String = "";
					var numLines:uint = opTF.numLines;
					var i:uint = 0;
					while(i < numLines)
					{
						if(i == (numLines - 1))
							resultStr += opTF.getLineText(i);
						else
							resultStr += opTF.getLineText(i) + enter;

						i++;
					}

					//trace(resultStr)
					opTF.text = resultStr;

					break;
				}
				fontSize++;
			}

			return opTF;
		}
	}
}