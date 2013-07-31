package sk.yoz.touch
{
    import com.greensock.TweenMax;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    
    import sk.yoz.touch.events.TransitionMultitouchEvent;
    
    public class TransitionMultitouch extends TwoFingerTouch implements IEventDispatcher
    {
        public var transitionDuration:Number = .5;
        
        private var transition0:Point = new Point;
        private var transition1:Point = new Point;
        private var dispatcher:EventDispatcher = new EventDispatcher;
        
        private function getTransition(event:TouchEvent):Point
        {
            return event.isPrimaryTouchPoint ? transition0 : transition1;
        }
        
        private function resetTransitions():void
        {
            if(last0)
            {
                transition0.x = last0.x;
                transition0.y = last0.y;
            }
            if(last1)
            {
                transition1.x = last1.x;
                transition1.y = last1.y;
            }
        }
        
        public function killTweens():void
        {
            TweenMax.killTweensOf(transition0);
            TweenMax.killTweensOf(transition1);
        }
        
        public function get isTweening():Boolean
        {
            return TweenMax.isTweening(transition0)
                || TweenMax.isTweening(transition1);
        }
        
        public function addEventListener(type:String, listener:Function, 
            useCapture:Boolean=false, priority:int=0, 
            useWeakReference:Boolean=false):void
        {
            dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        public function removeEventListener(type:String, listener:Function, 
            useCapture:Boolean=false):void
        {
            dispatcher.removeEventListener(type, listener, useCapture);
        }
        
        public function dispatchEvent(event:Event):Boolean
        {
            return dispatcher.dispatchEvent(event);
        }
        
        public function hasEventListener(type:String):Boolean
        {
            return dispatcher.hasEventListener(type);
        }
        
        public function willTrigger(type:String):Boolean
        {
            return dispatcher.willTrigger(type);
        }
        
        override protected function dispatch(event:TouchEvent, 
            target:Point):void
        {
            var transition:Point = getTransition(event);
            TweenMax.to(transition, transitionDuration, {
                x:target.x, y:target.y, 
                onUpdateParams:[event, transition], 
                onUpdate:super.dispatch,
                onComplete:onTransitionComplete});
        }
        
        override protected function onTouchBegin(event:TouchEvent):void
        {
            super.onTouchBegin(event);
            killTweens();
            resetTransitions();
        }
        
        override protected function onTouchMove(event:TouchEvent):void
        {
            if(countFingers != 2 && isTweening)
                return;
            if(countFingers != 2)
                resetTransitions();
            super.onTouchMove(event);
        }
        
        override protected function onTouchEnd(event:TouchEvent):void
        {
            super.onTouchEnd(event);
            resetTransitions();
        }
        
        override protected function onTouchRollOut(event:TouchEvent):void
        {
            super.onTouchRollOut(event);
            resetTransitions();
        }
        
        private function onTransitionComplete():void
        {
            var type:String = TransitionMultitouchEvent.TRANSITION_COMPLETE;
            dispatcher.dispatchEvent(new TransitionMultitouchEvent(type));
        }
    }
}