package sk.yoz.ycanvas.demo.starlingComponent
{
    import com.adobe.utils.AGALMiniAssembler;
    
    import flash.display3D.*;
    import flash.geom.*;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    import starling.utils.VertexData;
    
    /** This custom display objects renders a regular, n-sided polygon. */
    public class Circle extends DisplayObject
    {
        private static var PROGRAM_NAME:String = "polygon";
        
        // custom members
        private var mRadius:Number;
        private var mNumEdges:int;
        private var mColor:uint;
        
        // vertex data 
        private var mVertexData:VertexData;
        private var mVertexBuffer:VertexBuffer3D;
        
        // index data
        private var mIndexData:Vector.<uint>;
        private var mIndexBuffer:IndexBuffer3D;
        
        // helper objects (to avoid temporary objects)
        private static var sHelperMatrix:Matrix = new Matrix();
        private static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
        
        /** Creates a regular polygon with the specified redius, number of edges, and color. */
        public function Circle(radius:Number, numEdges:int=6, color:uint=0xffffff)
        {
            if (numEdges < 3) throw new ArgumentError("Invalid number of edges");
            
            mRadius = radius;
            mNumEdges = numEdges;
            mColor = color;
            
            // setup vertex data and prepare shaders
            setupVertices();
            createBuffers();
            registerPrograms();
            
            // handle lost context
            Starling.current.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
        }
        
        /** Disposes all resources of the display object. */
        public override function dispose():void
        {
            Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
            
            if (mVertexBuffer) mVertexBuffer.dispose();
            if (mIndexBuffer)  mIndexBuffer.dispose();
            
            super.dispose();
        }
        
        private function onContextCreated(event:Event):void
        {
            // the old context was lost, so we create new buffers and shaders.
            setupVertices();
            createBuffers();
            registerPrograms();
        }
        
        /** Returns a rectangle that completely encloses the object as it appears in another 
         * coordinate system. */
        public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle
        {
            if (resultRect == null) resultRect = new Rectangle();
            
            var transformationMatrix:Matrix = targetSpace == this ? 
                null : getTransformationMatrix(targetSpace, sHelperMatrix);
            
            return mVertexData.getBounds(transformationMatrix, 0, -1, resultRect);
        }
        
        /** Creates the required vertex- and index data and uploads it to the GPU. */ 
        private function setupVertices():void
        {
            var i:int;
            
            // create vertices
            
            mVertexData = new VertexData(mNumEdges+1);
            mVertexData.setUniformColor(mColor);
            
            for (i=0; i<mNumEdges; ++i)
            {
                var edge:Point = Point.polar(mRadius, i*2*Math.PI / mNumEdges);
                mVertexData.setPosition(i, edge.x, edge.y);
            }
            
            mVertexData.setPosition(mNumEdges, 0.0, 0.0); // center vertex
            
            // create indices that span up the triangles
            
            mIndexData = new <uint>[];
            
            for (i=0; i<mNumEdges; ++i)
                mIndexData.push(mNumEdges, i, (i+1)%mNumEdges);
        }
        
        /** Creates new vertex- and index-buffers and uploads our vertex- and index-data to those
         *  buffers. */ 
        private function createBuffers():void
        {
            var context:Context3D = Starling.context;
            if (context == null) throw new MissingContextError();
            
            if (mVertexBuffer) mVertexBuffer.dispose();
            if (mIndexBuffer)  mIndexBuffer.dispose();
            
            mVertexBuffer = context.createVertexBuffer(mVertexData.numVertices, VertexData.ELEMENTS_PER_VERTEX);
            mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, mVertexData.numVertices);
            
            mIndexBuffer = context.createIndexBuffer(mIndexData.length);
            mIndexBuffer.uploadFromVector(mIndexData, 0, mIndexData.length);
        }
        
        /** Renders the object with the help of a 'support' object and with the accumulated alpha
         * of its parent object. */
        public override function render(support:RenderSupport, alpha:Number):void
        {
            // always call this method when you write custom rendering code!
            // it causes all previously batched quads/images to render.
            support.finishQuadBatch();
            
            // make this call to keep the statistics display in sync.
            support.raiseDrawCount();
            
            sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = 1.0;
            sRenderAlpha[3] = alpha * this.alpha;
            
            var context:Context3D = Starling.context;
            if (context == null) throw new MissingContextError();
            
            // apply the current blendmode
            support.applyBlendMode(false);
            
            // activate program (shader) and set the required buffers / constants 
            context.setProgram(Starling.current.getProgram(PROGRAM_NAME));
            context.setVertexBufferAt(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
            context.setVertexBufferAt(1, mVertexBuffer, VertexData.COLOR_OFFSET,    Context3DVertexBufferFormat.FLOAT_4);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);            
            context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, sRenderAlpha, 1);
            
            // finally: draw the object!
            context.drawTriangles(mIndexBuffer, 0, mNumEdges);
            
            // reset buffers
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
        }
        
        /** Creates vertex and fragment programs from assembly. */
        private static function registerPrograms():void
        {
            var target:Starling = Starling.current;
            if (target.hasProgram(PROGRAM_NAME)) return; // already registered
            
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
        
        /** The radius of the polygon in points. */
        public function get radius():Number { return mRadius; }
        public function set radius(value:Number):void { mRadius = value; setupVertices();createBuffers(); }
        
        /** The number of edges of the regular polygon. */
        public function get numEdges():int { return mNumEdges; }
        public function set numEdges(value:int):void { mNumEdges = value; setupVertices();createBuffers(); }
        
        /** The color of the regular polygon. */
        public function get color():uint { return mColor; }
        public function set color(value:uint):void { mColor = value; setupVertices();createBuffers(); }
    }
}