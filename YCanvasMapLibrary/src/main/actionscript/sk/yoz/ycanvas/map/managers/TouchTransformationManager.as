package sk.yoz.ycanvas.map.managers
{
    import com.greensock.TweenMax;
    
    import flash.display.Stage;
    import flash.events.TouchEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
    
    import sk.yoz.ycanvas.map.utils.TransitionMultitouch;
    import sk.yoz.ycanvas.map.events.TransitionMultitouchEvent;
    import sk.yoz.touch.events.TwoFingerEvent;
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.valueObjects.CanvasLimit;
    import sk.yoz.ycanvas.utils.TransformationUtils;
    
    import starling.core.Starling;
    
    public class TouchTransformationManager extends AbstractTransformationManager
    {
        private var transitionDuration:Number = .25;
        private var multitouch:TransitionMultitouch = new TransitionMultitouch;
        private var previousPosition:Point;
        
        public function TouchTransformationManager(canvas:MapController, limit:CanvasLimit)
        {
            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
            
            super(canvas, limit);
            
            multitouch.attach(stage);
            multitouch.transitionDuration = transitionDuration;
            multitouch.addEventListener(TransitionMultitouchEvent.TRANSITION_COMPLETE, onMultitouchTransitionComplete);
            
            stage.addEventListener(TwoFingerEvent.SCALE_AND_ROTATE, onScaleAndRotate);
            stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
            stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove, false, 1);
            stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
            stage.addEventListener(TouchEvent.TOUCH_ROLL_OUT, onTouchRollOut);
        }
        
        override public function dispose():void
        {
            multitouch.detach(stage);
            multitouch.removeEventListener(TransitionMultitouchEvent.TRANSITION_COMPLETE, onMultitouchTransitionComplete);
            
            stage.removeEventListener(TwoFingerEvent.SCALE_AND_ROTATE, onScaleAndRotate);
            
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
        
        private function onScaleAndRotate(event:TwoFingerEvent):void
        {
            if(event.scale == 1 && event.rotation == 0)
                return;
            
            if(multitouch.countFingers != 2)
                return;
            
            dispatchTransformationStarted();
            
            TransformationUtils.rotateScaleTo(canvas, 
                canvas.rotation + normalizeRadians(event.rotation), 
                limitScale(canvas.scale * event.scale), 
                canvas.globalToCanvas(event.lock));
            
            resetTransformation();
            resetTransformationTarget();
            
            //TODO ???
            //signalUpdate.dispatch(transformation);
        }
        
        private function onMultitouchTransitionComplete(event:TransitionMultitouchEvent):void
        {
            dispatchTransformationFinished();
        }
        
        private function onTouchBegin(event:TouchEvent):void
        {
            killTween();
            resetTransformationTarget();
            previousPosition = getGlobalPointInTweenTarget(multitouch.getPoint(event));
        }
        
        private function onTouchMove(event:TouchEvent):void
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
        
        private function onTouchEnd(event:TouchEvent):void
        {
            resetTransformationTarget();
            previousPosition = null;
            
            dispatchTransformationFinished();
        }
        
        private function onTouchRollOut(event:TouchEvent):void
        {
            onTouchEnd(event);
        }
        
        private function onTransformationUpdate():void
        {
            TransformationUtils.moveTo(canvas, 
                new Point(transformation.centerX, transformation.centerY));
            //TODO ???
            //signalUpdate.dispatch(transformation);
        }
    }
}