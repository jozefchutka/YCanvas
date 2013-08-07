package sk.yoz.ycanvas.map.display
{
    import flash.display3D.Context3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.math.FastCollisions;
    import sk.yoz.ycanvas.map.utils.PolygonUtils;
    
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    import starling.utils.VertexData;
    
    public class Polygon extends AbstractGraphics
    {
        private static const PROGRAM_NAME:String = "YCanvasPolygon";
        
        public var autoUpdate:Boolean = true;
        
        private var _points:Vector.<Number>;
        private var _color:Number;
        private var _bounds:Rectangle;
        
        private var pointsChanged:Boolean = true;
        private var colorChanged:Boolean = true;
        
        public function Polygon(points:Vector.<Number>, color:uint=0xffffff,
            alpha:Number=1, autoUpdate:Boolean=true)
        {
            _points = points;
            _color = color;
            this.autoUpdate = autoUpdate;
            
            super();
            this.alpha = alpha;
            
            if(autoUpdate)
                update();
        }
        
        override protected function get programName():String
        {
            return PROGRAM_NAME;
        }
        
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
        
        override public function get bounds():Rectangle
        {
            return _bounds;
        }
        
        public function update():void
        {
            if(!pointsChanged && !colorChanged)
                return;
            
            var vertexDataChanged:Boolean = false;
            var indexDataChanged:Boolean = false;
            if(pointsChanged)
            {
                vertexData = PolygonUtils.pointsToVertexData(points);
                indexData = PolygonUtils.triangulate(points);
                vertexDataChanged = true;
                indexDataChanged = true;
                updateBounds();
            }
            
            if(colorChanged || vertexDataChanged)
            {
                vertexData.setUniformColor(color);
                vertexDataChanged = true;
            }
            
            pointsChanged = false;
            colorChanged = false;
            
            var context:Context3D = Starling.context;
            if(context == null)
                throw new MissingContextError();
            
            if(vertexDataChanged)
                updateVertexBuffer();
            
            if(indexDataChanged)
                updateIndexBuffer();
        }
        
        override public function hitTest(localPoint:Point, 
            forTouch:Boolean=false):DisplayObject
        {
            if(forTouch && (!visible || !touchable))
                return null;
            
            if(!bounds.containsPoint(localPoint))
                return null;
            
            var offset:uint, offset1:uint, i1:uint, i2:uint;
            var elementsPerVertex:uint = VertexData.ELEMENTS_PER_VERTEX;
            var positionOffset:uint = VertexData.POSITION_OFFSET;
            for(var i:uint = 0, length:uint = indexData.length; i < length; i += 3)
            {
                offset = indexData[i] * elementsPerVertex + positionOffset;
                offset1 = offset + 1;
                var p1x:Number = vertexData.rawData[offset];
                var p1y:Number = vertexData.rawData[offset1];
                
                i1 = i + 1;
                offset = indexData[i1] * elementsPerVertex + positionOffset;
                offset1 = offset + 1;
                var p2x:Number = vertexData.rawData[offset];
                var p2y:Number = vertexData.rawData[offset1];
                
                i2 = i + 2;
                offset = indexData[i2] * elementsPerVertex + positionOffset;
                offset1 = offset + 1;
                var p3x:Number = vertexData.rawData[offset];
                var p3y:Number = vertexData.rawData[offset1];
                
                if(FastCollisions.pointInTriangle(localPoint.x, 
                    localPoint.y, p1x, p1y, p2x, p2y, p3x, p3y))
                    return this;
            }
            
            return null;
        }
        
        /**
        * Calculates the main bounds.
        */
        private function updateBounds():void
        {
            _bounds = PolygonUtils.getRectangle(points);
        }
        
        /**
        * The old context was lost, a new buffers and shaders are created.
        */
        override protected function onContextCreated(event:Event):void
        {
            pointsChanged = true;
            colorChanged = true;
            update();
            super.onContextCreated(event);
        }
    }
}