package sk.yoz.ycanvas.demo.simple
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.starling.YCanvasStarling;
    import sk.yoz.ycanvas.utils.ILayerUtils;
    import sk.yoz.ycanvas.utils.IPartitionUtils;
    import sk.yoz.ycanvas.utils.TransformationUtils;
    
    [SWF(frameRate="60", backgroundColor="#ffffff")]
    public class ApplicationDemo extends Sprite
    {
        private var canvas:YCanvasStarling;
        private var position:Point;
        
        public function ApplicationDemo()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
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
            
            stage.addEventListener(Event.RESIZE, onStageResize);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
        }
        
        private function render():void
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
        
        private function onMouseDown(event:MouseEvent):void
        {
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            position = canvas.globalToCanvas(new Point(stage.mouseX, stage.mouseY));
        }
        
        private function onMouseMove(event:MouseEvent):void
        {
            var current:Point = canvas.globalToCanvas(new Point(stage.mouseX, stage.mouseY));
            var center:Point = new Point(
                canvas.center.x - current.x + position.x, 
                canvas.center.y - current.y + position.y);
            TransformationUtils.moveTo(canvas, center);
            position = canvas.globalToCanvas(new Point(stage.mouseX, stage.mouseY));
            render();
        }
        
        private function onMouseUp(event:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
        
        private function onMouseWheel(event:MouseEvent):void
        {
            TransformationUtils.scaleTo(canvas, 
                canvas.scale * (event.delta > 0 ? 1.5 : 0.7), 
                canvas.globalToCanvas(new Point(stage.mouseX, stage.mouseY)));
            render();
        }
    }
}