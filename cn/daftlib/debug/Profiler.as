package cn.daftlib.debug
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	import cn.daftlib.errors.DuplicateDefinedError;
	import cn.daftlib.utils.FileReferenceUtil;

	/**
	 * Initialize a Profiler, shows framerates(FPS), memory demand(MEM/MAX) and frame rendering time(MS)
	 *
	 * @example Initialize a Profiler
	 *
	 *		<listing version="3.0">
	 *         Profiler.initialize(this.stage);
	 *		</listing>
	 *
	 * @author Eric.lin
	 *
	 */
	public final class Profiler
	{
		private static var __stage:Stage;

		private static var __profiler:ProfilerContent;
		private static var __logger:Logger;
		private static var __screenShotsBtn:TinyButton;
		private static var __savelogBtn:TinyButton;
		private static var __minimizeBtn:TinyButton;
		private static var __maximizeBtn:TinyButton;

		private static var __scale:Number;
		private static var __mouseY:Number;

		public static function initialize(stage:Stage, scale:Number = 1):void
		{
			if(__stage == null)
			{
				__scale = scale;

				__stage = stage;
				__profiler = new ProfilerContent(__stage);
				__stage.addChild(__profiler);
				__stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				__stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				__stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

				__screenShotsBtn = new TinyButton("S");
				__screenShotsBtn.buttonMode = true;
				__screenShotsBtn.addEventListener(MouseEvent.CLICK, takeScreenshot);
				__stage.addChild(__screenShotsBtn);

				__savelogBtn = new TinyButton("L");
				__savelogBtn.buttonMode = true;
				__savelogBtn.addEventListener(MouseEvent.CLICK, saveLog);
				__stage.addChild(__savelogBtn);

				__minimizeBtn = new TinyButton("-");
				__minimizeBtn.buttonMode = true;
				__minimizeBtn.addEventListener(MouseEvent.CLICK, minimize);
				__stage.addChild(__minimizeBtn);

				__maximizeBtn = new TinyButton("+");
				__maximizeBtn.buttonMode = true;
				__maximizeBtn.addEventListener(MouseEvent.CLICK, maximize);
				__stage.addChild(__maximizeBtn);

				__profiler.scaleX = __profiler.scaleY = __scale;
				__screenShotsBtn.scaleX = __screenShotsBtn.scaleY = __scale;
				__savelogBtn.scaleX = __savelogBtn.scaleY = __scale;
				__minimizeBtn.scaleX = __minimizeBtn.scaleY = __scale;
				__maximizeBtn.scaleX = __maximizeBtn.scaleY = __scale;

				x = y = 0;

				maximize(null);
			}
			else
				throw new DuplicateDefinedError(__stage.toString());
		}
		public static function set x(x:Number):void
		{
			if(__profiler == null)
				throw new Error('Please call "Profiler.initialize" first before set the position.');

			x = Math.round(x);

			__profiler.x = x;
			__screenShotsBtn.x = x + 107 * __scale;
			__savelogBtn.x = x + 107 * __scale;
			__minimizeBtn.x = x + 107 * __scale;
			__maximizeBtn.x = x + 107 * __scale;
		}
		public static function set y(y:Number):void
		{
			if(__profiler == null)
				throw new Error('Please call "Profiler.initialize" first before set the position.');

			y = Math.round(y);

			__profiler.y = y;
			__screenShotsBtn.y = y + 33 * __scale;
			__savelogBtn.y = __screenShotsBtn.y + 33 * __scale;
			__minimizeBtn.y = y;
			__maximizeBtn.y = y;
		}
		public static function log(... parameters):void
		{
			if(__profiler == null)
			{
				trace(parameters);
				return;
			}

			if(__logger == null)
			{
				__logger = new Logger();
				__logger.y = 97 + 2;
				__profiler.addChild(__logger);
			}
			__logger.log(parameters);
		}
		private static function maximize(e:MouseEvent):void
		{
			__profiler.visible = __screenShotsBtn.visible = __savelogBtn.visible = __minimizeBtn.visible = true;
			__maximizeBtn.visible = false;
		}
		private static function minimize(e:MouseEvent):void
		{
			__profiler.visible = __screenShotsBtn.visible = __savelogBtn.visible = __minimizeBtn.visible = false;
			__maximizeBtn.visible = true;
		}
		private static function takeScreenshot(e:MouseEvent):void
		{
			var bmd:BitmapData = new BitmapData(__stage.stageWidth, __stage.stageHeight, false, 0x0);
			bmd.draw(__stage);

			FileReferenceUtil.saveBitmapAsPNG(bmd, "image" + int(getTimer() / 1000));
		}
		private static function saveLog(e:MouseEvent):void
		{
			if(__logger == null)
				return;
			
			__logger.saveLogToFile();
		}
		private static function mouseWheelHandler(e:MouseEvent):void
		{
			if(__logger != null)
			{
				if(__logger.hitTestPoint(__stage.mouseX, __stage.mouseY) && __profiler.visible == true)
					__logger.updateScrollOffsets(-e.delta);
			}
		}
		private static function mouseDownHandler(e:MouseEvent):void
		{
			if(__logger != null)
			{
				if(__logger.hitTestPoint(__stage.mouseX, __stage.mouseY) && __profiler.visible == true)
				{
					__mouseY = __stage.mouseY;
					__stage.addEventListener(Event.ENTER_FRAME, trackingMouse);
				}
			}
		}
		private static function mouseUpHandler(e:MouseEvent):void
		{
			__stage.removeEventListener(Event.ENTER_FRAME, trackingMouse);
		}
		private static function trackingMouse(e:Event):void
		{
			var offsetY:Number = (__stage.mouseY - __mouseY) * .1;
			__logger.updateScrollOffsets(-offsetY);
			__mouseY = __stage.mouseY;
		}
	}
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.GradientType;
import flash.display.JointStyle;
import flash.display.Shape;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.utils.getTimer;

class ProfilerContent extends Sprite
{
	private const SIZE:Rectangle = new Rectangle(0, 0, 105, 97);
	private const GRAPH_SIZE:Rectangle = new Rectangle(0, 0, 90, 10);
	private const COLORS:Object = {bg:0x0, fps:0xffffff, ms:0x999999, mem:0x01b0f0, memmax:0xaeee00};
	private const MARGIN:uint = 7;

	private var __stage:Stage;
	private var __xml:XML;
	private var __tf:TextField;
	private var __graph:Bitmap;
	private var __memBm:ShapeBitmap;

	private var __prevTime:int = 0;
	private var __fps:uint = 0;
	private var __averageFps:uint = 0;
	private var __mem:Number = 0;
	private var __memMax:Number = 0;
	private var __ms:uint = 0;

	private var __rectClear:Rectangle;
	private var __rectDraw:Rectangle;
	private var __timeCount:uint = 0;
	private var __framesCount:uint = 0;

	public function ProfilerContent(stage:Stage)
	{
		super();

		__stage = stage;

		initialize();
		this.mouseChildren = this.mouseEnabled = false;
		this.addEventListener(Event.ENTER_FRAME, onRenderTick);
	}
	private function onRenderTick(e:Event):void
	{
		var currentTime:int = getTimer();

		if((currentTime - __prevTime) > 1000)
		{
			var fpsGraph:uint = Math.min(GRAPH_SIZE.height, (__fps / __stage.frameRate) * GRAPH_SIZE.height);
			__graph.bitmapData.lock();
			__graph.bitmapData.scroll(1, 0)
			__graph.bitmapData.fillRect(__rectClear, COLORS.bg);
			__rectDraw = new Rectangle(0, (GRAPH_SIZE.height - fpsGraph), 1, fpsGraph);
			__graph.bitmapData.fillRect(__rectDraw, 0xccffffff);
			__graph.bitmapData.unlock();

			__prevTime = currentTime;
			__mem = Number((System.totalMemory * 0.000000954).toFixed(2));
			__memMax = __mem > __memMax ? __mem : __memMax;

			__xml.fps = "FPS: " + __fps + " / " + __stage.frameRate + " / " + __averageFps;
			__xml.mem = "MEM: " + __mem;
			__xml.memMax = "MAX: " + __memMax;
			__xml.memP = "PROC: " + (System.privateMemory * 0.000000954).toFixed(2);
			__xml.memF = "GARB: " + (System.freeMemory * 0.000000954).toFixed(2);

			//for averageFps
			__timeCount++;
			__averageFps = __framesCount / __timeCount;
			if(__timeCount > 108000)
			{
				__timeCount = 0;
				__framesCount = 0;
			}

			__fps = 0;
		}

		__fps++;

		//for averageFps
		__framesCount++;

		__xml.ms = "MS: " + (currentTime - __ms);
		__ms = currentTime;

		__memBm.width += (__mem / __memMax) * (GRAPH_SIZE.width + 1) * .3 - __memBm.width * .3;
		__tf.htmlText = __xml;
	}
	private function initialize():void
	{
		var bg:Shape = new Shape();
		bg.graphics.beginFill(0x222222, .7);
		bg.graphics.drawRect(0, 0, SIZE.width, SIZE.height);
		bg.graphics.endFill();
		this.addChild(new ShapeBitmap(bg));

		var fillType:String = GradientType.LINEAR;
		var colors:Array = [0x01b0f0, 0xff358b];
		var alphas:Array = [1, 1];
		var ratios:Array = [0, 255];
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(100, 20, 0, 0, 0);
		var spreadMethod:String = SpreadMethod.PAD;

		var shape:Shape = new Shape();
		shape.graphics.lineStyle(0, 0xFFFFFF, 1, true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
		shape.graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod);
		shape.graphics.drawRect(0, 0, GRAPH_SIZE.width, GRAPH_SIZE.height + 5);
		shape.graphics.endFill();
		shape.graphics.lineStyle();
		shape.graphics.beginFill(0xFFFFFF, .3);
		shape.graphics.drawRect(0, 0, GRAPH_SIZE.width, GRAPH_SIZE.height * .5);
		shape.graphics.endFill();
		var colorBm:ShapeBitmap = new ShapeBitmap(shape, 1);
		colorBm.x = colorBm.y = MARGIN;
		this.addChild(colorBm);

		colors = [0x01b0f0, 0xaeee00];
		var memShape:Shape = new Shape();
		memShape.graphics.beginFill(0xaeee00);
		memShape.graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod);
		memShape.graphics.drawRect(0, 0, GRAPH_SIZE.width + 1, GRAPH_SIZE.height * .4);
		memShape.graphics.endFill();
		__memBm = new ShapeBitmap(memShape);
		__memBm.x = MARGIN;
		__memBm.y = GRAPH_SIZE.height + MARGIN + 10;
		this.addChild(__memBm);

		__graph = new Bitmap();
		__graph.bitmapData = new BitmapData(GRAPH_SIZE.width, GRAPH_SIZE.height, true, 0x0);
		__graph.x = MARGIN;
		__graph.y = MARGIN + 5;
		this.addChild(__graph);

		__rectClear = new Rectangle(0, 0, 1, GRAPH_SIZE.height);

		__xml = <xml><fps>FPS:</fps><ms>MS:</ms><mem>MEM:</mem><memMax>MAX:</memMax><memP>PROC:</memP><memF>GARB:</memF></xml>;

		var css:StyleSheet = new StyleSheet();
		css.setStyle("xml", {fontSize:'9px', fontFamily:'Tahoma', fontWeight:'bold', leading:'-2px'});
		css.setStyle("fps", {color:hex2css(COLORS.fps)});
		css.setStyle("ms", {color:hex2css(COLORS.ms)});
		css.setStyle("mem", {color:hex2css(COLORS.mem)});
		css.setStyle("memMax", {color:hex2css(COLORS.memmax)});
		css.setStyle("memP", {color:hex2css(COLORS.ms)});
		css.setStyle("memF", {color:hex2css(COLORS.ms)});

		__tf = new TextField();
		__tf.width = SIZE.width;
		__tf.height = SIZE.height;
		__tf.styleSheet = css;
		__tf.condenseWhite = true;
		__tf.selectable = false;
		__tf.mouseEnabled = false;
		__tf.mouseWheelEnabled = false;
		__tf.htmlText = __xml;
		__tf.x = MARGIN;
		__tf.y = __memBm.y + MARGIN;
		this.addChild(__tf);
	}
	private function hex2css(color:int):String
	{
		return "#" + color.toString(16);
	}
}

class TinyButton extends Sprite
{
	public function TinyButton(str:String)
	{
		super();

		this.mouseChildren = false;

		var s:Shape = new Shape();
		s.graphics.beginFill(0x222222, .7);
		s.graphics.drawRect(0, 0, 31, 31);
		s.graphics.endFill();
		s.graphics.lineStyle(2, 0xFFFFFF, 1, true, "normal", CapsStyle.SQUARE, JointStyle.MITER);

		var offset:Number = 9;

		if(str == "S")
		{
			s.graphics.moveTo(9 + offset, 3 + offset);
			s.graphics.lineTo(3 + offset, 3 + offset);
			s.graphics.lineTo(3 + offset, 6 + offset);
			s.graphics.lineTo(9 + offset, 6 + offset);
			s.graphics.lineTo(9 + offset, 9 + offset);
			s.graphics.lineTo(3 + offset, 9 + offset);
		}
		else if(str == "L")
		{
			s.graphics.moveTo(3 + offset, 3 + offset);
			s.graphics.lineTo(3 + offset, 9 + offset);
			s.graphics.lineTo(9 + offset, 9 + offset);
		}
		else if(str == "-")
		{
			s.graphics.moveTo(3 + offset, 6 + offset);
			s.graphics.lineTo(9 + offset, 6 + offset);
		}
		else if(str == "+")
		{
			s.graphics.moveTo(3 + offset, 6 + offset);
			s.graphics.lineTo(9 + offset, 6 + offset);
			s.graphics.moveTo(6 + offset, 3 + offset);
			s.graphics.lineTo(6 + offset, 9 + offset);
		}

		this.addChild(new ShapeBitmap(s));
	}
}

class ShapeBitmap extends Bitmap
{
	public function ShapeBitmap(shape:Shape, expand:uint = 0)
	{
		var bmd:BitmapData = new BitmapData(shape.width + expand, shape.height + expand, true, 0x0);
		bmd.draw(shape);
		this.bitmapData = bmd;
	}
}