package sk.yoz.ycanvas.demo.remotair
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import net.hires.debug.Stats;
    
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.starling.YCanvasStarling;
    import sk.yoz.ycanvas.utils.ILayerUtils;
    import sk.yoz.ycanvas.utils.IPartitionUtils;
    
    [SWF(frameRate="60", backgroundColor="#ffffff")]
    public class ApplicationRemotair extends Sprite
    {
        private var canvas:YCanvasStarling;
        private var transformationManager:TransformationManager;
        
        public function ApplicationRemotair()
        {
            stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(...rest):void
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            if(loaderInfo.parameters.debug == "true")
                addChild(new Stats);
            
            canvas = new YCanvasStarling(stage, stage.stage3Ds[0], viewPort, canvasInit);
            canvas.partitionFactory = new PartitionFactory;
            canvas.layerFactory = new LayerFactory(canvas.partitionFactory);
        }
        
        private function get viewPort():Rectangle
        {
            return new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
        }
        
        private function canvasInit():void
        {
            canvas.center = new Point(35e6, 25e6);
            canvas.scale = 1 / 16384;
            render();
            
            transformationManager = new TransformationManager(canvas);
            addChild(transformationManager.simulator);
            
            stage.addEventListener(Event.RESIZE, onStageResize);
            transformationManager.addEventListener(Event.RENDER, render);
        }
        
        private function render(...rest):void
        {
            canvas.render();
            IPartitionUtils.disposeInvisible(canvas);
            ILayerUtils.disposeEmpty(canvas);
            
            var main:Layer = canvas.layers[canvas.layers.length - 1] as Layer;
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
        
        private function onStageResize(event:Event):void
        {
            canvas.viewPort = viewPort;
            render();
        }
    }
}