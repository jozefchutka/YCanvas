package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.demo.starlingComponent.events.CanvasEvent;
    import sk.yoz.ycanvas.demo.starlingComponent.events.PartitionEvent;
    import sk.yoz.ycanvas.demo.starlingComponent.partitions.AbstractPartition;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.stage3D.YCanvasRootStage3D;
    import sk.yoz.ycanvas.utils.ILayerUtils;
    import sk.yoz.ycanvas.utils.IPartitionUtils;
    import sk.yoz.ycanvas.valueObjects.LayerPartitions;
    
    public class YCanvasStarlingComponentController extends AbstractYCanvas
    {
        private var timer:Timer = new Timer(250, 1);
        private var dispatcher:IEventDispatcher;
        
        public function YCanvasStarlingComponentController(viewPort:Rectangle, partitionConstructor:Class, dispatcher:IEventDispatcher)
        {
            _root = new YCanvasRootStage3D;
            
            super(viewPort);
            
            marginOffset = 256;
            partitionFactory = new PartitionFactory(partitionConstructor, dispatcher);
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
            var partition:AbstractPartition;
            var list:Vector.<IPartition> = layer.partitions;
            for(var i:uint = 0, length:uint = list.length; i < length; i++)
            {
                partition = list[i] as AbstractPartition;
                if(!partition.loading && !partition.loaded)
                    partition.load();
            }
        }
        
        private function stopLoading(layer:Layer):void
        {
            var partition:AbstractPartition;
            var list:Vector.<IPartition> = layer.partitions;
            for(var i:uint = 0, length:uint = list.length; i < length; i++)
            {
                partition = list[i] as AbstractPartition;
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
        
        private function sortByDistanceFromCenter(partition1:AbstractPartition, partition2:AbstractPartition):Number
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
        
        private function onCanvasTransformationFinished(event:CanvasEvent):void
        {
            render();
        }
        
        private function onCanvasTransformationStarted(event:CanvasEvent):void
        {
            resetTimer();
        }
        
        private function onPartitionLoaded(event:PartitionEvent):void
        {
            var partition:AbstractPartition = event.partition;
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