package cn.daftlib
{
	public namespace arcane
	
	/*
	Ctrl+Shift+O 组织 import 结构
	Ctrl+Shift+C 块注释
	Ctrl+Shift+D Asdoc 注释
	
	需要隐藏自身api的类使用
	use namespace arcane
	arcane function():void{}
	需要调用隐藏api的其他类使用
	class.arcane::function
	
	凡是百分比, 取值范围 0 ~ 1
	凡是角度, 取值范围 0 ~ 360
	除cn.daftlib.transitions包使用秒为单位之外, 凡是时间, 单位为ms
	
	确保使用到EnterFrame和IntervalFrame的对象
	在destroy自身时移除相应的EnterFrame和IntervalFrame侦听
	
	无扩展子类可能的类使用public final Class的写法
	
	判断值是否为真
	value == true;
	
	判断值是否为null
	value != null;
	
	判断值是否为NaN
	isNaN(value);
	
	判断属性是否未定义, 或无类型变量是否初始化
	object[prop] != undefined;
	dictionary[key] == undefined;
	var myVar;
	trace(myVar); // undefined
	
	判断短写法仅用于基本数据类型, 不用于对象
	return outStr==""?null:outStr;
	
	toString()方法首先输出对象类型
	public function toString():String
	{
		return "[object ColorMatrix] ["+this.join(", ")+"]";
	}
	
	检查每个method或者getter/setter是否会抛出error
	try
	{
		flushStatus=$so.flush();
	}
	catch(e:Error)
	{
		trace(e);
	}
	
	检查除法分母是否为 0
	trace(0 / 0);  // NaN
	trace(7 / 0);  // Infinity
	trace(-7 / 0); // -Infinity
	
	[SWF(frameRate="60", backgroundColor="0x0")]
	
	[Embed(source = "../../resource/btn.png")]
	private static var BM_btn:Class;
	
	[Embed(source="../../resource/font.ttf", fontName="My font name", mimeType="application/x-font", embedAsCFF="false")]
	private var MY_FONT:Class;
	*/
}