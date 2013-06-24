package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.events.Event;
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
    
    public class YCanvasStarlingComponentController extends AbstractYCanvas
    {
        private var timer:Timer = new Timer(250, 1);
        private var dispatcher:IEventDispatcher;
        
        private var _mode:Mode;
        
        public function YCanvasStarlingComponentController(viewPort:Rectangle, mode:Mode, dispatcher:IEventDispatcher)
        {
            _root = new YCanvasRootStage3D;
            _mode = mode;
            
            super(viewPort);
            
            var buffer:URLRequestBuffer = new URLRequestBuffer(6, 10000);
            marginOffset = 256;
            partitionFactory = new PartitionFactory(mode, dispatcher, buffer);
            layerFactory = new LayerFactory(partitionFactory);
            center = new Point(35e6, 25e6);
            scale = 1 / 16384;
            render();
            
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_STARTED, onCanvasTransformationStarted);
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
            dispatcher.addEventListener(PartitionEvent.LOADED, onPartitionLoaded);
            
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
        }
        
        public function get component():YCanvasRootStage3D
        {
            return root as YCanvasRootStage3D;
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
        
        override public function render():void
        {
            super.render();
            IPartitionUtils.disposeInvisible(this);
            ILayerUtils.disposeEmpty(this);
            
            var main:Layer = layers[layers.length - 1] as Layer;
            for each(var layer:Layer in layers)
                (layer == main) ? startLoading(layer) : stopLoading(layer);
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
    }
}