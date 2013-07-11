package sk.yoz.ycanvas.demo.explorer.managers
{
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.demo.explorer.events.CanvasEvent;
    import sk.yoz.ycanvas.demo.explorer.events.PartitionEvent;
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.Mode;
    import sk.yoz.ycanvas.demo.explorer.modes.Partition;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.starling.YCanvasStarling;
    import sk.yoz.ycanvas.utils.ILayerUtils;
    import sk.yoz.ycanvas.utils.IPartitionUtils;
    import sk.yoz.ycanvas.valueObjects.LayerPartitions;

    public class CanvasManager
    {
        private var _canvas:AbstractYCanvas;
        private var timer:Timer = new Timer(250, 1);
        private var canvasInitCallback:Function;
        private var dispatcher:IEventDispatcher;
        
        public function CanvasManager(stage:Stage, stage3D:Stage3D, 
            viewPort:Rectangle, canvasInitCallback:Function, 
            dispatcher:IEventDispatcher)
        {
            this.dispatcher = dispatcher;
            this.canvasInitCallback = canvasInitCallback;
            
            _canvas = new YCanvasStarling(stage, stage3D, viewPort, canvasInit);
            
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_STARTED, onCanvasTransformationStarted);
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
            dispatcher.addEventListener(PartitionEvent.LOADED, onPartitionLoaded);
        }
        
        public function set mode(value:Mode):void
        {
            while(canvas.layers.length)
                canvas.disposeLayer(canvas.layers[0]);
            
            var partitionFactoryClass:Class = value.partitionFactory;
            var layerFactoryClass:Class = value.layerFactory;
            
            canvas.partitionFactory = new partitionFactoryClass(dispatcher, value.factoryData);
            canvas.layerFactory = new layerFactoryClass(canvas.partitionFactory, value.factoryData);
            canvas.center = new Point(value.transformation.centerX,
                value.transformation.centerY);
            canvas.rotation = value.transformation.rotation;
            canvas.scale = value.transformation.scale;
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
            render();
        }
        
        public function get canvas():AbstractYCanvas
        {
            return _canvas;
        }
        
        public function get mainLayer():Layer
        {
            return canvas.layers[canvas.layers.length - 1] as Layer;
        }
        
        public function set viewPort(value:Rectangle):void
        {
            canvas.viewPort = value;
            resetTimer();
        }
        
        private function render():void
        {
            canvas.render();
            IPartitionUtils.disposeInvisible(canvas);
            ILayerUtils.disposeEmpty(canvas);
            
            var main:Layer = mainLayer;
            for each(var layer:Layer in canvas.layers)
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
        
        private function sortByDistanceFromCenter(partition1:Partition, partition2:Partition):Number
        {
            var x1:Number = partition1.x + partition1.expectedWidth * .5 - canvas.center.x;
            var y1:Number = partition1.y + partition1.expectedHeight * .5 - canvas.center.y;
            var x2:Number = partition2.x + partition2.expectedWidth * .5 - canvas.center.x;
            var y2:Number = partition2.y + partition2.expectedHeight * .5 - canvas.center.y;
            return (x1 * x1 + y1 * y1) - (x2 * x2 + y2 * y2);
        }
        
        private function resetTimer():void
        {
            if(timer.running)
                return;
            timer.reset();
            timer.start();
        }
        
        private function canvasInit():void
        {
            if(canvasInitCallback != null)
                canvasInitCallback();
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
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
            var partition:Partition = event.partition;
            var layer:Layer = partition.layer;
            if(mainLayer != layer)
                return;
            
            var layerPartitions:Vector.<LayerPartitions> = 
                IPartitionUtils.getLower(canvas, layer, partition);
            IPartitionUtils.diposeLayerPartitionsList(canvas, layerPartitions);
            ILayerUtils.disposeEmpty(canvas);
        }
        
        private function onTimerComplete(event:Event):void
        {
            render();
        }
    }
}