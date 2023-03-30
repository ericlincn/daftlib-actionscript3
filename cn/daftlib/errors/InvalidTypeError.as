package cn.daftlib.errors
{
	/**
	 * @author Eric.lin
	 */
	public final class InvalidTypeError extends Error
	{
		public function InvalidTypeError(type:String = null, message:String = "", id:int = 0)
		{
			super((type == null) ? 'The type is invalid or undefined.' : 'Type: "' + type + '" is invalid or undefined.');
		}
	}
}