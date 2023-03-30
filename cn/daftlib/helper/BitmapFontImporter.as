package cn.daftlib.helper
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import cn.daftlib.time.IntervalFrame;

	public class BitmapFontImporter extends Sprite
	{
		private var __tf:TextField;
		private var __bm:Bitmap;
		private var __drawID:uint=33;
		private var __finalData:String="";
		private var __inter:IntervalFrame;
		private var __margin:Array;
		
		private var __size:Array=null;
		
		public function BitmapFontImporter(fontName:String, fontSize:uint, frameDelay:uint=1, margin:Array=null)
		{
			__tf=new TextField();
			__tf.embedFonts=true;
			__tf.selectable=false;
			__tf.background=true;
			__tf.backgroundColor=0xffffff;
			__tf.autoSize=TextFieldAutoSize.LEFT;
			//__tf.antiAliasType=AntiAliasType.ADVANCED;
			__tf.defaultTextFormat=new TextFormat(fontName, fontSize, 0x0);
			__bm=new Bitmap();
			__bm.x=50;
			__bm.scaleX=__bm.scaleY=6;
			this.addChild(__bm);
			this.addChild(__tf);
			
			__margin = margin != null ? margin : [0, 0, 0, 0];
			
			__inter=new IntervalFrame();
			__inter.addEventListener(next, frameDelay);
		}
		private function next():void
		{
			if(__drawID==127)
			{
				__inter.removeEventListener(next);
				__finalData=__finalData.substring(0, __finalData.length-1);
				trace(__finalData);
				trace(__size[1]-__size[0]+1, __size[3]-__size[2]+1);
				return;
			}
			
			//trace(__drawID, String.fromCharCode(__drawID));
			draw(String.fromCharCode(__drawID));
			__drawID++;
		}
		private function draw(str:String):void
		{
			__tf.text=str;
			if((__tf.width-__margin[0])>0 && (__tf.height-__margin[1])>0)
			{
				var bmd:BitmapData=new BitmapData(__tf.width-__margin[0], __tf.height-__margin[1]);
				var m:Matrix=new Matrix();
				m.translate(-__margin[2], -__margin[3]);
				bmd.draw(__tf, m);
				__bm.bitmapData=bmd;
				
				var data:String=str.charCodeAt()+":"+bmd.width+","+bmd.height+",";
				var i:uint=0;
				while(i<bmd.width)
				{
					var j:uint=0;
					while(j<bmd.height)
					{
						if(bmd.getPixel(i, j) != 0 && bmd.getPixel(i, j) != 0xffffff)
							trace(bmd.getPixel(i, j));
						if(bmd.getPixel(i, j) == 0)
						{
							data+=(i+","+j+",");
							fitSize(i, j);
						}
						j++;
					}
					i++;
				}
				data=data.substring(0, data.length-1)+";";
				__finalData+=data;
			}
			else
			{
				trace(str, str.charCodeAt());
			}
		}
		private function fitSize(i:uint, j:uint):void
		{
			if(__size==null)
			{
				__size=[i, i, j, j];
			}
			else
			{
				__size[0]=Math.min(i, __size[0]);
				__size[1]=Math.max(i, __size[1]);
				__size[2]=Math.min(j, __size[2]);
				__size[3]=Math.max(j, __size[3]);
			}
		}
	}
}