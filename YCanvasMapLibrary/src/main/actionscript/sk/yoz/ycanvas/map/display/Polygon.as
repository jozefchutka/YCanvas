package sk.yoz.ycanvas.map.display
{
    import flash.display3D.Context3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.map.utils.PolygonUtils;
    
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    
    public class Polygon extends AbstractGraphics
    {
        /**
        * Program/shader name.
        */
        private static const PROGRAM_NAME:String = "YCanvasPolygon";
        
        /**
        * If true, changing points or color would be automatically rendered.
        * If false, update() method must be called manualy.
        */
        public var autoUpdate:Boolean = true;
        
        /**
        * Variable holder for points.
        */
        private var _points:Vector.<Number>;
        
        /**
        * Variable holder for color.
        */
        private var _color:Number;
        
        /**
        * Variable holder for bounds.
        */
        private var _bounds:Rectangle;
        
        /**
        * Flag describing that points variable has changed.
        */
        private var pointsChanged:Boolean = true;
        
        /**
        * Flag describing that color variable has changed.
        */
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
        
        /**
        * Program/shader name.
        */
        override protected function get programName():String
        {
            return PROGRAM_NAME;
        }
        
        /**
        * Array of x, y values defining the polygon shape.
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
        * Polygon fill Color.
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
        * Updates vertex data and index data based on points and color.
        */
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
        
        /**
        * For performance optimization, first the main bounds is tested for a 
        * collision, then all the triagles are evaluated for a collision. 
        */
        override public function hitTest(localPoint:Point, 
            forTouch:Boolean=false):DisplayObject
        {
            if(forTouch && (!visible || !touchable))
                return null;
            
            if(!bounds.containsPoint(localPoint))
                return null;
            
            if(hitTestIndices(localPoint, 0, indexData.length - 1))
                return this;
            
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