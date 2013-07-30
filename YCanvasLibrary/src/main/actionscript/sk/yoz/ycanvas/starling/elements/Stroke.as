package sk.yoz.ycanvas.starling.elements
{
    import com.adobe.utils.AGALMiniAssembler;
    
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.math.FastCollisions;
    import sk.yoz.ycanvas.utils.PartialBoundsUtils;
    import sk.yoz.ycanvas.utils.StrokeUtils;
    import sk.yoz.ycanvas.utils.VertexDataUtils;
    import sk.yoz.ycanvas.valueObjects.PartialBounds;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    import starling.utils.MatrixUtil;
    import starling.utils.VertexData;
    
    /**
    * Starling implementation for simple stroke.
    */
    public class Stroke extends DisplayObject
    {
        /**
        * Program/shader name.
        */
        private static const PROGRAM_NAME:String = "YCanvasStroke";
        
        /**
        * If true, changing any of points, color or thickness would be 
        * automatically rendered. If false, update() method must be called
        * manualy.
        */
        public var autoUpdate:Boolean = true;
        
        /**
        * Amount of vertices per partial bound.
        */
        protected var verticesPerPartialBounds:uint = 256;
        
        /**
        * Variable holder for points.
        */
        private var _points:Vector.<Number>;
        
        /**
        * Variable holder for thickness.
        */
        private var _thickness:Number;
        
        /**
        * Variable holder for color.
        */
        private var _color:Number;
        
        /**
        * Variable holder for bounds.
        */
        private var _bounds:Rectangle;
        
        /**
        * In order to optimize hitTest() performance, partial bounds are used
        * for collision detection. Once a collision is detected in a partial
        * bound, all triangles within the bound are tested for collision.
        */
        private var partialBounds:Vector.<PartialBounds>;
        
        /**
        * Flag describing that points variable has changed.
        */
        private var pointsChanged:Boolean = true;
        
        /**
        * Flag describing that thickness variable has changed.
        */
        private var thicknessChanged:Boolean = true;
        
        /**
        * Flag describing that color variable has changed.
        */
        private var colorChanged:Boolean = true;
        
        /**
        * Vertex data are calculated from points and thickness.
        */
        private var vertexData:VertexData;
        private var vertexBuffer:VertexBuffer3D;
        
        /**
        * Index data.
        */
        private var indexData:Vector.<uint>;
        private var indexBuffer:IndexBuffer3D;
        
        /**
        * Helper object to avoid temporary objects.
        */
        private var renderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
        
        public function Stroke(points:Vector.<Number>, thickness:Number = 1, 
            color:uint=0xffffff, alpha:Number=1, 
            autoUpdate:Boolean=true)
        {
            _points = points;
            _thickness = thickness;
            _color = color;
            this.alpha = alpha;
            this.autoUpdate = autoUpdate;
            
            if(autoUpdate)
                update();
            
            registerPrograms();
            
            Starling.current.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
        }
        
        /**
        * Disposes all resources and listeners.
        */
        public override function dispose():void
        {
            Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
            
            if(vertexBuffer)
                vertexBuffer.dispose();
            
            if(indexBuffer)
                indexBuffer.dispose();
            
            super.dispose();
        }
        
        /**
        * Array of x, y values defining the stroke.
        */
        public function set points(value:Vector.<Number>):void
        {
            if(points == value)
                return;
            
            _points = value;
            pointsChanged = true;
            if(autoUpdate)
                update();
        }
        
        public function get points():Vector.<Number>
        {
            return _points;
        }
        
        /**
        * Thickness of the stroke.
        */
        public function set thickness(value:Number):void
        {
            if(thickness == value)
                return;
            
            _thickness = value;
            thicknessChanged = true;
            if(autoUpdate)
                update();
        }
        
        public function get thickness():Number
        {
            return _thickness;
        }
        
        /**
        * Color of the stroke.
        */
        public function set color(value:uint):void
        {
            if(color == value)
                return;
            
            _color = value;
            colorChanged = true;
            if(autoUpdate)
                update();
        }
        
        public function get color():uint
        {
            return _color;
        }
        
        /**
        * Cached bounds.
        */
        override public function get bounds():Rectangle
        {
            return _bounds;
        }
        
        /**
        * @inheritDoc
        */
        override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            if(resultRect == null)
                resultRect = new Rectangle();
            
            var matrix:Matrix = getTransformationMatrix(targetSpace);
            var lt:Point = MatrixUtil.transformCoords(matrix, bounds.x, bounds.y);
            var rb:Point = MatrixUtil.transformCoords(matrix, bounds.x + bounds.width, bounds.y + bounds.height);
            resultRect.setTo(lt.x, lt.y, rb.x - lt.x, rb.y - lt.y);
            return resultRect;
        }
        
        /**
        * Updates vertex data and index data based on points, thickness and 
        * color.
        */
        public function update():void
        {
            if(!pointsChanged && !thicknessChanged && !colorChanged)
                return;
            
            var vertexDataChanged:Boolean = false;
            var indexDataChanged:Boolean = false;
            if(pointsChanged || thicknessChanged)
            {
                vertexData = StrokeUtils.pointsToVertexData(points, thickness);
                vertexDataChanged = true;
                
                indexData = StrokeUtils.vertexDataToIndexData(vertexData);
                indexDataChanged = true;
                
                updateBounds();
            }
            
            if(colorChanged || vertexDataChanged)
            {
                vertexData.setUniformColor(color);
                vertexDataChanged = true;
            }
            
            pointsChanged = false;
            thicknessChanged = false;
            colorChanged = false;
            
            var context:Context3D = Starling.context;
            if(context == null)
                throw new MissingContextError();
            
            if(vertexDataChanged)
            {
                if(vertexBuffer)
                    vertexBuffer.dispose();
                
                vertexBuffer = context.createVertexBuffer(vertexData.numVertices, VertexData.ELEMENTS_PER_VERTEX);
                vertexBuffer.uploadFromVector(vertexData.rawData, 0, vertexData.numVertices);
            }
            
            if(indexDataChanged)
            {
                if(indexBuffer)
                    indexBuffer.dispose();
                
                indexBuffer = context.createIndexBuffer(indexData.length);
                indexBuffer.uploadFromVector(indexData, 0, indexData.length);
            }
        }
        
        /**
        * For performance optimization, first the main bounds is tested for a 
        * collision, then partial bounds and in case a collision is detected in 
        * a specific partial bounds all the necessary triagles are evaluated 
        * for a collision as well. 
        */
        override public function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            if(forTouch && (!visible || !touchable))
                return null;
            
            if(!bounds.containsPoint(localPoint))
                return null;
            
            for(var j:uint = 0, length:uint = partialBounds.length; j < length; j++)
            {
                var partialBound:PartialBounds = partialBounds[j];
                if(!partialBound.rectangle.containsPoint(localPoint))
                    continue;
                
                var offset:uint;
                for(var i:uint = partialBound.indiceIndexMin; i <= partialBound.indiceIndexMax; i += 3)
                {
                    var i0:uint = indexData[i];
                    var i1:uint = indexData[uint(i + 1)];
                    var i2:uint = indexData[uint(i + 2)];
                    
                    offset = i0 * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
                    var p1x:Number = vertexData.rawData[offset];
                    var p1y:Number = vertexData.rawData[uint(offset + 1)];
                    
                    offset = i1 * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
                    var p2x:Number = vertexData.rawData[offset];
                    var p2y:Number = vertexData.rawData[uint(offset + 1)];
                    
                    offset = i2 * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
                    var p3x:Number = vertexData.rawData[offset];
                    var p3y:Number = vertexData.rawData[uint(offset + 1)];
                    
                    if(FastCollisions.pointInTriangle(localPoint.x, localPoint.y, p1x, p1y, p2x, p2y, p3x, p3y))
                        return this;
                }
            }
            
            return null;
        }
        
        /**
        * @inheritDoc
        */
        override public function render(support:RenderSupport, alpha:Number):void
        {
            support.finishQuadBatch();
            support.raiseDrawCount();
            
            renderAlpha[3] = alpha * this.alpha;
            
            var context:Context3D = Starling.context;
            if(context == null)
                throw new MissingContextError();
            
            support.applyBlendMode(false);
            
            context.setProgram(Starling.current.getProgram(PROGRAM_NAME));
            context.setVertexBufferAt(0, vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
            context.setVertexBufferAt(1, vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, renderAlpha, 1);
            
            context.drawTriangles(indexBuffer, 0, indexData.length / 3);
            
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
        }
        
        /**
        * Calculates the main bounds.
        */
        private function updateBounds():void
        {
            partialBounds = VertexDataUtils.getPartialBoundsList(vertexData, verticesPerPartialBounds);
            _bounds = PartialBoundsUtils.mergeListToRectangle(partialBounds);
        }
        
        /**
        * Creates vertex and fragment programs from assembly.
        */
        private static function registerPrograms():void
        {
            var target:Starling = Starling.current;
            if(target.hasProgram(PROGRAM_NAME))
                return;
            
            // va0 -> position
            // va1 -> color
            // vc0 -> mvpMatrix (4 vectors, vc0 - vc3)
            // vc4 -> alpha
            
            var vertexProgramCode:String = 
                "m44 op, va0, vc0 \n" + // 4x4 matrix transform to output space
                "mul v0, va1, vc4 \n"; // multiply color with alpha and pass it to fragment shader
            
            // just forward incoming color
            var fragmentProgramCode:String = "mov oc, v0";
            
            var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode);
            
            var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentProgramCode);
            
            target.registerProgram(PROGRAM_NAME, vertexProgramAssembler.agalcode,
                fragmentProgramAssembler.agalcode);
        }
        
        /**
        * The old context was lost, a new buffers and shaders are created.
        */
        private function onContextCreated(event:Event):void
        {
            pointsChanged = true;
            colorChanged = true;
            thicknessChanged = true;
            update();
            registerPrograms();
        }
    }
}