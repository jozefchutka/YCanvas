package sk.yoz.ycanvas.map.display
{
    import com.adobe.utils.AGALMiniAssembler;
    
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    import starling.utils.VertexData;
    
    public class Triangle extends DisplayObject
    {
        private static var PROGRAM_NAME:String = "polygon";
        
        private var p1x:Number;
        private var p1y:Number;
        
        private var p2x:Number;
        private var p2y:Number;
        
        private var p3x:Number;
        private var p3y:Number;
        
        private var color:uint;
        
        private var vertexData:VertexData;
        private var vertexBuffer:VertexBuffer3D;
        
        private var indexData:Vector.<uint>;
        private var indexBuffer:IndexBuffer3D;
        
        private static var sHelperMatrix:Matrix = new Matrix();
        private static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
        
        public function Triangle(p1x:Number, p1y:Number, p2x:Number, p2y:Number, p3x:Number, p3y:Number, color:uint=0xffffff)
        {
            setup(p1x, p1y, p2x, p2y, p3x, p3y, color);
            registerPrograms();
            
            Starling.current.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
        }
        
        public function setup(p1x:Number, p1y:Number, p2x:Number, p2y:Number, p3x:Number, p3y:Number, color:uint):void
        {
            if(this.p1x == p1x && this.p1y == p1y
                && this.p2x == p2x && this.p2y == p2y
                && this.p3x == p3x && this.p3y == p3y
                && this.color == color)
                return;
            
            this.p1x = p1x;
            this.p1y = p1y;
            this.p2x = p2x;
            this.p2y = p2y;
            this.p3x = p3x;
            this.p3y = p3y;
            this.color = color;
            setupVertices();
            createBuffers();
        }
        
        override public function dispose():void
        {
            Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
            
            if(vertexBuffer)
                vertexBuffer.dispose();
            
            if(indexBuffer)
                indexBuffer.dispose();
            
            super.dispose();
        }
        
        override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            if(resultRect == null)
                resultRect = new Rectangle();
            
            var transformationMatrix:Matrix = targetSpace == this ? 
                null : getTransformationMatrix(targetSpace, sHelperMatrix);
            
            return vertexData.getBounds(transformationMatrix, 0, -1, resultRect);
        }
        
        private function setupVertices():void
        {
            vertexData = new VertexData(3);
            vertexData.setUniformColor(color);
            vertexData.setPosition(0, p1x, p1y);
            vertexData.setPosition(1, p2x, p2y);
            vertexData.setPosition(2, p3x, p3y);
            
            indexData = new <uint>[0, 1, 2];
        }
        
        private function createBuffers():void
        {
            var context:Context3D = Starling.context;
            if(context == null)
                throw new MissingContextError();
            
            if(vertexBuffer)
                vertexBuffer.dispose();
            
            if(indexBuffer)
                indexBuffer.dispose();
            
            vertexBuffer = context.createVertexBuffer(3, VertexData.ELEMENTS_PER_VERTEX);
            vertexBuffer.uploadFromVector(vertexData.rawData, 0, 3);
            
            indexBuffer = context.createIndexBuffer(3);
            indexBuffer.uploadFromVector(indexData, 0, 3);
        }
        
        public override function render(support:RenderSupport, alpha:Number):void
        {
            support.finishQuadBatch();
            support.raiseDrawCount();
            
            sRenderAlpha[3] = alpha * this.alpha;
            
            var context:Context3D = Starling.context;
            if(context == null)
                throw new MissingContextError();
            
            support.applyBlendMode(false);
            
            context.setProgram(Starling.current.getProgram(PROGRAM_NAME));
            context.setVertexBufferAt(0, vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
            context.setVertexBufferAt(1, vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, sRenderAlpha, 1);
            context.drawTriangles(indexBuffer, 0, 1);
            
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
        }
        
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
            setupVertices();
            registerPrograms();
        }
    }
}