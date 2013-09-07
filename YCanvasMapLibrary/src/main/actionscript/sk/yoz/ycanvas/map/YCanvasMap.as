package sk.yoz.ycanvas.map
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.map.display.MapDisplay;
    import sk.yoz.ycanvas.map.display.MapLayer;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.events.PartitionEvent;
    import sk.yoz.ycanvas.map.layers.Layer;
    import sk.yoz.ycanvas.map.layers.LayerFactory;
    import sk.yoz.ycanvas.map.partitions.Partition;
    import sk.yoz.ycanvas.map.partitions.PartitionFactory;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    import sk.yoz.ycanvas.map.valueObjects.Transformation;
    import sk.yoz.ycanvas.starling.YCanvasRootStarling;
    import sk.yoz.ycanvas.utils.ILayerUtils;
    import sk.yoz.ycanvas.utils.IPartitionUtils;
    import sk.yoz.ycanvas.valueObjects.LayerPartitions;
    
    import starling.core.Starling;
    
    [Event(name="canvasTransformationStarted", type="sk.yoz.ycanvas.map.events.CanvasEvent")]
    [Event(name="canvasTransformationFinished", type="sk.yoz.ycanvas.map.events.CanvasEvent")]
    [Event(name="canvasCenterChanged", type="sk.yoz.ycanvas.map.events.CanvasEvent")]
    [Event(name="canvasScaleChanged", type="sk.yoz.ycanvas.map.events.CanvasEvent")]
    [Event(name="canvasRotationChanged", type="sk.yoz.ycanvas.map.events.CanvasEvent")]
    [Event(name="canvasRendered", type="sk.yoz.ycanvas.map.events.CanvasEvent")]
    
    [Event(name="partitionLoaded", type="sk.yoz.ycanvas.map.events.PartitionEvent")]
    
    /**
    * Map implementation of YCanvas.
    */
    public class YCanvasMap extends AbstractYCanvas implements IEventDispatcher
    {
        /**
        * Timer is started on any canvas transformation and executes render() 
        * method when complete. 
        */
        private var timer:Timer = new Timer(250, 1);
        
        /**
        * Variable holder for display.
        */
        private var _display:MapDisplay;
        
        /**
        * Variable holder for config.
        */
        private var _config:MapConfig;
        
        /**
        * This is the main dispatcher for this class as this class is expected
        * to dispatch events.
        */
        private var dispatcher:EventDispatcher = new EventDispatcher;
        
        /**
        * List of layers currently available.
        */
        private var mapLayers:Vector.<MapLayer> = new Vector.<MapLayer>;
        
        /**
        * Max count of map layers to be rendered and preserved in cache.
        */
        protected var maxLayers:uint;
        
        public function YCanvasMap(config:MapConfig, 
            transformation:Transformation, marginOffset:uint=0,
            maxLayers:uint=0)
        {
            _config = config;
            this.marginOffset = marginOffset;
            this.maxLayers = maxLayers;
            
            _root = new YCanvasRootStarling;
            
            _display = new MapDisplay;
            display.addChild(root as YCanvasRootStarling);
            display.addEventListener(MapDisplay.VIEWPORT_UPDATED, onComponentViewPortUpdated);
            
            super(getViewPort());
            
            partitionFactory = new PartitionFactory(config, this);
            layerFactory = new LayerFactory(config, partitionFactory);
            center = new Point(transformation.centerX, transformation.centerY);
            scale = transformation.scale;
            rotation = transformation.rotation;
            
            addEventListener(CanvasEvent.TRANSFORMATION_STARTED, onCanvasTransformationStarted);
            addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
            addEventListener(PartitionEvent.LOADED, onPartitionLoaded);
            
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
        }
        
        /**
         * Starling DisplayObject.
         */
        public function get display():MapDisplay
        {
            return _display;
        }
        
        /**
        * Map config for the controller. When changed:
        * 1. partitionFactory config is updated
        * 2. all except main layers are disposed
        * 3. main layer config is updated
        * 4. main layer partitions config is updated (triggers partition reload)
        */
        public function set config(value:MapConfig):void
        {
            if(config == value)
                return;
            
            _config = value;
            
            if(partitionFactory)
                (partitionFactory as PartitionFactory).config = config;
            
            while(layers.length > 1)
                disposeLayer(layers[0]);
            
            (layers[0] as Layer).config = config;
            
            var list:Vector.<IPartition> = layers[0].partitions;
            list.sort(sortByDistanceFromCenter);
            for(var i:uint = 0, length:uint = list.length; i < length; i++)
                (list[i] as Partition).config = config;
        }
        
        public function get config():MapConfig
        {
            return _config;
        }
        
        /**
        * @inheritDoc
        */
        override public function set center(value:Point):void
        {
            super.center = value;
            
            for(var i:uint = mapLayers.length; i--;)
                mapLayers[i].center = value;
            
            dispatchEvent(new CanvasEvent(CanvasEvent.CENTER_CHANGED));
        }
        
        /**
        * @inheritDoc
        */
        override public function set scale(value:Number):void
        {
            super.scale = value;
            
            for(var i:uint = mapLayers.length; i--;)
                mapLayers[i].scale = value;
            
            dispatchEvent(new CanvasEvent(CanvasEvent.SCALE_CHANGED));
        }
        
        /**
        * @inheritDoc
        */
        override public function set rotation(value:Number):void
        {
            super.rotation = value;
            
            for(var i:uint = mapLayers.length; i--;)
                mapLayers[i].rotation = rotation;
            
            dispatchEvent(new CanvasEvent(CanvasEvent.ROTATION_CHANGED));
        }
        
        /**
        * Returns top most map layer.
        */
        public function get mainLayer():Layer
        {
            return layers[layers.length - 1] as Layer;
        }
        
        /**
        * @inheritDoc
        */
        override public function set viewPort(value:Rectangle):void
        {
            super.viewPort = value;
            
            for(var i:uint = mapLayers.length; i--;)
            {
                mapLayers[i].width = value.width;
                mapLayers[i].height = value.height;
            }
            
            resetTimer();
        }
        
        /**
        * @inheritDoc
        */
        override public function render():void
        {
            super.render();
            IPartitionUtils.disposeInvisible(this);
            ILayerUtils.disposeEmpty(this);
            
            if(layers.length)
            {
                var main:Layer = mainLayer;
                for each(var layer:Layer in layers)
                    (layer == main) ? startLoading(layer) : stopLoading(layer);
            }
            
            dispatchEvent(new CanvasEvent(CanvasEvent.RENDERED));
        }
        
        /**
        * Returns true if global point hits current component viewport.
        */
        public function hitTestComponent(x:Number, y:Number):Boolean
        {
            var viewPort:Rectangle = Starling.current.viewPort;
            var starlingPoint:Point = new Point(x - viewPort.x, y - viewPort.y);
            return display.stage.hitTest(starlingPoint, true) == display;
        }
        
        /**
        * Adds map layer to the controller.
        */
        public function addMapLayer(mapLayer:MapLayer):void
        {
            mapLayer.width = viewPort.width;
            mapLayer.height = viewPort.height;
            mapLayer.center = center;
            mapLayer.scale = scale;
            mapLayer.rotation = rotation;
            mapLayers.push(mapLayer);
            display.addChild(mapLayer);
        }
        
        /**
        * Removes map layer from the controller.
        */
        public function removeMapLayer(mapLayer:MapLayer):void
        {
            mapLayers.splice(mapLayers.indexOf(mapLayer), 1);
            display.removeChild(mapLayer);
        }
        
        /**
        * @inheritDoc
        */
        override public function dispose():void
        {
            while(mapLayers.length)
            {
                var mapLayer:MapLayer = mapLayers[0];
                mapLayer.removeChildren();
                removeMapLayer(mapLayer);
            }
            
            timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
            timer.stop();
            timer = null;
            
            super.dispose();
        }
        
        /**
        * Required by IEventDispatcher implementation.
        */
        public function addEventListener(type:String, listener:Function, 
            useCapture:Boolean=false, priority:int=0, 
            useWeakReference:Boolean=false):void
        {
            dispatcher.addEventListener(type, listener, useCapture, priority,
                useWeakReference);
        }
        
        /**
        * Required by IEventDispatcher implementation.
        */
        public function removeEventListener(type:String, listener:Function, 
            useCapture:Boolean=false):void
        {
            dispatcher.removeEventListener(type, listener, useCapture);
        }
        
        /**
        * Required by IEventDispatcher implementation.
        */
        public function dispatchEvent(event:Event):Boolean
        {
            return dispatcher.dispatchEvent(event);
        }
        
        /**
        * Required by IEventDispatcher implementation.
        */
        public function hasEventListener(type:String):Boolean
        {
            return dispatcher.hasEventListener(type);
        }
        
        /**
        * Required by IEventDispatcher implementation.
        */
        public function willTrigger(type:String):Boolean
        {
            return dispatcher.willTrigger(type);
        }
        
        /**
        * Loads necessary partitions for a layer.
        */
        private function startLoading(layer:Layer):void
        {
            var partition:Partition;
            var list:Vector.<IPartition> = layer.partitions;
            list.sort(sortByDistanceFromCenter);
            for(var i:uint = 0, length:uint = list.length; i < length; i++)
            {
                partition = list[i] as Partition;
                if(!partition.loading && !partition.loaded)
                    partition.load();
            }
        }
        
        /**
        * Cancels partition loading in layer.
        */
        private function stopLoading(layer:Layer):void
        {
            var partition:Partition;
            var list:Vector.<IPartition> = layer.partitions;
            for(var i:uint = 0, length:uint = list.length; i < length; i++)
            {
                partition = list[i] as Partition;
                if(partition.loading)
                    partition.stopLoading();
            }
        }
        
        /**
        * Returns component viewport in global coordinates.
        */
        private function getViewPort():Rectangle
        {
            var starlingPoint:Point = display.localToGlobal(new Point(0, 0));
            return new Rectangle(
                Starling.current.viewPort.x + starlingPoint.x, 
                Starling.current.viewPort.y + starlingPoint.y, 
                display.width, display.height);
        }
        
        /**
        * Sorting method for partitions.
        */
        private function sortByDistanceFromCenter(partition1:Partition,
            partition2:Partition):Number
        {
            var x1:Number = partition1.x + partition1.expectedWidth * .5 - center.x;
            var y1:Number = partition1.y + partition1.expectedHeight * .5 - center.y;
            var x2:Number = partition2.x + partition2.expectedWidth * .5 - center.x;
            var y2:Number = partition2.y + partition2.expectedHeight * .5 - center.y;
            return (x1 * x1 + y1 * y1) - (x2 * x2 + y2 * y2);
        }
        
        /**
        * Resets the timer.
        */
        private function resetTimer():void
        {
            if(timer.running)
                return;
            timer.reset();
            timer.start();
        }
        
        /**
        * Listener for transformation tween start.
        */
        private function onCanvasTransformationStarted(event:CanvasEvent):void
        {
            resetTimer();
        }
        
        /**
        * Listener for transformation tween finish.
        */
        private function onCanvasTransformationFinished(event:CanvasEvent):void
        {
            render();
        }
        
        /**
        * Listener for partition loaded.
        */
        private function onPartitionLoaded(event:PartitionEvent):void
        {
            var partition:Partition = event.partition;
            var layer:ILayer = partition.layer;
            if(mainLayer != layer)
                return;
            
            var layerPartitions:Vector.<LayerPartitions> = 
                IPartitionUtils.getLower(this, layer, partition);
            IPartitionUtils.diposeLayerPartitionsList(this, layerPartitions);
            ILayerUtils.disposeEmpty(this);
            if(maxLayers)
                ILayerUtils.disposeDeep(this, maxLayers);
        }
        
        /**
        * Listener for timer complete.
        */
        private function onTimerComplete(event:Event):void
        {
            render();
        }
        
        /**
        * Listener for component viewport update.
        */
        private function onComponentViewPortUpdated():void
        {
            viewPort = getViewPort();
            render();
        }
    }
}