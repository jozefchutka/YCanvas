package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    import sk.yoz.net.URLRequestBuffer;
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.demo.starlingComponent.events.CanvasEvent;
    import sk.yoz.ycanvas.demo.starlingComponent.events.PartitionEvent;
    import sk.yoz.ycanvas.demo.starlingComponent.layers.Layer;
    import sk.yoz.ycanvas.demo.starlingComponent.layers.LayerFactory;
    import sk.yoz.ycanvas.demo.starlingComponent.partitions.Partition;
    import sk.yoz.ycanvas.demo.starlingComponent.partitions.PartitionFactory;
    import sk.yoz.ycanvas.demo.starlingComponent.valueObjects.Mode;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.stage3D.YCanvasRootStage3D;
    import sk.yoz.ycanvas.utils.ILayerUtils;
    import sk.yoz.ycanvas.utils.IPartitionUtils;
    import sk.yoz.ycanvas.valueObjects.LayerPartitions;
    
    import starling.core.Starling;
    import starling.display.Sprite;
    
    public class YCanvasStarlingComponentController extends AbstractYCanvas
    {
        private var _markers:Vector.<Marker> = new Vector.<Marker>;
        
        private var timer:Timer = new Timer(250, 1);
        private var _component:YCanvasStarlingComponent;
        private var _transformationManager:TransformationManager;
        private var _dispatcher:IEventDispatcher;
        
        private var markersContainer:Sprite = new Sprite;
        
        private var _mode:Mode;
        
        public function YCanvasStarlingComponentController(mode:Mode, stage:Stage)
        {
            _mode = mode;
            
            _dispatcher = new EventDispatcher();
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_STARTED, onCanvasTransformationStarted);
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
            dispatcher.addEventListener(PartitionEvent.LOADED, onPartitionLoaded);
            
            _root = new YCanvasRootStage3D;
            
            _component = new YCanvasStarlingComponent(dispatcher);
            component.addChild(root as YCanvasRootStage3D);
            component.addEventListener(YCanvasStarlingComponent.VIEWPORT_UPDATED, onWrapperViewPortUpdated);
            
            component.addChild(markersContainer);
            
            super(getViewPort());
            
            var buffer:URLRequestBuffer = new URLRequestBuffer(6, 10000);
            marginOffset = 256;
            partitionFactory = new PartitionFactory(mode, dispatcher, buffer);
            layerFactory = new LayerFactory(partitionFactory);
            center = new Point(mode.initCenterX, mode.initCenterY);
            scale = mode.initScale;
            rotation = mode.initRotaton;
            render();
            
            _transformationManager = new TransformationManager(this, dispatcher, stage);
            transformationManager.minScale = mode.minScale;
            transformationManager.maxScale = mode.maxScale;
            transformationManager.minCenterX = mode.minCenterX;
            transformationManager.maxCenterX = mode.maxCenterX;
            transformationManager.minCenterY = mode.minCenterY;
            transformationManager.maxCenterY = mode.maxCenterY;
            
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
        }
        
        public function get transformationManager():TransformationManager
        {
            return _transformationManager;
        }
        
        public function get dispatcher():IEventDispatcher
        {
            return _dispatcher;
        }
        
        public function get component():YCanvasStarlingComponent
        {
            return _component;
        }
        
        public function set mode(value:Mode):void
        {
            if(mode == value)
                return;
            
            _mode = value;
            
            if(partitionFactory)
                (partitionFactory as PartitionFactory).mode = mode;
            
            while(layers.length > 1)
                disposeLayer(layers[0]);
            
            var list:Vector.<IPartition> = layers[0].partitions;
            list.sort(sortByDistanceFromCenter);
            for(var i:uint = 0, length:uint = list.length; i < length; i++)
                (list[i] as Partition).mode = mode;
        }
        
        public function get mode():Mode
        {
            return _mode;
        }
        
        override public function set center(value:Point):void
        {
            super.center = value;
            
            for(var i:uint = markers.length; i--;)
                markers[i].canvasCenter = value;
            
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.CENTER_CHANGED));
        }
        
        override public function set scale(value:Number):void
        {
            super.scale = value;
            
            for(var i:uint = markers.length; i--;)
                markers[i].canvasScale = value;
            
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.SCALE_CHANGED));
        }
        
        override public function set rotation(value:Number):void
        {
            super.rotation = value;
            
            for(var i:uint = markers.length; i--;)
                markers[i].canvasRotation = value;
            
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.ROTATION_CHANGED));
        }
        
        public function get markers():Vector.<Marker>
        {
            return _markers;
        }
        
        override public function render():void
        {
            super.render();
            IPartitionUtils.disposeInvisible(this);
            ILayerUtils.disposeEmpty(this);
            
            var main:Layer = layers[layers.length - 1] as Layer;
            for each(var layer:Layer in layers)
                (layer == main) ? startLoading(layer) : stopLoading(layer);
                
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.RENDERED));
        }
        public function hitTest(x:Number, y:Number):Boolean
        {
            var engine:Starling = Starling.current;
            var starlingPoint:Point = new Point(x - engine.viewPort.x, y - engine.viewPort.y);
            return component.stage.hitTest(starlingPoint) == component;
        }
        
        public function addMarker(marker:Marker):void
        {
            markersContainer.addChild(marker);
            marker.canvasCenter = center;
            marker.canvasScale = scale;
            marker.canvasRotation = rotation;
            markers.push(marker);
            
            trace(marker.localToGlobal(new Point(0, 0)));
        }
        
        public function removeMarker(marker:Marker):void
        {
            markersContainer.removeChild(marker);
            markers.splice(markers.indexOf(marker), 1);
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
        
        public function get mainLayer():Layer
        {
            return layers[layers.length - 1] as Layer;
        }
        
        override public function set viewPort(value:Rectangle):void
        {
            super.viewPort = value;
            resetTimer();
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
        
        private function onWrapperViewPortUpdated():void
        {
            viewPort = getViewPort();
            render();
        }
    }
}