package sk.yoz.ycanvas.demo.remotair
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    
    import net.hires.debug.Stats;
    
    import sk.yoz.touch.events.MultitouchDragZoomEvent;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.stage3D.YCanvasStage3D;
    import sk.yoz.ycanvas.utils.ILayerUtils;
    import sk.yoz.ycanvas.utils.IPartitionUtils;
    import sk.yoz.ycanvas.utils.TransformationUtils;
    
    [SWF(frameRate="60", backgroundColor="#ffffff")]
    public class ApplicationRemotair extends Sprite
    {
        private var canvas:YCanvasStage3D;
        private var position:Point;
        private var renderTimer:Timer = new Timer(500, 1);
        private var simulator:TouchSimulator = new TouchSimulator;
        private var multitouch:TransitionMultitouch = new TransitionMultitouch;
        
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
            render();
            
            addChild(simulator);
            multitouch.attach(simulator);
            
            simulator.addEventListener(MultitouchDragZoomEvent.DRAG_ZOOM, onDragZoom);
            stage.addEventListener(Event.RESIZE, onStageResize);
            simulator.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
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
            
            TransformationUtils.rotateScaleTo(canvas, 
                canvas.rotation + minifyRotation(event.rotation), 
                canvas.scale * event.scale, 
                canvas.globalToCanvas(event.lock))
            renderLater();
        }
        
        private function minifyRotation(rotation:Number):Number
        {
            while(rotation > Math.PI)   rotation -= Math.PI * 2;
            while(rotation < -Math.PI)  rotation += Math.PI * 2;
            return rotation;
        }
        
        private function onTouchBegin(event:TouchEvent):void
        {
            if(!event.isPrimaryTouchPoint)
                return;
            
            simulator.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
            simulator.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
            position = canvas.globalToCanvas(new Point(event.localX, event.localY));
        }
        
        private function onTouchMove(event:TouchEvent):void
        {
            if(!event.isPrimaryTouchPoint)
                return;
            
            var current:Point = canvas.globalToCanvas(new Point(event.localX, event.localY));
            var center:Point = new Point(
                canvas.center.x - current.x + position.x, 
                canvas.center.y - current.y + position.y);
            TransformationUtils.moveTo(canvas, center);
            position = canvas.globalToCanvas(new Point(event.localX, event.localY));
            render();
        }
        
        private function onTouchEnd(event:TouchEvent):void
        {
            if(!event.isPrimaryTouchPoint)
                return;
            
            simulator.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
            simulator.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
        }
    }
}