package sk.yoz.ycanvas.stage3D.elements
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
    import sk.yoz.ycanvas.utils.StrokeUtils;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    import starling.utils.VertexData;
    
    public class Stroke extends DisplayObject
    {
        private static var PROGRAM_NAME:String = "YStroke";
        private static var HELPER_MATRIX:Matrix = new Matrix();
        private static var RENDER_ALPHA:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
        
        public var autoUpdate:Boolean = true;
        
        private var _points:Vector.<Number>;
        private var _thickness:Number;
        private var _color:Number;
        private var _joints:Boolean;
        private var _bounds:Rectangle;
        
        private var vertexData:VertexData;
        private var vertexBuffer:VertexBuffer3D;
        
        private var indexData:Vector.<uint>;
        private var indexBuffer:IndexBuffer3D;
        
        public function Stroke(points:Vector.<Number>, thickness:Number = 1, 
            color:uint=0xffffff, alpha:Number=1, joints:Boolean=true,
            autoUpdate:Boolean=true)
        {
            _points = points;
            _thickness = thickness;
            _color = color;
            _joints = joints;
            this.alpha = alpha;
            this.autoUpdate = autoUpdate;
            
            if(autoUpdate)
                update();
            
            registerPrograms();
            
            Starling.current.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
        }
        
        public override function dispose():void
        {
            Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
            
            if(vertexBuffer)
                vertexBuffer.dispose();
            
            if(indexBuffer)
                indexBuffer.dispose();
            
            super.dispose();
        }
        
        public function set points(value:Vector.<Number>):void
        {
            if(points == value)
                return;
            
            _points == value;
            if(autoUpdate)
                update();
        }
        
        public function get points():Vector.<Number>
        {
            return _points;
        }
        
        public function set thickness(value:Number):void
        {
            if(thickness == value)
                return;
            
            _thickness = value;
            if(autoUpdate)
                update();
        }
        
        public function get thickness():Number
        {
            return _thickness;
        }
        
        public function set color(value:uint):void
        {
            if(color == value)
                return;
            
            _color = value;
            if(autoUpdate)
                update();
        }
        
        public function get color():uint
        {
            return _color;
        }
        
        public function set joints(value:Boolean):void
        {
            if(joints == value)
                return;
            
            _joints = value;
            if(autoUpdate)
                update();
        }
        
        public function get joints():Boolean
        {
            return _joints;
        }
        
        override public function get bounds():Rectangle
        {
            return _bounds;
        }
        
        public function update():void
        {
            vertexData = StrokeUtils.pointsToVertexData(points, thickness);
            vertexData.setUniformColor(color);
            
            _bounds = vertexData.getBounds();
            
            indexData = StrokeUtils.vertexDataToIndexData(vertexData, joints);
            
            var context:Context3D = Starling.context;
            if(context == null)
                throw new MissingContextError();
            
            if(vertexBuffer)
                vertexBuffer.dispose();
            if(indexBuffer)
                indexBuffer.dispose();
            
            vertexBuffer = context.createVertexBuffer(vertexData.numVertices, VertexData.ELEMENTS_PER_VERTEX);
            vertexBuffer.uploadFromVector(vertexData.rawData, 0, vertexData.numVertices);
            
            indexBuffer = context.createIndexBuffer(indexData.length);
            indexBuffer.uploadFromVector(indexData, 0, indexData.length);
        }
        
        override public function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            if(forTouch && (!visible || !touchable))
                return null;
            
            if(!bounds.containsPoint(localPoint))
                return null;
            
            var offset:uint;
            for(var i:uint = 0, length:uint = indexData.length; i < length; i += 3)
            {
                var i1:uint = indexData[i];
                var i2:uint = indexData[uint(i + 1)];
                var i3:uint = indexData[uint(i + 2)];
                
                offset = i1 * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
                var p1x:Number = vertexData.rawData[offset];
                var p1y:Number = vertexData.rawData[uint(offset + 1)];
                
                offset = i2 * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
                var p2x:Number = vertexData.rawData[offset];
                var p2y:Number = vertexData.rawData[uint(offset + 1)];
                
                offset = i3 * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
                var p3x:Number = vertexData.rawData[offset];
                var p3y:Number = vertexData.rawData[uint(offset + 1)];
                
                if(FastCollisions.pointInTriangle(localPoint.x, localPoint.y, p1x, p1y, p2x, p2y, p3x, p3y))
                    return this;
            }
            
            return null;
        }
        
        override public function render(support:RenderSupport, alpha:Number):void
        {
            support.finishQuadBatch();
            support.raiseDrawCount();
            
            RENDER_ALPHA[0] = RENDER_ALPHA[1] = RENDER_ALPHA[2] = 1.0;
            RENDER_ALPHA[3] = alpha * this.alpha;
            
            var context:Context3D = Starling.context;
            if(context == null)
                throw new MissingContextError();
            
            support.applyBlendMode(false);
            
            context.setProgram(Starling.current.getProgram(PROGRAM_NAME));
            context.setVertexBufferAt(0, vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
            context.setVertexBufferAt(1, vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, RENDER_ALPHA, 1);
            
            context.drawTriangles(indexBuffer, 0, indexData.length / 3);
            
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
        }
        
        private static function registerPrograms():void
        {
            var target:Starling = Starling.current;
            if (target.hasProgram(PROGRAM_NAME))
                return; // already registered
            
            // va0 -> position
            // va1 -> color
            // vc0 -> mvpMatrix (4 vectors, vc0 - vc3)
            // vc4 -> alpha
            
            var vertexProgramCode:String =
                "m44 op, va0, vc0 \n" + // 4x4 matrix transform to output space
                "mul v0, va1, vc4 \n";  // multiply color with alpha and pass it to fragment shader
            
            var fragmentProgramCode:String =
                "mov oc, v0";           // just forward incoming color
            
            var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode);
            
            var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentProgramCode);
            
            target.registerProgram(PROGRAM_NAME, vertexProgramAssembler.agalcode,
                fragmentProgramAssembler.agalcode);
        }
        
        private function onContextCreated(event:Event):void
        {
            update();
            registerPrograms();
        }
    }
}