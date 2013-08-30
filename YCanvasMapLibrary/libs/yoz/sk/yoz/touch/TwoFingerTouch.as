package sk.yoz.touch
{
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    
    import sk.yoz.touch.events.TwoFingerEvent;

    public class TwoFingerTouch
    {
        public var stopImmediatePropagation:Boolean = true;
        
        private var _countFingers:int = 0;
        
        protected var last0:Point;
        protected var last1:Point;
        
        public static function process(event:TouchEvent, target:Point, 
            last:Point, lock:Point):TwoFingerEvent
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
            
            var type:String = TwoFingerEvent.SCALE_AND_ROTATE;
            var point:Point = lock.clone();
            return new TwoFingerEvent(type, event, point, scale, rotation);
        }
        
        public function get countFingers():int
        {
            return _countFingers;
        }
        
        public function attach(dispatcher:IEventDispatcher, priority:int = 0):void
        {
            var type:String;
            
            type = TouchEvent.TOUCH_BEGIN;
            dispatcher.addEventListener(type, onTouchBegin, false, 0, true);
            
            type = TouchEvent.TOUCH_MOVE;
            dispatcher.addEventListener(type, onTouchMove, false, 0, true);
            
            type = TouchEvent.TOUCH_END;
            dispatcher.addEventListener(type, onTouchEnd, false, 0, true);
            
            type = TouchEvent.TOUCH_ROLL_OUT;
            dispatcher.addEventListener(type, onTouchRollOut, false, 0, true);
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
            
            type = TouchEvent.TOUCH_ROLL_OUT;
            dispatcher.removeEventListener(type, onTouchRollOut, false);
        }
        
        public function getPoint(event:TouchEvent):Point
        {
            return new Point(event.stageX, event.stageY)
        }
        
        protected function setLastByEvent(event:TouchEvent):void
        {
            setLast(event, getPoint(event));
        }
        
        protected function setLast(event:TouchEvent, value:Point):void
        {
            if(event.isPrimaryTouchPoint)
                last0 = value;
            else
                last1 = value;
        }
        
        public function getLast(event:TouchEvent):Point
        {
            return event.isPrimaryTouchPoint ? last0 : last1;
        }
        
        protected function getLock(event:TouchEvent):Point
        {
            return event.isPrimaryTouchPoint ? last1 : last0;
        }
        
        protected function getDispatcher(event:TouchEvent):IEventDispatcher
        {
            return event.currentTarget as IEventDispatcher;
        }
        
        protected function dispatch(event:TouchEvent, target:Point):void
        {
            var last:Point = getLast(event);
            var lock:Point = getLock(event);
            var twoFingerEvent:Event = process(event, target, last, lock);
            var dispatcher:IEventDispatcher = getDispatcher(event);
            if(twoFingerEvent && dispatcher)
                dispatcher.dispatchEvent(twoFingerEvent);
            setLast(event, target.clone());
        }
        
        protected function onTouchBegin(event:TouchEvent):void
        {
            _countFingers++;
            setLastByEvent(event);
        }
        
        protected function onTouchMove(event:TouchEvent):void
        {
            if(countFingers != 2)
                return setLastByEvent(event);
            
            if(stopImmediatePropagation)
                event.stopImmediatePropagation();
            dispatch(event, getPoint(event));
        }
        
        protected function onTouchEnd(event:TouchEvent):void
        {
            if(_countFingers)
                _countFingers--;
        }
        
        protected function onTouchRollOut(event:TouchEvent):void
        {
            if(_countFingers)
                _countFingers--;
        }
    }
}