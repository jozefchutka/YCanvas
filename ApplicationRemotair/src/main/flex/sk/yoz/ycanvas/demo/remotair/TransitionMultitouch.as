package sk.yoz.ycanvas.demo.remotair
{
    import com.greensock.TweenMax;
    
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    
    import sk.yoz.touch.events.MultitouchDragZoomEvent;
    
    public class TransitionMultitouch
    {
        public var stopImmediatePropagation:Boolean = true;
        
        private var is0:Boolean;
        private var is1:Boolean;
        
        private var last0:Point;
        private var last1:Point;
        
        private var transition0:Point;
        private var transition1:Point;
        
        private static function process(event:TouchEvent, target:Point, 
            last:Point, lock:Point):MultitouchDragZoomEvent
        {
            var distanceX0:Number = last.x - lock.x;
            var distanceY0:Number = last.y - lock.y;
            
            var distanceX1:Number = target.x - lock.x;
            var distanceY1:Number = target.y - lock.y;
            
            var scale:Number =
                Math.sqrt(distanceX1 * distanceX1 + distanceY1 * distanceY1) /
                Math.sqrt(distanceX0 * distanceX0 + distanceY0 * distanceY0);
            
            if(isNaN(scale) || !isFinite(scale))
                return null;
            
            var rad1:Number = Math.atan2(distanceY0, distanceX0);
            var rad2:Number = Math.atan2(distanceY1, distanceX1);
            var rotation:Number = rad2 - rad1;
            
            var type:String = MultitouchDragZoomEvent.DRAG_ZOOM;
            var point:Point = new Point(lock.x, lock.y);
            return new MultitouchDragZoomEvent(
                type, event, point, scale, rotation);
        }
        
        public function attach(dispatcher:IEventDispatcher):void
        {
            var type:String;
            
            type = TouchEvent.TOUCH_BEGIN;
            dispatcher.addEventListener(type, onTouchBegin, false, 0, true);
            
            type = TouchEvent.TOUCH_MOVE;
            dispatcher.addEventListener(type, onTouchMove, false, 0, true);
            
            type = TouchEvent.TOUCH_END;
            dispatcher.addEventListener(type, onTouchEnd, false, 0, true);
        }
        
        public function detach(dispatcher:IEventDispatcher):void
        {
            var type:String;
            
            type = TouchEvent.TOUCH_BEGIN;
            dispatcher.removeEventListener(type, onTouchBegin, false);
            
            type = TouchEvent.TOUCH_MOVE;
            dispatcher.removeEventListener(type, onTouchMove, false);
            
            type = TouchEvent.TOUCH_END;
            dispatcher.removeEventListener(type, onTouchEnd, false);
        }
        
        private function setPoint(event:TouchEvent, value:Boolean):void
        {
            if(event.isPrimaryTouchPoint)
                is0 = value;
            else
                is1 = value;
        }
        
        private function setLastByEvent(event:TouchEvent):void
        {
            setLast(event, new Point(event.stageX, event.stageY));
        }
        
        private function setLast(event:TouchEvent, value:Point):void
        {
            if(event.isPrimaryTouchPoint)
                last0 = value;
            else
                last1 = value;
        }
        
        private function getLast(event:TouchEvent):Point
        {
            return event.isPrimaryTouchPoint ? last0 : last1;
        }
        
        private function getLock(event:TouchEvent):Point
        {
            return event.isPrimaryTouchPoint ? last1 : last0;
        }
        
        private function getTransition(event:TouchEvent):Point
        {
            return event.isPrimaryTouchPoint ? transition0 : transition1;
        }
        
        private function resetTransitions():void
        {
            if(last0)
                transition0 = last0.clone();
            if(last1)
                transition1 = last1.clone();
        }
        
        private function killTweens():void
        {
            TweenMax.killTweensOf(transition0);
            TweenMax.killTweensOf(transition1);
        }
        
        private function onTouchBegin(event:TouchEvent):void
        {
            killTweens();
            setLastByEvent(event);
            setPoint(event, true)
            resetTransitions();
        }
        
        private function onTouchMove(event:TouchEvent):void
        {
            if(!is0 || !is1)
            {
                setLastByEvent(event);
                resetTransitions();
                return;
            }
            
            if(stopImmediatePropagation)
                event.stopImmediatePropagation();
            var dispatcher:IEventDispatcher = event.currentTarget as IEventDispatcher;
            TweenMax.to(getTransition(event), .5, {
                x:event.stageX, y:event.stageY, 
                onUpdate:function():void
                {
                    var newEvent:Event = process(event, getTransition(event), 
                        getLast(event), getLock(event));
                    newEvent && dispatcher.dispatchEvent(newEvent);
                    setLast(event, getTransition(event).clone());
                }});
        }
        
        private function onTouchEnd(event:TouchEvent):void
        {
            killTweens();
            resetTransitions();
            setPoint(event, false);
        }
    }
}