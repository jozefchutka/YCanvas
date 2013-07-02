package sk.yoz.ycanvas.map
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    import sk.yoz.net.URLRequestBuffer;
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.map.display.MapComponent;
    import sk.yoz.ycanvas.map.display.MapLayer;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.events.PartitionEvent;
    import sk.yoz.ycanvas.map.layers.Layer;
    import sk.yoz.ycanvas.map.layers.LayerFactory;
    import sk.yoz.ycanvas.map.partitions.Partition;
    import sk.yoz.ycanvas.map.partitions.PartitionFactory;
    import sk.yoz.ycanvas.map.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    import sk.yoz.ycanvas.stage3D.YCanvasRootStage3D;
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
    
    public class MapController extends AbstractYCanvas implements IEventDispatcher
    {
        private var timer:Timer = new Timer(250, 1);
        private var _component:MapComponent;
        private var _config:MapConfig;
        
        private var dispatcher:EventDispatcher = new EventDispatcher;
        private var mapLayers:Vector.<MapLayer> = new Vector.<MapLayer>;
        
        public function MapController(config:MapConfig, init:CanvasTransformation)
        {
            _config = config;
            
            addEventListener(CanvasEvent.TRANSFORMATION_STARTED, onCanvasTransformationStarted);
            addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
            addEventListener(PartitionEvent.LOADED, onPartitionLoaded);
            
            _root = new YCanvasRootStage3D;
            
            _component = new MapComponent(this);
            component.addChild(root as YCanvasRootStage3D);
            component.addEventListener(MapComponent.VIEWPORT_UPDATED, onComponentViewPortUpdated);
            
            super(getViewPort());
            
            var buffer:URLRequestBuffer = new URLRequestBuffer(6, 10000);
            marginOffset = 256;
            partitionFactory = new PartitionFactory(config, this, buffer);
            layerFactory = new LayerFactory(config, partitionFactory);
            center = new Point(init.centerX, init.centerY);
            scale = init.scale;
            rotation = init.rotation;
            render();
            
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
        }
        
        public function get component():MapComponent
        {
            return _component;
        }
        
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
        
        override public function set center(value:Point):void
        {
            super.center = value;
            
            for(var i:uint = mapLayers.length; i--;)
                mapLayers[i].center = value;
            
            dispatchEvent(new CanvasEvent(CanvasEvent.CENTER_CHANGED));
        }
        
        override public function set scale(value:Number):void
        {
            super.scale = value;
            
            for(var i:uint = mapLayers.length; i--;)
                mapLayers[i].scale = value;
            
            dispatchEvent(new CanvasEvent(CanvasEvent.SCALE_CHANGED));
        }
        
        override public function set rotation(value:Number):void
        {
            super.rotation = value;
            
            for(var i:uint = mapLayers.length; i--;)
                mapLayers[i].rotation = rotation;
            
            dispatchEvent(new CanvasEvent(CanvasEvent.ROTATION_CHANGED));
        }
        
        public function get mainLayer():Layer
        {
            return layers[layers.length - 1] as Layer;
        }
        
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
        
        override public function render():void
        {
            super.render();
            IPartitionUtils.disposeInvisible(this);
            ILayerUtils.disposeEmpty(this);
            
            var main:Layer = layers[layers.length - 1] as Layer;
            for each(var layer:Layer in layers)
                (layer == main) ? startLoading(layer) : stopLoading(layer);
            
            dispatchEvent(new CanvasEvent(CanvasEvent.RENDERED));
        }
        
        public function hitTestComponent(x:Number, y:Number):Boolean
        {
            var engine:Starling = Starling.current;
            var starlingPoint:Point = new Point(x - engine.viewPort.x, y - engine.viewPort.y);
            return component.stage.hitTest(starlingPoint, true) == component;
        }
        
        public function addMapLayer(mapLayer:MapLayer):void
        {
            mapLayer.width = viewPort.width;
            mapLayer.height = viewPort.height;
            mapLayer.center = center;
            mapLayer.scale = scale;
            mapLayer.rotation = rotation;
            mapLayers.push(mapLayer);
            component.addChild(mapLayer);
        }
        
        public function removeMapLayer(mapLayer:MapLayer):void
        {
            mapLayers.splice(mapLayers.indexOf(mapLayer), 1);
            component.removeChild(mapLayer);
        }
        
        public function addEventListener(type:String, listener:Function, 
            useCapture:Boolean=false, priority:int=0, 
            useWeakReference:Boolean=false):void
        {
            dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        public function removeEventListener(type:String, listener:Function, 
            useCapture:Boolean=false):void
        {
            dispatcher.removeEventListener(type, listener, useCapture);
        }
        
        public function dispatchEvent(event:Event):Boolean
        {
            return dispatcher.dispatchEvent(event);
        }
        
        public function hasEventListener(type:String):Boolean
        {
            return dispatcher.hasEventListener(type);
        }
        
        public function willTrigger(type:String):Boolean
        {
            return dispatcher.willTrigger(type);
        }
        
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
        
        private function getViewPort():Rectangle
        {
            var starlingPoint:Point = component.localToGlobal(new Point(0, 0));
            return new Rectangle(
                    Starling.current.viewPort.x + starlingPoint.x, 
                    Starling.current.viewPort.y + starlingPoint.y, 
                    component.width, component.height);
        }
        
        private function sortByDistanceFromCenter(partition1:Partition, partition2:Partition):Number
        {
            var x1:Number = partition1.x + partition1.expectedWidth * .5 - center.x;
            var y1:Number = partition1.y + partition1.expectedHeight * .5 - center.y;
            var x2:Number = partition2.x + partition2.expectedWidth * .5 - center.x;
            var y2:Number = partition2.y + partition2.expectedHeight * .5 - center.y;
            return (x1 * x1 + y1 * y1) - (x2 * x2 + y2 * y2);
        }
        
        private function resetTimer():void
        {
            if(timer.running)
                return;
            timer.reset();
            timer.start();
        }
        
        private function onCanvasTransformationStarted(event:CanvasEvent):void
        {
            resetTimer();
        }
        
        private function onCanvasTransformationFinished(event:CanvasEvent):void
        {
            render();
        }
        
        private function onPartitionLoaded(event:PartitionEvent):void
        {
            var partition:Partition = event.partition;
            var layer:Layer = partition.layer;
            if(mainLayer != layer)
                return;
            
            var layerPartitions:Vector.<LayerPartitions> = 
                IPartitionUtils.getLower(this, layer, partition);
            IPartitionUtils.diposeLayerPartitionsList(this, layerPartitions);
            ILayerUtils.disposeEmpty(this);
        }
        
        private function onTimerComplete(event:Event):void
        {
            render();
        }
        
        private function onComponentViewPortUpdated():void
        {
            viewPort = getViewPort();
            render();
        }
    }
}