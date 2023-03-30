package cn.daftlib.utils
{
	public final class FlashVarUtil
	{
		public static function getValue(key:String):String
		{
			return StageReference.stage.loaderInfo.parameters[key];
		}
		public static function hasKey(key:String):Boolean
		{
			return FlashVarUtil.getValue(key) != null ? true : false;
		}
	}
}