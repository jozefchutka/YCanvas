package sk.yoz.ycanvas.demo.remotair
{
    import com.greensock.TweenMax;
    
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    import net.hires.debug.Stats;
    
    import sk.yoz.touch.MultitouchDragZoom;
    import sk.yoz.touch.events.MultitouchDragZoomEvent;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.stage3D.YCanvasStage3D;
    import sk.yoz.ycanvas.utils.ILayerUtils;
    import sk.yoz.ycanvas.utils.IPartitionUtils;
    
    [SWF(frameRate="60", backgroundColor="#ffffff")]
    public class ApplicationRemotair extends Sprite
    {
        private var canvas:YCanvasStage3D;
        private var position:Point;
        private var renderTimer:Timer = new Timer(500, 1);
        private var simulator:TouchSimulator = new TouchSimulator;
        private var multitouch:MultitouchDragZoom = new MultitouchDragZoom;
        private var currentTransformation:CanvasTransformation = new CanvasTransformation;
        private var targetTransformation:CanvasTransformation = new CanvasTransformation;
        
        public function ApplicationRemotair()
        {
            addChild(new Stats);
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            canvas = new YCanvasStage3D(stage, stage.stage3Ds[0], viewPort, canvasInit);
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
            currentTransformation.fromCanvas(canvas);
            targetTransformation.fromCanvas(canvas);
            render();
            
            addChild(simulator);
            multitouch.attach(simulator);
            simulator.addEventListener(MultitouchDragZoomEvent.DRAG_ZOOM, onDragZoom);
            
            stage.addEventListener(Event.RESIZE, onStageResize);
            
            renderTimer.addEventListener(TimerEvent.TIMER_COMPLETE, render);
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
        
        private function renderLater():void
        {
            if(renderTimer.running)
                return;
            
            renderTimer.reset();
            renderTimer.start();
        }
        
        private function startLoading(layer:Layer):void
        {
            var partition:Partition;
            var list:Vector.<IPartition> = layer.partitions;
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
        
        private function onStageResize(event:Event):void
        {
            canvas.viewPort = viewPort;
            render();
        }
        
        private function onDragZoom(event:MultitouchDragZoomEvent):void
        {
            if(event.scale == 1 && event.rotation == 0)
                return;
            
            targetTransformation.applyScaleRotation(
                event.scale, 
                event.rotation, 
                event.lock,
                canvas);
            
            TweenMax.to(currentTransformation, .2, {
                centerX:targetTransformation.centerX, 
                centerY:targetTransformation.centerY, 
                rotation:targetTransformation.rotation, 
                scale:targetTransformation.scale, 
                onUpdate:onTweenUpdate});
        }
        
        private function onTweenUpdate():void
        {
            currentTransformation.toCanvas(canvas);
            renderLater();
        }
    }
}