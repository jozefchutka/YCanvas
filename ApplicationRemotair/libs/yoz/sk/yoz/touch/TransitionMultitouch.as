package sk.yoz.touch
{
    import com.greensock.TweenMax;
    
    import flash.events.TouchEvent;
    import flash.geom.Point;
    
    public class TransitionMultitouch extends TwoFingerTouch
    {
        public var transitionDuration:Number = .5;
        
        private var transition0:Point = new Point;
        private var transition1:Point = new Point;
        
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
        
        override protected function dispatch(event:TouchEvent, 
            target:Point):void
        {
            var transition:Point = getTransition(event);
            TweenMax.to(transition, transitionDuration, {
                x:target.x, y:target.y, 
                onUpdateParams:[event, transition], 
                onUpdate:super.dispatch});
        }
        
        override protected function onTouchBegin(event:TouchEvent):void
        {
            super.onTouchBegin(event);
            killTweens();
            resetTransitions();
        }
        
        override protected function onTouchMove(event:TouchEvent):void
        {
            if(countFingers != 2)
                resetTransitions();
            super.onTouchMove(event);
        }
        
        override protected function onTouchEnd(event:TouchEvent):void
        {
            super.onTouchEnd(event);
            resetTransitions();
        }
    }
}