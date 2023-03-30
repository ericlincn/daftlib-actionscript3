package cn.daftlib.ui.modify
{
    import cn.daftlib.core.IDestroyable;
    import cn.daftlib.time.EnterFrame;
    
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.filters.ConvolutionFilter;
    import flash.filters.DisplacementMapFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /** 
     * 
     * The Rippler class creates an effect of rippling water on a source DisplayObject.
     * 
     * @example The following code takes a DisplayObject on the stage and adds a ripple to it, assuming source is a DisplayObject already on the stage.
     * 
     *		<listing version="3.0">
     *         // create a Rippler instance to impact source, with a strength of 60 and a scale of 6.
     *         // The source can be any DisplayObject on the stage, such as a Bitmap or MovieClip object.
     *         var rippler : Rippler = new Rippler(source, 60, 6);
     * 
     *         // create a ripple with size 20 and alpha 1 with origin on position (200, 50)
     *         rippler.drawRipple(100, 50, 20, 1);
     *		</listing>
     * 
      */
    public class Rippler implements IDestroyable
    {
        // The DisplayObject which the ripples will affect.
        private var __source:DisplayObject;
        
        // Two buffers on which the ripple displacement image will be created, and swapped.
        // Depending on the scale parameter, this will be smaller than the source
        private var __buffer1:BitmapData;
        private var __buffer2:BitmapData;
        
        // The final bitmapdata containing the upscaled ripple image, to match the source DisplayObject
        private var __defData:BitmapData;
        
        // Rectangle and Point objects created once and reused for performance
        private var __fullRect:Rectangle; 			// A buffer-sized Rectangle used to apply filters to the buffer
        private var __drawRect:Rectangle;			// A Rectangle used when drawing a ripple
        private var __origin:Point = new Point();	// A Point object to (0, 0) used for the DisplacementMapFilter as well as for filters on the buffer
        
        // The DisplacementMapFilter applied to the source DisplayObject
        private var __filter:DisplacementMapFilter;
        // A filter causing the ripples to grow
        private var __expandFilter:ConvolutionFilter;
        
        // Creates a colour offset to 0x7f7f7f so there is no image offset due to the DisplacementMapFilter
        private var __colourTransform:ColorTransform;
        
        // Used to scale up the buffer to the final source DisplayObject's scale
        private var __matrix:Matrix;
        
        // We only need 1/scale, so we keep it here
        private var __scaleXInv:Number;
        private var __scaleYInv:Number;
        
        /**
         * Creates a Rippler instance.
         * 
         * @param source The DisplayObject which the ripples will affect.
         * @param strength The strength of the ripple displacements.
         * @param scale The size of the ripples. In reality, the scale defines the size of the ripple displacement map (map.width = source.width/scale). Higher values are therefor also potentially faster.
         * 
         */
        public function Rippler(source:DisplayObject, strength:Number, scaleX:Number = 2, scaleY:Number = 2)
        {
            var correctedScaleX:Number;
            var correctedScaleY:Number;
            
            __source = source;
            __scaleXInv = 1/scaleX;
            __scaleYInv = 1/scaleY;
            
            // create the (downscaled) buffers and final (upscaled) image data, sizes depend on scale
            __buffer1 = new BitmapData(source.width*__scaleXInv, source.height*__scaleYInv, false, 0x000000);
            __buffer2 = new BitmapData(__buffer1.width, __buffer1.height, false, 0x000000);
            __defData = new BitmapData(source.width, source.height, false, 0x7f7f7f);
            
            // Recalculate scale between the buffers and the final upscaled image to prevent roundoff errors.
            correctedScaleX = __defData.width/__buffer1.width;
            correctedScaleY = __defData.height/__buffer1.height;
            
            // Create reusable objects
            __fullRect = new Rectangle(0, 0, __buffer1.width, __buffer1.height);
            __drawRect = new Rectangle();
            
            // Create the DisplacementMapFilter and assign it to the source
            __filter = new DisplacementMapFilter(__defData, __origin, BitmapDataChannel.BLUE, BitmapDataChannel.BLUE, strength, strength, "wrap");
            __source.filters = [__filter];
            
            // Create a frame-based loop to update the ripples
            EnterFrame.addEventListener(handleEnterFrame);
            
            // Create the filter that causes the ripples to grow.
            // Depending on the colour of its neighbours, the pixel will be turned white
            __expandFilter = new ConvolutionFilter(3, 3, [0.5, 1, 0.5, 1, 0, 1, 0.5, 1, 0.5], 3);
            
            // Create the colour transformation based on 
            __colourTransform = new ColorTransform(1, 1, 1, 1, 128, 128, 128);
            
            // Create the Matrix object
            __matrix = new Matrix(correctedScaleX, 0, 0, correctedScaleY);
            
        }
        
        /**
         * Initiates a ripple at a position of the source DisplayObject.
         * 
         * @param x The horizontal coordinate of the ripple origin.
         * @param y The vertical coordinate of the ripple origin.
         * @param size The size of the ripple diameter on first impact.
         * @param alpha The alpha value of the ripple on first impact.
         */
        public function drawRipple(x:int, y:int, size:int, alpha:Number):void
        {
        	var half:int = size >> 1;		// We need half the size of the ripple
            var intensity:int = (alpha*0xff & 0xff)*alpha;	// The colour which will be drawn in the currently active buffer
            
            // calculate and draw the rectangle, having (x, y) in its centre
            __drawRect.x = (-half+x)*__scaleXInv;	
            __drawRect.y = (-half+y)*__scaleYInv;
            __drawRect.width = size*__scaleXInv;
            __drawRect.height = size*__scaleYInv;
            __buffer1.fillRect(__drawRect, intensity);
        }
        
        /**
         * Removes all memory occupied by this instance. This method must be called before discarding an instance.
         */
        public function destroy():void
        {
            EnterFrame.removeEventListener(handleEnterFrame);
            __buffer1.dispose();
            __buffer2.dispose();
            __defData.dispose();
        }
        
        // the actual loop where the ripples are animated
        private function handleEnterFrame($e:Event):void
        {
        	// a temporary clone of buffer 2
            var temp:BitmapData = __buffer2.clone();
            // buffer2 will contain an expanded version of buffer1
            __buffer2.applyFilter(__buffer1, __fullRect, __origin, __expandFilter);
            // by substracting buffer2's old image, buffer2 will now be a ring
            __buffer2.draw(temp, null, null, BlendMode.SUBTRACT, null, false);
            // scale up and draw to the final displacement map, and apply it to the filter
            __defData.draw(__buffer2, __matrix, __colourTransform, null, null, true);
            __filter.mapBitmap = __defData;
            __source.filters = [__filter];
            temp.dispose();
            // switch buffers 1 and 2
            switchBuffers();
        }
        
        // switch buffer 1 and 2, so that 
        private function switchBuffers():void
        {
            var temp:BitmapData;
            temp = __buffer1;
            __buffer1 = __buffer2;
            __buffer2 = temp;
        }
    }
}