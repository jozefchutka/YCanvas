package sk.yoz.ycanvas.map.display
{
    import com.adobe.utils.AGALMiniAssembler;
    
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    import starling.utils.VertexData;
    
    public class AbstractGraphics extends DisplayObject
    {
        /**
        * Vertex data are calculated.
        */
        protected var vertexData:VertexData;
        private var vertexBuffer:VertexBuffer3D;
        
        /**
        * Index data.
        */
        protected var indexData:Vector.<uint>;
        private var indexBuffer:IndexBuffer3D;
        
        /**
        * Helper object to avoid temporary objects.
        */
        private var renderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
        
        public function AbstractGraphics()
        {
            var type:String = Event.CONTEXT3D_CREATE;
            Starling.current.addEventListener(type, onContextCreated);
            
            registerPrograms();
            
            super();
        }
        
        protected function get programName():String
        {
            throw new Error("Method not implemented");
        }
        
        /**
        * Disposes all resources and listeners.
        */
        public override function dispose():void
        {
            var type:String = Event.CONTEXT3D_CREATE;
            Starling.current.removeEventListener(type, onContextCreated);
            
            if(vertexBuffer)
                vertexBuffer.dispose();
            
            if(indexBuffer)
                indexBuffer.dispose();
            
            super.dispose();
        }
        
        /**
        * @inheritDoc
        */
        override public function render(support:RenderSupport, 
            alpha:Number):void
        {
            support.finishQuadBatch();
            support.raiseDrawCount();
            
            renderAlpha[3] = alpha * this.alpha;
            
            var context:Context3D = Starling.context;
            if(context == null)
                throw new MissingContextError();
            
            support.applyBlendMode(false);
            
            context.setProgram(Starling.current.getProgram(programName));
            context.setVertexBufferAt(0, vertexBuffer, 
                VertexData.POSITION_OFFSET,
                Context3DVertexBufferFormat.FLOAT_2); 
            context.setVertexBufferAt(1, vertexBuffer, VertexData.COLOR_OFFSET,
                Context3DVertexBufferFormat.FLOAT_4);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,
                0, support.mvpMatrix3D, true);
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
                4, renderAlpha, 1);
            
            context.drawTriangles(indexBuffer, 0, indexData.length / 3);
            
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
        }
        
        protected function updateVertexBuffer():void
        {
            if(vertexBuffer)
                vertexBuffer.dispose();
            
            vertexBuffer = Starling.context.createVertexBuffer(
                vertexData.numVertices, VertexData.ELEMENTS_PER_VERTEX);
            vertexBuffer.uploadFromVector(vertexData.rawData, 0, 
                vertexData.numVertices);
        }
        
        protected function updateIndexBuffer():void
        {
            if(indexBuffer)
                indexBuffer.dispose();
            
            indexBuffer = Starling.context.createIndexBuffer(indexData.length);
            indexBuffer.uploadFromVector(indexData, 0, indexData.length);
        }
        
        /**
        * Creates vertex and fragment programs from assembly.
        */
        private function registerPrograms():void
        {
            if(Starling.current.hasProgram(programName))
                return;
            
            // va0 -> position
            // va1 -> color
            // vc0 -> mvpMatrix (4 vectors, vc0 - vc3)
            // vc4 -> alpha
            
            // 4x4 matrix transform to output space
            // multiply color with alpha and pass it to fragment shader
            var vertex:AGALMiniAssembler = new AGALMiniAssembler();
            vertex.assemble(Context3DProgramType.VERTEX, 
                "m44 op, va0, vc0 \n" + 
                "mul v0, va1, vc4 \n");
            
            // just forward incoming color
            var fragment:AGALMiniAssembler = new AGALMiniAssembler();
            fragment.assemble(Context3DProgramType.FRAGMENT, "mov oc, v0");
            
            Starling.current.registerProgram(programName, vertex.agalcode,
                fragment.agalcode);
        }
        
        /**
        * The old context was lost, a new buffers and shaders are created.
        */
        protected function onContextCreated(event:Event):void
        {
            registerPrograms();
        }
    }
}