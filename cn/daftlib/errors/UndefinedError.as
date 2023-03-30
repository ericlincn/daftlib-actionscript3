package cn.daftlib.errors
{
	/**
	 * @author Eric.lin
	 */
	public final class UndefinedError extends Error
	{
		public function UndefinedError(referenceType:String = null, message:String = "", id:int = 0)
		{
			super((referenceType == null) ? 'The property is uninitialized or undefined.' : 'Property class: "' + referenceType + '" is uninitialized or undefined.');
		}
	}
}