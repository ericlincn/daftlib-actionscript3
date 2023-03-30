package cn.daftlib.ui.controls
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	import cn.daftlib.display.DaftBitmap;

	public final class ColourSpectrum extends DaftBitmap
	{
		public function ColourSpectrum($width:Number, $height:Number)
		{
			super(null, "auto", false);

			var canvas:Sprite = new Sprite();

			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0xFF0000,0xFFFF00,0x00FF00,0x00FFFF,0x0000FF,0xFF00FF,0xFF0000];
			var alphas:Array = [1,1,1,1,1,1,1];
			var ratios:Array = [0,39,91,125,168,210,255];
			var matr:Matrix = new Matrix();
			matr.createGradientBox($width, $height, 0, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;

			var sp:Shape = new Shape();
			sp.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			sp.graphics.drawRect(0, 0, $width, $height);
			canvas.addChild(sp);

			fillType = GradientType.LINEAR;
			colors = [0xFFFFFF,0xFFFFFF,0xFFFFFF];
			alphas = [1,0.5,0];
			ratios = [0,90,255];
			matr = new Matrix();
			matr.createGradientBox($width, $height / 2, 90 * Math.PI / 180, 0, 0);
			spreadMethod = SpreadMethod.PAD;
			sp = new Shape();
			sp.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			sp.graphics.drawRect(0, 0, $width, $height);
			canvas.addChild(sp);

			fillType = GradientType.LINEAR;
			colors = [0x000000,0x000000,0x000000];
			alphas = [0,0.5,1];
			ratios = [0,90,255];
			matr = new Matrix();
			matr.createGradientBox($width, $height / 2, 90 * Math.PI / 180, 0, 0);
			spreadMethod = SpreadMethod.PAD;
			sp = new Shape();
			sp.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			sp.graphics.drawRect(0, 0, $width, $height / 2);
			sp.y = $height / 2;
			canvas.addChild(sp);

			this.bitmapData = new BitmapData($width, $height, false, 0x0);
			this.bitmapData.draw(canvas);
		}
	}
}