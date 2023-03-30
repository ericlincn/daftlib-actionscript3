package cn.daftlib.ui.modify
{
	import cn.daftlib.display.DaftSprite;
	import cn.daftlib.utils.StageReference;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class PageFlip extends DaftSprite
	{
		private var __pageWidth:Number;
		private var __pageHeight:Number;
		private var __pagesUrlArr:Array;
		
		private var __crossPageAmount:uint;
		private var __currentCrossPageIndex:uint=uint.MAX_VALUE;
		
		private var __singlePagesMap:Dictionary=new Dictionary();
		
		private var __renderShape:Shape;
		private var __leftBackPageBD:BitmapData;
		private var __leftPageBD:BitmapData;
		private var __rightBackPageBD:BitmapData;
		private var __rightPageBD:BitmapData;
		private var __mouseAreaIndex:int;
		
		public function PageFlip($pageWidth:Number, $pageHeight:Number, $pagesUrlArr:Array)
		{
			super();
			
			__pageWidth=$pageWidth;
			__pageHeight=$pageHeight;
			__pagesUrlArr=$pagesUrlArr;
			__crossPageAmount=__pagesUrlArr.length/2;
			
			if(__pagesUrlArr.length%2!=0)
				trace(this, "单页页数必须是大于等于4的偶数");
			
			init();
			currentCrossPageIndex=2;
			initInteractive();
			initRenderner();
		}
		override public function destroy():void
		{
			__singlePagesMap=null;
			
			StageReference.stage.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			StageReference.stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			
			super.destroy();
		}
		public function set currentCrossPageIndex(value:uint):void
		{
			if(value!=__currentCrossPageIndex)
			{
				__currentCrossPageIndex = value;
				gotoCrossPage(__currentCrossPageIndex);
			}
		}
		private function init():void
		{
			var i:uint=0;
			while(i<__pagesUrlArr.length)
			{
				var loader:Loader=new Loader();
				loader.name="pageLoader|"+i;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, pageLoadComplete);
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, pageLoadProgress);
				loader.load(new URLRequest(__pagesUrlArr[i]));
				
				var pageContainer:Sprite=new Sprite();
				pageContainer.graphics.beginFill(0x0);
				pageContainer.graphics.drawRect(0, 0, __pageWidth, __pageHeight);
				pageContainer.graphics.endFill();
				__singlePagesMap[i]=pageContainer;
				
				i++;
			}
		}
		private function pageLoadComplete(e:Event):void
		{
			var li:LoaderInfo=e.target as LoaderInfo;
			var loader:Loader=li.loader;
			var index:uint=uint(loader.name.split("|")[1]);
			var pageContainer:Sprite=__singlePagesMap[index];
			pageContainer.addChild(li.content);
		}
		private function pageLoadProgress(e:ProgressEvent):void
		{
			
		}
		private function initInteractive():void
		{
			this.graphics.beginFill(0x0, 0);
			this.graphics.drawRect(-2500, -2500, 10000, 10000);
			this.graphics.endFill();
			
			StageReference.stage.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			StageReference.stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
		}
		private function downHandler(e:MouseEvent):void
		{
			//See getMouseArea()
			__mouseAreaIndex=getMouseArea(new Point(this.mouseX,this.mouseY));
			
			if(__mouseAreaIndex==0)
				return;
			
			if( ( (__mouseAreaIndex==-1) || (__mouseAreaIndex==-2) ) && __currentCrossPageIndex<1 )
				return;
			
			if( ( (__mouseAreaIndex==-3) || (__mouseAreaIndex==-4) ) && __currentCrossPageIndex>=(__crossPageAmount-1) )
				return;
			
			//Need to be sequence
			gotoCrossPage(__currentCrossPageIndex);
			this.addChild(__renderShape);
		}
		private function upHandler(e:MouseEvent):void
		{
			
		}
		private function initRenderner():void
		{
			__renderShape=new Shape();
			__renderShape.addEventListener(Event.ENTER_FRAME, render);
			this.addChild(__renderShape);
		}
		private function render(e:Event):void
		{
			var pageBackBD:BitmapData;
			var pageFrontBD:BitmapData;
			var cornerPoint:Point;
			
			switch(__mouseAreaIndex)
			{
				case -1:
					pageBackBD=__leftBackPageBD;
					pageFrontBD=__leftPageBD;
					cornerPoint=new Point(0, 0);
					break;
				case -2:
					pageBackBD=__leftBackPageBD;
					pageFrontBD=__leftPageBD;
					cornerPoint=new Point(0, 1);
					break;
				case -3:
					pageBackBD=__rightBackPageBD;
					pageFrontBD=__rightPageBD;
					cornerPoint=new Point(1, 0);
					break;
				case -4:
					pageBackBD=__rightBackPageBD;
					pageFrontBD=__rightPageBD;
					cornerPoint=new Point(1, 1);
					break;
				default:
					return;
			}
			
			__renderShape.graphics.clear();
			
			var o:Object=PageFlipUtil.computeFlip(	new Point(this.mouseX,this.mouseY),	// flipped point
				cornerPoint,		// of bottom-right corner
				pageFrontBD.width,		// size of the sheet
				pageBackBD.height,
				true,				// in horizontal mode
				1);					// sensibility to one 
			
			
			PageFlipUtil.drawBitmapSheet(o,					// computeflip returned object
				__renderShape,					// target
				pageFrontBD,		// bitmap page 0
				pageBackBD);		// bitmap page 1
		}
		private function gotoCrossPage($index:uint):void
		{
			var pageNeedDrawIndexArr:Array;
			var singlePageAmount:uint=__pagesUrlArr.length;
			
			switch($index)
			{
				case 0:
					//左侧背景、左侧页底、左侧页、右侧页、右侧页底、右侧背景
					//均为singlePage位于__singlePagesMap的index
					pageNeedDrawIndexArr=[null, null, null, 0, 1, 2];
					break;
				case 1:
					pageNeedDrawIndexArr=[null, 0, 1, 2, 3, 4];
					break;
				case __crossPageAmount-1:
					pageNeedDrawIndexArr=[singlePageAmount-3, singlePageAmount-2, singlePageAmount-1, null, null, null];
					break;
				case __crossPageAmount-2:
					pageNeedDrawIndexArr=[singlePageAmount-5, singlePageAmount-4, singlePageAmount-3, singlePageAmount-2, singlePageAmount-1, null];
					break;
				default:
					var currentLeftSinglePage:uint=$index*2-1;
					pageNeedDrawIndexArr=[currentLeftSinglePage-2, currentLeftSinglePage-1, currentLeftSinglePage, currentLeftSinglePage+1, currentLeftSinglePage+2, currentLeftSinglePage+3];
			}
			
			drawPages(pageNeedDrawIndexArr);
		}
		private function drawPages($pagesIndexArr:Array):void
		{
			var leftBgPage:Sprite;
			var leftBackPage:Sprite;
			var leftPage:Sprite;
			var rightBgPage:Sprite;
			var rightBackPage:Sprite;
			var rightPage:Sprite;
			
			//Bg pages
			if($pagesIndexArr[0]!=null)
			{
				leftBgPage=__singlePagesMap[$pagesIndexArr[0]];
				leftBgPage.x=0;
				this.addChild(leftBgPage);
			}
			if($pagesIndexArr[5]!=null)
			{
				rightBgPage=__singlePagesMap[$pagesIndexArr[5]];
				rightBgPage.x=__pageWidth;
				this.addChild(rightBgPage);
			}
			
			//Back pages
			if($pagesIndexArr[1]!=null)
			{
				leftBackPage=__singlePagesMap[$pagesIndexArr[1]];
			}
			if($pagesIndexArr[4]!=null)
			{
				rightBackPage=__singlePagesMap[$pagesIndexArr[4]];
			}
			
			//Current pages
			if($pagesIndexArr[2]!=null)
			{
				leftPage=__singlePagesMap[$pagesIndexArr[2]];
				leftPage.x=0;
				this.addChild(leftPage);
			}
			if($pagesIndexArr[3]!=null)
			{
				rightPage=__singlePagesMap[$pagesIndexArr[3]];
				rightPage.x=__pageWidth;
				this.addChild(rightPage);
			}
			
			if(__leftBackPageBD)
				__leftBackPageBD.dispose();
			if(__leftPageBD)
				__leftPageBD.dispose();
			if(__rightBackPageBD)
				__rightBackPageBD.dispose();
			if(__rightPageBD)
				__rightPageBD.dispose();
			
			__leftBackPageBD=leftBackPage? drawSinglePage(leftBackPage):null;
			__leftPageBD=leftPage? drawSinglePage(leftPage):null;
			__rightBackPageBD=rightBackPage? drawSinglePage(rightBackPage):null;
			__rightPageBD=rightPage? drawSinglePage(rightPage):null;
		}
		/**
		 * Util methods
		 * @param point
		 * @return 
		 * 
		 */		
		private function getMouseArea(point:Point):Number 
		{
			/* 取下面的四个区域,返回数值:
			*   --------------------
			*  | -1|     |     | -3 |
			*  |---      |      ----|
			*  |     1   |   3      |
			*  |---------|----------| 
			*  |     2   |   4      |
			*  |----     |      ----|
			*  | -2 |    |     | -4 |
			*   --------------------
			*/
			var tmpn:Number;
			var minx:Number=0;
			var maxx:Number=__pageWidth*2;
			var miny:Number=0;
			var maxy:Number=__pageHeight;
			var areaNum:Number=50;
			
			if (point.x>minx&&point.x<=maxx*0.5) 
			{
				tmpn=(point.y>miny&&point.y<=(maxy*0.5))?1:(point.y>(maxy*0.5)&&point.y<maxy)?2:0;
				if (point.x<=(minx+areaNum)) 
				{
					tmpn=(point.y>miny&&point.y<=(miny+areaNum))?-1:(point.y>(maxy-areaNum)&&point.y<maxy)?-2:tmpn;
				}
				return tmpn;
			} 
			else if (point.x>(maxx*0.5)&&point.x<maxx) 
			{
				tmpn=(point.y>miny&&point.y<=(maxy*0.5))?3:(point.y>(maxy*0.5)&&point.y<maxy)?4:0;
				if (point.x>=(maxx-areaNum)) 
				{
					tmpn=(point.y>miny&&point.y<=(miny+areaNum))?-3:(point.y>(maxy-areaNum)&&point.y<maxy)?-4:tmpn;
				}
				return tmpn;
			}
			return 0;
		}
		private function drawSinglePage($page:Sprite):BitmapData
		{
			var outBD:BitmapData=new BitmapData(__pageWidth, __pageHeight, false, 0x000000);
			outBD.draw($page);
			return outBD;
		}
	}
}