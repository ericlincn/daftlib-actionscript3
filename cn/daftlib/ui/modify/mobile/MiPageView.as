package cn.daftlib.ui.modify.mobile
{
	import cn.daftlib.display.DaftSprite;
	import cn.daftlib.ui.modify.mobile.vo.MiPage;
	import cn.daftlib.transitions.TweenManager;

	public class MiPageView extends DaftSprite
	{
		protected var __data:MiPage;
		
		public function MiPageView($data:MiPage)
		{
			super();
			
			__data=$data;
		}
		public function transitionIn():void
		{
			TweenManager.to(this, .3, {alpha:1});
		}
		public function transitionOut():void
		{
			TweenManager.to(this, .3, {alpha:0, onComplete:destroy});
		}
		public function deactive():void
		{
			TweenManager.to(this, .2, {x:this.width * (1-.8)*.5, y:this.height * (1-.8)*.5, scaleX:.8, scaleY:.8, alpha:.5});
		}
		public function active():void
		{
			TweenManager.to(this, .2, {x:0, y:0, scaleX:1, scaleY:1, alpha:1});
		}
	}
}
