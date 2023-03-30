package cn.daftlib.errors
{
	/**
	 * @author Eric.lin
	 */
	public final class DuplicateDefinedError extends Error
	{
		public function DuplicateDefinedError(referenceType:String = null, message:String = "", id:int = 0)
		{
			super((referenceType == null) ? 'The property should only be defined once, and its has been defined.' : 'Property class: "' + referenceType + '" should only be defined once, and its has been defined.');
		}
	}
}