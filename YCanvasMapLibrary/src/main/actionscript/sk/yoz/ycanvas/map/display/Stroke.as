package sk.yoz.ycanvas.map.display
{
    import flash.display3D.Context3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.map.utils.PartialBoundsUtils;
    import sk.yoz.ycanvas.map.utils.StrokeUtils;
    import sk.yoz.ycanvas.map.utils.VertexDataUtils;
    import sk.yoz.ycanvas.map.valueObjects.PartialBounds;
    
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.errors.MissingContextError;
    import starling.events.Event;
    
    /**
    * Starling implementation for simple stroke.
    */
    public class Stroke extends AbstractGraphics
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
        
        public function Stroke(points:Vector.<Number>, thickness:Number = 1, 
            color:uint=0xffffff, alpha:Number=1, 
            autoUpdate:Boolean=true)
        {
            _points = points;
            _thickness = thickness;
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
        * Updates vertex data and index data based on points, thickness and 
        * color.
        */
        public function update():void
        {
            if(!pointsChanged && !thicknessChanged && !colorChanged)
                return;
            
            var context:Context3D = Starling.context;
            if(context == null)
                throw new MissingContextError();
            
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
            
            if(vertexDataChanged)
                updateVertexBuffer();
            
            if(indexDataChanged)
                updateIndexBuffer();
        }
        
        /**
        * For performance optimization, first the main bounds is tested for a 
        * collision, then partial bounds and in case a collision is detected in 
        * a specific partial bounds all the necessary triagles are evaluated 
        * for a collision as well. 
        */
        override public function hitTest(localPoint:Point, 
            forTouch:Boolean=false):DisplayObject
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
                
                if(hitTestIndices(localPoint, partialBound.indiceIndexMin,
                    partialBound.indiceIndexMax))
                    return this;
            }
            
            return null;
        }
        
        /**
        * Calculates the main bounds.
        */
        private function updateBounds():void
        {
            partialBounds = VertexDataUtils.getPartialBoundsList(vertexData,
                verticesPerPartialBounds);
            _bounds = PartialBoundsUtils.mergeListToRectangle(partialBounds);
        }
        
        /**
        * The old context was lost, a new buffers and shaders are created.
        */
        override protected function onContextCreated(event:Event):void
        {
            pointsChanged = true;
            colorChanged = true;
            thicknessChanged = true;
            update();
            super.onContextCreated(event);
        }
    }
}