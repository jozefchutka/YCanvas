package sk.yoz.ycanvas.map.managers
{
    import com.greensock.TweenMax;
    
    import flash.display.Stage;
    import flash.events.TouchEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
    
    import sk.yoz.touch.events.TwoFingerEvent;
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.events.TransitionMultitouchEvent;
    import sk.yoz.ycanvas.map.utils.TransitionMultitouch;
    import sk.yoz.ycanvas.map.valueObjects.CanvasLimit;
    import sk.yoz.ycanvas.utils.TransformationUtils;
    
    import starling.core.Starling;
    
    public class TouchTransformationManager extends AbstractTransformationManager
    {
        private var multitouch:TransitionMultitouch = new TransitionMultitouch;
        private var previousPosition:Point;
        
        public function TouchTransformationManager(canvas:MapController, 
            limit:CanvasLimit, transitionDuration:Number=.25)
        {
            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
            
            super(canvas, limit, transitionDuration);
            
            multitouch.attach(stage);
            multitouch.transitionDuration = transitionDuration;
            multitouch.addEventListener(TransitionMultitouchEvent.TRANSITION_COMPLETE, onMultitouchTransitionComplete);
            
            stage.addEventListener(TwoFingerEvent.SCALE_AND_ROTATE, onStageScaleAndRotate);
            stage.addEventListener(TouchEvent.TOUCH_BEGIN, onStageTouchBegin);
            stage.addEventListener(TouchEvent.TOUCH_END, onStageTouchEnd);
            stage.addEventListener(TouchEvent.TOUCH_ROLL_OUT, onStageTouchRollOut);
        }
        
        override public function dispose():void
        {
            multitouch.detach(stage);
            multitouch.removeEventListener(TransitionMultitouchEvent.TRANSITION_COMPLETE, onMultitouchTransitionComplete);
            multitouch = null;
            
            stage.removeEventListener(TwoFingerEvent.SCALE_AND_ROTATE, onStageScaleAndRotate);
            stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onStageTouchBegin);
            stage.removeEventListener(TouchEvent.TOUCH_END, onStageTouchEnd);
            stage.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, onStageTouchRollOut);
            stage.removeEventListener(TouchEvent.TOUCH_MOVE, onStageTouchMove, false);
            
            super.dispose();
        }
        
        private function get stage():Stage
        {
            return Starling.current.nativeStage;
        }
        
        private function getGlobalPointInTweenTarget(globalPoint:Point):Point
        {
            var point:Point = canvas.globalToViewPort(globalPoint);
            var matrix:Matrix = canvas.getConversionMatrix(
                new Point(transformationTarget.centerX, transformationTarget.centerY), 
                canvas.scale, canvas.rotation, canvas.viewPort);
            matrix.invert();
            return matrix.transformPoint(point);
        }
        
        private function killTween():void
        {
            TweenMax.killTweensOf(transformation);
        }
        
        private function resetTransformation():void
        {
            transformation.centerX = canvas.center.x;
            transformation.centerY = canvas.center.y;
            transformation.scale = canvas.scale;
            transformation.rotation = canvas.rotation;
        }
        
        private function resetTransformationTarget():void
        {
            transformationTarget.centerX = canvas.center.x;
            transformationTarget.centerY = canvas.center.y;
            transformationTarget.scale = canvas.scale;
            transformationTarget.rotation = canvas.rotation;
        }
        
        private function dispatchTransformationStarted():void
        {
            if(transforming)
                return;
            
            transforming = true;
            canvas.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_STARTED));
        }
        
        private function dispatchTransformationFinished():void
        {
            if(multitouch.isTweening || multitouch.countFingers)
                return;
            
            if(!transforming)
                return;
            
            transforming = false;
            canvas.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
        }
        
        private function hitTest(x:Number, y:Number):Boolean
        {
            return canvas.hitTestComponent(x, y);
        }
        
        private function onStageScaleAndRotate(event:TwoFingerEvent):void
        {
            if(!hitTest(event.source.stageX, event.source.stageY))
                return;
            
            if(event.scale == 1 && event.rotation == 0)
                return;
            
            if(multitouch.countFingers != 2)
                return;
            
            dispatchTransformationStarted();
            
            var rotation:Number = canvas.rotation;
            TransformationUtils.rotateScaleTo(canvas, 
                canvas.rotation + normalizeRadians(event.rotation), 
                limitScale(canvas.scale * event.scale), 
                canvas.globalToCanvas(event.lock));
            if(!allowRotate)
                canvas.rotation = rotation;
            
            resetTransformation();
            resetTransformationTarget();
        }
        
        private function onMultitouchTransitionComplete(event:TransitionMultitouchEvent):void
        {
            dispatchTransformationFinished();
        }
        
        private function onStageTouchBegin(event:TouchEvent):void
        {
            if(!hitTest(event.stageX, event.stageY))
                return;
            
            killTween();
            resetTransformationTarget();
            previousPosition = getGlobalPointInTweenTarget(multitouch.getPoint(event));
            
            stage.addEventListener(TouchEvent.TOUCH_MOVE, onStageTouchMove, false, 1);
        }
        
        private function onStageTouchMove(event:TouchEvent):void
        {
            dispatchTransformationStarted();
            killTween();
            
            var point:Point = multitouch.getPoint(event);
            var current:Point = getGlobalPointInTweenTarget(point);
            if(!previousPosition || multitouch.isTweening || multitouch.countFingers != 1)
            {
                previousPosition = current;
                return;
            }
            
            transformationTarget.centerX += previousPosition.x - current.x;
            transformationTarget.centerY += previousPosition.y - current.y;
            resetTransformation();
            
            TweenMax.to(transformation, transitionDuration, {
                centerX:transformationTarget.centerX, 
                centerY:transformationTarget.centerY, 
                onUpdate:onTransformationUpdate});
            
            previousPosition = getGlobalPointInTweenTarget(point);
        }
        
        private function onStageTouchEnd(event:TouchEvent):void
        {
            stage.removeEventListener(TouchEvent.TOUCH_MOVE, onStageTouchMove, false);
            
            resetTransformationTarget();
            previousPosition = null;
            
            dispatchTransformationFinished();
        }
        
        private function onStageTouchRollOut(event:TouchEvent):void
        {
            onStageTouchEnd(event);
        }
        
        private function onTransformationUpdate():void
        {
            TransformationUtils.moveTo(canvas, 
                new Point(transformation.centerX, transformation.centerY));
        }
    }
}