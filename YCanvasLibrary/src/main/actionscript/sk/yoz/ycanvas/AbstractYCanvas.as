package sk.yoz.ycanvas
{
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.IBitmapDrawable;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.math.FastCollisions;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.ILayerFactory;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    import sk.yoz.ycanvas.interfaces.IYCanvasRoot;
    import sk.yoz.ycanvas.utils.DisplayObjectUtils;
    import sk.yoz.ycanvas.valueObjects.MarginPoints;
    
    /**
    * An abstract YCanvas class providing shared functionality for any 
    * implemetation. While stage3D implementation will require viewPort 
    * rectangle, lets base all the implementations on viewPort.
    */
    public class AbstractYCanvas
    {
        /**
        * A factory to be used for partition live cycle.
        */
        public var partitionFactory:IPartitionFactory;
        
        /**
        * A factory to be used for layer live cycle.
        */
        public var layerFactory:ILayerFactory;
        
        /**
        * An internal pointer to a root instance.
        */
        protected var _root:IYCanvasRoot;
        
        /**
        * An offset to be used when calculating default margin points (amount 
        * of pixels in global coordinates). Increase the value in order to 
        * include even those invisible (marginal) partitions within rendering.
        */
        protected var marginOffset:uint = 0;
        
        /**
        * An internal cached conversion matrix.
        */
        private var cachedConversionMatrix:Matrix;
        
        /**
        * An internal cached viewPort points.
        */
        private var cachedMarginPoints:MarginPoints;
        
        /**
        * A value holder to a center point.
        */
        private var _center:Point = new Point(0, 0);
        
        /**
        * A value holder for rotation (in radians).
        */
        private var _rotation:Number = 0;
        
        /**
        * A value holder for scale.
        */
        private var _scale:Number = 1;
        
        /**
        * A value holder for viewPort.
        */
        private var _viewPort:Rectangle = new Rectangle(0, 0, 640, 480);
        
        /**
        * A constructor.
        */
        public function AbstractYCanvas(viewPort:Rectangle)
        {
            this.viewPort = viewPort;
        }
        
        /**
        * A public getter/setter for viewPort rectangle.
        */
        public function set viewPort(value:Rectangle):void
        {
            _viewPort = value;
            invalidateTransformationCache();
            centerRoot();
        }
        
        public function get viewPort():Rectangle
        {
            return _viewPort;
        }
        
        /**
        * A public getter/setter for center point.
        */
        public function set center(value:Point):void
        {
            _center = value;
            for(var i:uint = 0, length:uint = layers.length; i < length; i++)
                centerLayer(layers[i]);
            invalidateTransformationCache();
        }
        
        public function get center():Point
        {
            return _center;
        }
        
        /**
        * A public getter/setter for rotation in radians.
        */
        public function set rotation(value:Number):void
        {
            _rotation = root.rotation = value;
            invalidateTransformationCache();
        }
        
        public function get rotation():Number
        {
            return _rotation;
        }
        
        /**
        * A public getter/setter for scale.
        */
        public function set scale(value:Number):void
        {
            _scale = root.scale = value;
            for(var i:uint = 0, length:uint = layers.length; i < length; i++)
                scaleLayer(layers[i]);
            invalidateTransformationCache();
        }
        
        public function get scale():Number
        {
            return _scale;
        }
        
        public function get root():IYCanvasRoot
        {
            return _root;
        }
        
        public function get layers():Vector.<ILayer>
        {
            return root.layers;
        }
        
        /**
        * Returns a conversion matrix based on current transformation values.
        */
        public function get conversionMatrix():Matrix
        {
            if(cachedConversionMatrix)
                return cachedConversionMatrix;
            
            cachedConversionMatrix = 
                getConversionMatrix(center, scale, rotation, viewPort);
            return cachedConversionMatrix;
        }
        
        /**
        * Returns screenshot for actual viewPort.
        */
        public function get bitmapData():BitmapData
        {
            throw new Error("This method must be overriden.");
        }
        
        /**
        * Shows stats.
        */
        public function set showStats(value:Boolean):void
        {
            throw new Error("This method must be overriden.");
        }
        
        /**
        * Return margin points (4 corner points of viewPort) in canvas 
        * coordinates based on current canvas transformation and validation
        * margin offset.
        */
        public function get marginPoints():MarginPoints
        {
            if(cachedMarginPoints)
                return cachedMarginPoints;
            
            cachedMarginPoints = getMarginPoints(viewPort, marginOffset);
            return cachedMarginPoints;
        }
        
        /**
        * Converts the point object from the Stage (global) coordinates to the
        * canvas coordinates.
        */
        public function globalToCanvas(globalPoint:Point):Point
        {
            var point:Point = globalToViewPort(globalPoint);
            var matrix:Matrix = conversionMatrix.clone();
            matrix.invert();
            return matrix.transformPoint(point);
        }
        
        /**
        * Converts the point object from the Stage (global) coordinates to the
        * viewPort coordinates.
        */
        public function globalToViewPort(globalPoint:Point):Point
        {
            return new Point(
                globalPoint.x - viewPort.x, globalPoint.y - viewPort.y);
        }
        
        /**
        * Converts the point object from the canvas coordinates to the
        * Stage (global) coordinates.
        */
        public function canvasToGlobal(canvasPoint:Point):Point
        {
            var matrix:Matrix = conversionMatrix.clone();
            var viewPortPoint:Point = matrix.transformPoint(canvasPoint);
            return viewPortToGlobal(viewPortPoint);
        }
        
        /**
        * Converts the point object from the canvas coordinates to the
        * viewPort coordinates.
        */
        public function canvasToViewPort(canvasPoint:Point):Point
        {
            return globalToViewPort(canvasToGlobal(canvasPoint));
        }
        
        /**
        * Converts the point object from the viewPort coordinates to the
        * canvas coordinates.
        */
        public function viewPortToCanvas(viewPortPoint:Point):Point
        {
            return globalToCanvas(viewPortToGlobal(viewPortPoint));
        }
        
        /**
        * Converts the point object from the viewPort coordinates to the
        * Stage (global) coordinates.
        */
        public function viewPortToGlobal(viewPortPoint:Point):Point
        {
            return new Point(
                viewPortPoint.x + viewPort.x, viewPortPoint.y + viewPort.y);
        }
        
        /**
        * Executes layer validation and validates visible partitions on this 
        * layer.
        */
        public function render():void
        {
            var layer:ILayer = layerFactory.create(scale, center);
            scaleLayer(layer);
            centerLayer(layer);
            root.addLayer(layer);
            addPartitions(layer, getVisiblePartitions(layer));
        }
        
        /**
        * Disposes whole YCanvas.
        */
        public function dispose():void
        {
            while(root.layers.length)
                disposeLayer(root.layers[0]);
            root.dispose();
            _root = null;
            partitionFactory = null;
            layerFactory = null;
        }
        
        /**
        * Provides complete layer dispose.
        */
        public function disposeLayer(layer:ILayer):void
        {
            root.removeLayer(layer);
            layerFactory.disposeLayer(layer);
        }
        
        /**
        * Provides complete partition dispose.
        */
        public function disposePartition(layer:ILayer, 
            partition:IPartition):void
        {
            layer.removePartition(partition);
            partitionFactory.disposePartition(partition);
        }
        
        /**
        * Returns conversion matrix based on custom transformation parameters.
        * Value can be used for transformation canvas point into viewPort 
        * coordinates.
        */
        public function getConversionMatrix(center:Point, scale:Number, 
            rotation:Number, viewPort:Rectangle):Matrix
        {
            var result:Matrix = new Matrix();
            result.translate(-center.x, -center.y);
            result.scale(scale, scale);
            result.rotate(rotation % (Math.PI * 2));
            result.translate(viewPort.width / 2, viewPort.height / 2);
            return result;
        }
        
        /**
        * Returns a list of all partitions that are visible in the layer. 
        * The missing partitions are created.
        */
        public function getVisiblePartitions(layer:ILayer):Vector.<IPartition>
        {
            return getVisiblePartitionsByMarginPoints(layer, marginPoints);
        }
        
        /**
        * Returns a list of all partitions that are visible within custom 
        * margin points. The missing partitions are created.
        */
        public function getVisiblePartitionsByMarginPoints(layer:ILayer, 
            marginPoints:MarginPoints):Vector.<IPartition>
        {
            var w:uint = layer.partitionWidth * layer.level;
            var h:uint = layer.partitionHeight * layer.level;
            var x0:int = Math.floor(marginPoints.getMinX() / w) * w;
            var x1:int = Math.floor(marginPoints.getMaxX() / w) * w;
            var y0:int = Math.floor(marginPoints.getMinY() / h) * h;
            var y1:int = Math.floor(marginPoints.getMaxY() / h) * h;
            var result:Vector.<IPartition> = new Vector.<IPartition>;
            
            for(var x:int = x0; x <= x1; x += w)
            for(var y:int = y0; y <= y1; y += h)
                if(isCollision(marginPoints, x, y, w, h))
                    result.push(layer.getPartition(x, y) 
                        || partitionFactory.create(x, y, layer));
            return result;
        }
        
        /**
        * Converts global points to canvas points based on values.
        */
        public function getMarginPoints(globalPoints:Rectangle, offset:uint=0)
            :MarginPoints
        {
            var x0:Number = globalPoints.left - offset;
            var x1:Number = globalPoints.right + offset;
            var y0:Number = globalPoints.top - offset;
            var y1:Number = globalPoints.bottom + offset;
            return MarginPoints.fromPoints(
                globalToCanvas(new Point(x0, y0)),
                globalToCanvas(new Point(x1, y0)),
                globalToCanvas(new Point(x1, y1)),
                globalToCanvas(new Point(x0, y1)));
        }
        
        /**
        * Applies any display object on stage to all existing paritions with 
        * proper transformation matrix.
        * 
        * @param source DisplayObject must be added on stage.
        */
        public function applyDisplayObject(source:DisplayObject):void
        {
            applyIBitmapDrawableWithMatrix(source, 
                DisplayObjectUtils.getConcatenatedMatrix(source));
        }
        
        /**
         * Applies display object to all existing paritions using 
         * transformation matrix.
         * 
         * @param source Any DisplayObject.
         * @param sourceMatrix Any Matrix.
         */
        public function applyIBitmapDrawableWithMatrix(source:IBitmapDrawable, 
            sourceMatrix:Matrix):void
        {
            var matrix:Matrix, partitionMatrix:Matrix;
            
            for each(var layer:ILayer in layers)
            for each(var partition:IPartition in layer.partitions)
            {
                partitionMatrix = partition.concatenatedMatrix;
                partitionMatrix.invert();
                
                matrix = sourceMatrix.clone();
                matrix.translate(-viewPort.x, -viewPort.y);
                matrix.concat(partitionMatrix);
                partition.applyIBitmapDrawable(source, matrix);
            }
        }
        
        /**
        * Tests collision of margin points (in canvas coordinates) against 
        * some canvas rectangle defined by x, y, width, height.
        */
        public function isCollision(marginPoints:MarginPoints, 
            x:Number, y:Number, width:Number, height:Number):Boolean
        {
            return FastCollisions.rectangles(
                marginPoints.x1, marginPoints.y1, 
                marginPoints.x2, marginPoints.y2, 
                marginPoints.x3, marginPoints.y3, 
                marginPoints.x4, marginPoints.y4,
                x, y, x + width, y, x + width, y + height, x, y + height);
        }
        
        /**
        * Aligns root to vertical and horizontal center.
        */
        protected function centerRoot():void
        {
            root.x = viewPort.width / 2;
            root.y = viewPort.height / 2;
        }
        
        /**
        * Provides current center to a layer. All layers should be always in 
        * sync with canvas center.
        */
        protected function centerLayer(layer:ILayer):void
        {
            layer.center = center;
        }
        
        /**
        * Scales layer based on its level. The flash.display implementation 
        * will require custom scale handling as there are some flash player 
        * limitations.
        */
        protected function scaleLayer(layer:ILayer):void
        {
            layer.scale = layer.level;
        }
        
        /**
        * Adds a list of partitions to a layer.
        */
        protected function addPartitions(layer:ILayer, 
            partitions:Vector.<IPartition>):void
        {
            var length:uint = partitions.length;
            for(var i:uint = 0; i < length; i++)
                layer.addPartition(partitions[i]);
        }
        
        /**
        * Invalidates all cached transformation values.
        */
        protected function invalidateTransformationCache():void
        {
            cachedConversionMatrix = null;
            cachedMarginPoints = null;
        }
    }
}