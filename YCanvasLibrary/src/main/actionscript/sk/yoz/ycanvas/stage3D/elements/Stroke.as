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
        
        private function onContextCreated(event:Event):void
        {
            update();
            registerPrograms();
        }
        
        public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            if (resultRect == null)
                resultRect = new Rectangle();
            
            var transformationMatrix:Matrix = targetSpace == this 
                ? null
                : getTransformationMatrix(targetSpace, HELPER_MATRIX);
            
            return vertexData.getBounds(transformationMatrix, 0, -1, resultRect);
        }
        
        public function update():void
        {
            vertexData = pointsToVertexData(points, thickness);
            vertexData.setUniformColor(color);
            
            indexData = vertexDataToIndexData(vertexData, joints);
            
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
            //TODO optimize by checking rectangle bounds first
            
            if(forTouch && (!visible || !touchable))
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
        
        public static function pointsToVertexData(points:Vector.<Number>, thickness:Number):VertexData
        {
            var vertices:Vector.<Number> = pointsToVertices(points, thickness);
            var result:VertexData = new VertexData(vertices.length / 2);
            for(var i:uint = 0, p:uint = 0, length:uint = vertices.length; i < length; i += 4, p += 2)
            {
                result.setPosition(p, vertices[i], vertices[i + 1]);
                result.setPosition(p + 1, vertices[i + 2], vertices[i + 3]);
            }
            
            return result;
        }
        
        public static function vertexDataToIndexData(vertexData:VertexData, joints:Boolean):Vector.<uint>
        {
            var result:Vector.<uint> = new Vector.<uint>;
            for(var i:uint = 0, length:uint = vertexData.numVertices - 2; i < length; i++)
            {
                result.push(i, i + 1, i + 2);
                if(!joints && i%2)
                    i += 2;
            }
            return result;
        }
        
        private static function pointsToVertices(points:Vector.<Number>, thickness:Number):Vector.<Number>
        {
            var p0x:Number = points[0], p0y:Number = points[1];
            var xi:uint = 2, yi:uint = 3;
            var t2:Number = thickness / 2;
            var result:Vector.<Number> = new Vector.<Number>;
            
            for(var length:uint = points.length; xi < length; xi += 2, yi += 2)
            {
                var override:Boolean = false;
                var p1x:Number = points[xi], p1y:Number = points[yi];
                var rotation:Number = Math.atan2(p1y - p0y, p1x - p0x);
                var dx:Number = Math.sin(rotation) * t2;
                var dy:Number = Math.cos(rotation) * t2;
                var v0x:Number = p0x + dx, v0y:Number = p0y - dy;
                var v1x:Number = p0x - dx, v1y:Number = p0y + dy;
                
                if(v0x == v2x && v0y == v2y && v1x == v3x && v1y == v3y)
                    override = true;
                
                var v2x:Number = p1x + dx, v2y:Number = p1y - dy;
                var v3x:Number = p1x - dx, v3y:Number = p1y + dy;
                
                if(override)
                {
                    result.splice(result.length - 4, 4);
                    result.push(v2x, v2y, v3x, v3y);
                }
                else
                {
                    result.push(v0x, v0y, v1x, v1y, v2x, v2y, v3x, v3y);
                }
                
                p0x = p1x, p0y = p1y;
            }
            
            return result;
        }
    }
}