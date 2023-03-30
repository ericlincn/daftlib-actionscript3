package cn.daftlib.utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.system.Capabilities;
	
	import cn.daftlib.errors.UndefinedError;
	import cn.daftlib.time.EnterFrame;

	/**
	 * @author Eric.lin
	 */
	public final class StageReference
	{
		public static var phoneScreenMaximumInches:Number = 6.4;

		private static var __rootContainer:DisplayObjectContainer;
		private static var __callback:Function;
		private static var __stage:Stage;
		private static var __flashPlayerVersion:uint;
		private static var __swfVersion:uint;

		/* 使用一个扩展功能支持配置文件以支持更新的 GPU，后者支持更大的纹理
		此配置文件将 2D 纹理和矩形纹理的大小增加到最大 4096x4096 */
		private static const BASELINE_EXTENDED:String = "baselineExtended";
		/* 用默认功能支持配置文件 */
		private static const BASELINE:String = "baseline";
		/* 使用受限功能支持配置文件面向更早期的 GPU
		此配置文件主要面向这样的设备，它们仅支持类似 Intel GMA 9xx 系列的 PS_2.0 级着色器。 此外，此模式试图通过直接呈现到后台缓冲区中来改善内存带宽的使用。有几个副作用：
		每个着色器被限定为 64 ALU 和 32 个纹理指令。
		每个着色器只有四个纹理读取指令。
		不支持预测寄存器。这会影响 sln/sge/seq/sne，您可以用复合 mov/cmp 指令代替，它随 ps_2_0 提供。
		Context3D 后台缓冲区必须总是在舞台范围之内。
		一个 Flash Player 实例内只允许有一个 Context3D 实例在受限配置文件中运行。
		标准显示列表的呈现由 Context3D.present() 驱动，而不是基于 SWF 帧速率。也就是说，如果 Context3D 对象活动且可见，则必须调用 Context3D.present() 来呈现标准显示列表。
		通过 Context3D.drawToBitmapData() 从后台缓冲区读回可能会包括部分显示列表内容。 Alpha 信息将丢失。 */
		private static const BASELINE_CONSTRAINED:String = "baselineConstrained";

		private static var __profile:String;
		private static var __renderMode:String;
		private static var __stage3D:Stage3D; // For requestContext() only

		public static function initialize(rootContainer:DisplayObjectContainer, callback:Function, rootMouseChildren:Boolean = true, rootMouseEnabled:Boolean = false):void
		{
			if(__rootContainer != null) return;
				//throw new DuplicateDefinedError(__rootContainer.toString());

			__rootContainer = rootContainer;
			__rootContainer.mouseChildren = rootMouseChildren;
			__rootContainer.mouseEnabled = rootMouseEnabled;
			__callback = callback;

			EnterFrame.addEventListener(checkStageReference);
		}
		public static function get stage():Stage
		{
			confirmStageReference();

			return __stage;
		}
		public static function get stage3D():Stage3D
		{
			if(__stage3D == null)
				throw new UndefinedError("[class Stage3D]");

			return __stage3D;
		}
		public static function get context3DProfile():String
		{
			trace(StageReference, 'The renderMode flag in the application descriptor should be set as "direct".');

			return __profile;
		}
		public static function get context3DRenderMode():String
		{
			return __renderMode;
		}
		public static function get stageWidth():int
		{
			trace(StageReference, 'Do not call get_stageWidth frequently.');
			
			confirmStageReference();

			return __stage.stageWidth;
		}
		public static function get stageHeight():int
		{
			trace(StageReference, 'Do not call get_stageHeight frequently.');
			
			confirmStageReference();

			return __stage.stageHeight;
		}
		public static function get isCurrentlyPortrait():Boolean
		{
			confirmStageReference();

			return __stage.orientation == StageOrientation.DEFAULT || __stage.orientation == StageOrientation.UPSIDE_DOWN;
		}
		public static function get isPhone():Boolean
		{
			confirmStageReference();

			var screenWidth:Number = __stage.fullScreenWidth;
			var screenHeight:Number = __stage.fullScreenHeight;
			//var size:Number = Math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight) / dpi;
			return (Math.max(screenWidth, screenHeight) / dpi) < phoneScreenMaximumInches;
		}
		private static function checkStageReference(e:Event):void
		{
			if(__rootContainer.stage != null)
			{
				if(__rootContainer.stage.stageWidth > 0 && __rootContainer.stage.stageHeight > 0)
				{
					EnterFrame.removeEventListener(checkStageReference);

					__stage = __rootContainer.stage;
					__stage.align = StageAlign.TOP_LEFT;
					__stage.scaleMode = StageScaleMode.NO_SCALE;
					__stage.stageFocusRect = false;
					__stage.showDefaultContextMenu = false;

					__flashPlayerVersion = uint(flashVersion.split(".")[0]);
					__swfVersion = __rootContainer.loaderInfo.swfVersion;
					//trace(__swfVersion, __flashPlayerVersion);

					/*
					Flash Player	AIR			Flex							-swf-version	-target-player
					9	 						3								9				9
					10.0			1.5	 		4.0								10				10.0.0
					10.1			2.0/2.5		4.1								10				10.1.0
					10.2			2.6			4.5/4.5.1						11				10.2.0
					10.3			2.7											12				10.3.0
					11.0			3.0											13				11.0.0
					11.1			3.1			4.6								14				11.1
					11.2			3.2											15				11.2
					11.3			3.3											16				11.3
					11.4			3.4			Adobe Flex 4.6/Apache Flex 4.8	17				11.4
					11.5			3.5			Adobe Flex 4.6/Apache Flex 4.8	18				11.5
					11.6			3.6			Adobe Flex 4.7/Apache Flex 4.9	19				11.6
					beta 11.7		3.6			Adobe Flex 4.7/Apache Flex 4.9	20				11.7

					__flashPlayerVersion = Flash Player
					__swfVersion = -swf-version
					*/

					if(__swfVersion >= 13 && __flashPlayerVersion >= 11)
						requestStage3D();
					else
						finishInit();
				}
			}
		}
		private static function requestStage3D():void
		{
			if(__rootContainer.stage.stage3Ds.length > 0)
			{
				var stage3D:Stage3D = stage.stage3Ds[0];
				stage3D.addEventListener(Event.CONTEXT3D_CREATE, context3DCreateHandler);
				stage3D.addEventListener(ErrorEvent.ERROR, context3DNotAvailableHandler);

				__renderMode = Context3DRenderMode.AUTO;
				__profile = BASELINE_EXTENDED;
				__stage3D = stage3D;

				requestContext3D();
			}
			else
			{
				__renderMode = Context3DRenderMode.SOFTWARE;

				finishInit();
			}
		}
		private static function context3DNotAvailableHandler(e:Event):void
		{
			__renderMode = Context3DRenderMode.SOFTWARE;

			finishInit();
		}
		private static function finishInit():void
		{
			if(__stage3D != null)
			{
				__stage3D.removeEventListener(Event.CONTEXT3D_CREATE, context3DCreateHandler);
				__stage3D.removeEventListener(ErrorEvent.ERROR, context3DNotAvailableHandler);
				if(__stage3D.context3D!=null)
				__stage3D.context3D.dispose();
			}

			//trace(__callback, "finish");
			if(__callback != null)
			{
				__callback.apply();
				__callback = null;
			}
		}
		private static function requestContext3D():void
		{
			//trace("requestContext", __renderMode, __profile);
			try
			{
				// Only pass a profile when the parameter is accepted. Do this
				// dynamically so we can still compile for older versions.
				if(__stage3D.requestContext3D.length >= 2)
					__stage3D["requestContext3D"](__renderMode, __profile);
				else
					__stage3D.requestContext3D(__renderMode);
			}
			catch(err:Error)
			{
				fallback();
			}
		}
		private static function fallback():void
		{
			//trace("fallback", __renderMode, __profile);
			// Check what profile we were trying to get
			switch(__profile)
			{
				// Trying to get extended profile. Try baseline.
				case BASELINE_EXTENDED:
					__profile = BASELINE;
					requestContext3D();
					break;
				// Trying to get baseline profile. Try constrained.
				case BASELINE:
					__profile = BASELINE_CONSTRAINED;
					requestContext3D();
					break;
				// Trying to get constrained profile. Try software.
				case BASELINE_CONSTRAINED:
					__profile = BASELINE;
					__renderMode = Context3DRenderMode.SOFTWARE;
					requestContext3D();
					break;
			}
		}
		private static function context3DCreateHandler(e:Event):void
		{
			var stage3D:Stage3D = e.target as Stage3D;
			var driverInfo:String = stage3D.context3D.driverInfo.toLowerCase();
			//trace(driverInfo);
			//__context3D = stage3D.context3D;

			var gotSoftware:Boolean = driverInfo.indexOf("software") >= 0;
			if(gotSoftware == true)
			{
				if(__renderMode == Context3DRenderMode.AUTO)
					fallback();
				else
					finishInit();
			}
			else
			{
				finishInit();
			}
		}
		private static function get dpi():Number
		{
			var dpi:Number = Capabilities.screenDPI;
			var serverString:String = unescape(Capabilities.serverString);
			var reportedDpi:Number = Number(serverString.split("&DP=", 2)[1]);

			if(dpi != reportedDpi)
			{
				if(reportedDpi < 100)
				{
					//final dpi is dpi
				}
				else if((dpi - reportedDpi) < 96)
				{
					dpi = reportedDpi;
				}
			}

			if(dpi < 100)
				dpi = 80;
			else if(dpi < 200)
				dpi = 160;
			else if(dpi < 300)
				dpi = 240;
			else
				dpi = 320;

			return dpi;
		}
		/**
		 * Return the client device Flash Player version, format as 11.0.0.58
		 * @return
		 */
		private static function get flashVersion():String
		{
			var result:String = Capabilities.version;

			var r:RegExp = new RegExp("[0-9,]+", "");
			var o:*;
			o = r.exec(result);
			result = o[0].toString();

			result = result.split(",").join(".");

			return result;
		}
		private static function confirmStageReference():void
		{
			if(__stage == null)
				throw new UndefinedError("[class Stage]");
		}
	}
}