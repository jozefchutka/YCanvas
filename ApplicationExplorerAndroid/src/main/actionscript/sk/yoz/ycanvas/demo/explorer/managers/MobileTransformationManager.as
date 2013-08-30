package sk.yoz.ycanvas.demo.explorer.managers
{
    import com.greensock.TweenMax;
    
    import flash.events.IEventDispatcher;
    import flash.events.TimerEvent;
    import flash.events.TouchEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
    import flash.utils.Timer;
    
    import sk.yoz.touch.TransitionMultitouch;
    import sk.yoz.touch.events.TwoFingerEvent;
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.demo.explorer.events.CanvasEvent;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.CanvasLimits;
    import sk.yoz.ycanvas.demo.explorer.view.Board;
    import sk.yoz.ycanvas.utils.TransformationUtils;

    public class MobileTransformationManager
    {
        private var canvas:AbstractYCanvas;
        private var dispatcher:IEventDispatcher;
        private var renderTimer:Timer = new Timer(500, 1);
        private var transitionDuration:Number = .5;
        
        private var minScale:Number = 1;
        private var maxScale:Number = 1 / 12;
        private var multitouch:TransitionMultitouch = new TransitionMultitouch;
        private var last:Point;
        private var transitionTarget:Point = new Point;
        private var transition:Point = new Point;
        
        public function MobileTransformationManager(canvas:AbstractYCanvas, 
            board:Board, dispatcher:IEventDispatcher):void
        {
            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
            
            this.canvas = canvas;
            this.dispatcher = dispatcher;
            
            renderTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onRenderTimer);
            
            multitouch.attach(board);
            multitouch.transitionDuration = transitionDuration;
            
            board.addEventListener(TwoFingerEvent.SCALE_AND_ROTATE, onScaleAndRotate);
            
            board.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
            board.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove, false, 1);
            board.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
        }
        
        public function set limits(value:CanvasLimits):void
        {
            minScale = value.scaleMin;
            maxScale = value.scaleMax;
        }
        
        private function minifyRotation(rotation:Number):Number
        {
            while(rotation > Math.PI)
                rotation -= Math.PI * 2;
            while(rotation < -Math.PI)
                rotation += Math.PI * 2;
            return rotation;
        }
        
        private function killTween():void
        {
            TweenMax.killTweensOf(transition);
        }
        
        private function onRenderTimer(event:TimerEvent):void
        {
            var type:String = CanvasEvent.TRANSFORMATION_FINISHED;
            dispatcher.dispatchEvent(new CanvasEvent(type));
        }
        
        private function renderLater():void
        {
            if(renderTimer.running)
                return;
            
            renderTimer.reset();
            renderTimer.start();
        }
        
        private function resetTransitionTarget():void
        {
            transitionTarget = canvas.center.clone();
        }
        
        private function getGlobalPointInTweenTarget(globalPoint:Point):Point
        {
            var point:Point = canvas.globalToViewPort(globalPoint);
            var matrix:Matrix = canvas.getConversionMatrix(
                transitionTarget, canvas.scale, canvas.rotation, canvas.viewPort);
            matrix.invert();
            return matrix.transformPoint(point);
        }
        
        private function onScaleAndRotate(event:TwoFingerEvent):void
        {
            if(event.scale == 1 && event.rotation == 0)
                return;
            
            var scale:Number = canvas.scale * event.scale;
            TransformationUtils.rotateScaleTo(canvas, 
                canvas.rotation + minifyRotation(event.rotation), 
                Math.max(maxScale, Math.min(minScale, scale)), 
                canvas.globalToCanvas(event.lock));
            renderLater();
        }
        
        private function onTouchBegin(event:TouchEvent):void
        {
            killTween();
            resetTransitionTarget();
            last = getGlobalPointInTweenTarget(multitouch.getPoint(event));
        }
        
        private function onTouchMove(event:TouchEvent):void
        {
            killTween();
            
            var point:Point = multitouch.getPoint(event);
            var current:Point = getGlobalPointInTweenTarget(point);
            if(!last || multitouch.isTweening || multitouch.countFingers != 1)
            {
                last = current;
                return;
            }
            
            transitionTarget.x += last.x - current.x;
            transitionTarget.y += last.y - current.y;
            transition.x = canvas.center.x;
            transition.y = canvas.center.y;
            TweenMax.to(transition, transitionDuration, {
                x:transitionTarget.x, y:transitionTarget.y, 
                onUpdate:onTweenUpdate});
            
            last = getGlobalPointInTweenTarget(point);
        }
        
        private function onTouchEnd(event:TouchEvent):void
        {
            resetTransitionTarget();
            last = null;
        }
        
        private function onTweenUpdate():void
        {
            TransformationUtils.moveTo(canvas, transition);
            renderLater();
        }
    }
}