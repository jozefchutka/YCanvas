package sk.yoz.ycanvas.map.managers
{
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.valueObjects.CanvasLimit;
    
    import starling.core.Starling;
    
    /**
    * Transformation manager implementation for mouse interactions.
    */
    public class MouseTransformationManager extends AbstractTransformationManager
    {
        private var last:Point;
        
        public function MouseTransformationManager(canvas:MapController, 
            limit:CanvasLimit, transitionDuration:Number=.5)
        {
            super(canvas, limit, transitionDuration);
        }
        
        override public function dispose():void
        {
            stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
            
            super.dispose();
        }
        
        override public function set allowMove(value:Boolean):void
        {
            if(allowMove == value)
                return;
            
            super.allowMove = value
            if(allowMove)
                stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
            else
                stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
        }
        
        override public function set allowZoom(value:Boolean):void
        {
            if(allowZoom == value)
                return;
            
            super.allowZoom = value;
            if(allowZoom)
                stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
            else
                stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
        }
        
        override protected function set allowInteractions(value:Boolean):void
        {
            if(allowInteractions == value)
                return;
            
            super.allowInteractions = value;
            if(allowInteractions)
                stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
            else
                stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }
        
        private function get stage():Stage
        {
            return Starling.current.nativeStage;
        }
        
        private function get globalPointInTweenTarget():Point
        {
            var targetCenter:Point =
                new Point(transformationTarget.centerX, transformationTarget.centerY);
            var globalPoint:Point = new Point(stage.mouseX, stage.mouseY);
            var point:Point = canvas.globalToViewPort(globalPoint);
            var matrix:Matrix = canvas.getConversionMatrix(
                targetCenter, 
                transformationTarget.scale, 
                transformationTarget.rotation, canvas.viewPort);
            matrix.invert();
            return matrix.transformPoint(point);
        }
        
        private function get globalPointOnCanvas():Point
        {
            return canvas.globalToCanvas(new Point(stage.mouseX, stage.mouseY));
        }
        
        private function hitTest(x:Number, y:Number):Boolean
        {
            return canvas.hitTestComponent(x, y);
        }
        
        override protected function stop():void
        {
            super.stop();
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
        }
        
        private function onStageMouseDown(event:MouseEvent):void
        {
            if(!hitTest(event.stageX, event.stageY))
                return;
            
            last = globalPointInTweenTarget;
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
        }
        
        private function onStageMouseMove(event:MouseEvent):void
        {
            var current:Point = globalPointInTweenTarget;
            moveByTween(last.x - current.x, last.y - current.y);
            last = globalPointInTweenTarget;
        }
        
        private function onStageMouseUp(event:MouseEvent):void
        {
            stop();
        }
        
        private function onStageMouseWheel(event:MouseEvent):void
        {
            if(!hitTest(event.stageX, event.stageY))
                return;
            
            const step:Number = 1.25;
            var delta:Number = event.delta < 0 ? 1 / step : step;
            var point:Point = globalPointOnCanvas;
            point.x = limitCenterX(point.x);
            point.y = limitCenterY(point.y);
            scaleByTween(delta, point);
        }
        
        private function onStageMouseLeave(event:Event):void
        {
            stop();
        }
    }
}