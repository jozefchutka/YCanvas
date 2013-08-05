package sk.yoz.ycanvas.map.managers
{
    import com.greensock.TweenNano;
    
    import flash.display.Stage;
    import flash.events.TouchEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
    
    import sk.yoz.touch.TransitionMultitouch;
    import sk.yoz.touch.events.TransitionMultitouchEvent;
    import sk.yoz.touch.events.TwoFingerEvent;
    import sk.yoz.ycanvas.map.YCanvasMap;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.valueObjects.Limit;
    import sk.yoz.ycanvas.utils.TransformationUtils;
    
    import starling.core.Starling;
    
    /**
    * Transformation manager implementation for touch interactions.
    */
    public class TouchTransformationManager extends AbstractTransformationManager
    {
        private var multitouch:TransitionMultitouch = new TransitionMultitouch;
        private var previousPosition:Point;
        
        public function TouchTransformationManager(canvas:YCanvasMap, 
            limit:Limit, transitionDuration:Number=.25)
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
            var point:Point = controller.globalToViewPort(globalPoint);
            var matrix:Matrix = controller.getConversionMatrix(
                new Point(transformationTarget.centerX, transformationTarget.centerY), 
                controller.scale, controller.rotation, controller.viewPort);
            matrix.invert();
            return matrix.transformPoint(point);
        }
        
        private function killTween():void
        {
            TweenNano.killTweensOf(transformation);
        }
        
        private function resetTransformation():void
        {
            transformation.centerX = controller.center.x;
            transformation.centerY = controller.center.y;
            transformation.scale = controller.scale;
            transformation.rotation = controller.rotation;
        }
        
        private function resetTransformationTarget():void
        {
            transformationTarget.centerX = controller.center.x;
            transformationTarget.centerY = controller.center.y;
            transformationTarget.scale = controller.scale;
            transformationTarget.rotation = controller.rotation;
        }
        
        private function dispatchTransformationStarted():void
        {
            if(transforming)
                return;
            
            transforming = true;
            controller.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_STARTED));
        }
        
        private function dispatchTransformationFinished():void
        {
            if(multitouch.isTweening || multitouch.countFingers)
                return;
            
            if(!transforming)
                return;
            
            transforming = false;
            controller.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
        }
        
        private function hitTest(x:Number, y:Number):Boolean
        {
            return controller.hitTestComponent(x, y);
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
            
            var rotation:Number = controller.rotation;
            TransformationUtils.rotateScaleTo(controller, 
                controller.rotation + normalizeRadians(event.rotation), 
                limitScale(controller.scale * event.scale), 
                controller.globalToCanvas(event.lock));
            if(!allowRotate)
                controller.rotation = rotation;
            
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
            
            TweenNano.to(transformation, transitionDuration, {
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
            TransformationUtils.moveTo(controller, 
                new Point(transformation.centerX, transformation.centerY));
        }
    }
}