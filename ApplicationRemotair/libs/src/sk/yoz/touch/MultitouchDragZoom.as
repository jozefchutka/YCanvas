package sk.yoz.touch
{
    import flash.events.EventDispatcher;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    import flash.utils.Dictionary;
    
    import sk.yoz.touch.events.MultitouchDragZoomEvent;
    
    public class MultitouchDragZoom extends EventDispatcher
    {
        protected var dispatchers:Dictionary = new Dictionary(true);
        
        public function attach(dispatcher:EventDispatcher):void
        {
            var type:String;
            
            type = TouchEvent.TOUCH_BEGIN;
            dispatcher.addEventListener(type, onTouchBegin, false, 0, true);
            
            type = TouchEvent.TOUCH_MOVE;
            dispatcher.addEventListener(type, onTouchMove, false, 0, true);
            
            type = TouchEvent.TOUCH_END;
            dispatcher.addEventListener(type, onTouchEnd, false, 0, true);
            
            if(!dispatchers.hasOwnProperty(dispatcher))
                dispatchers[dispatcher] = new History();
        }
        
        public function detach(dispatcher:EventDispatcher):void
        {
            var type:String;
            
            type = TouchEvent.TOUCH_BEGIN;
            dispatcher.removeEventListener(type, onTouchBegin, false);
            
            type = TouchEvent.TOUCH_MOVE;
            dispatcher.removeEventListener(type, onTouchMove, false);
            
            type = TouchEvent.TOUCH_END;
            dispatcher.removeEventListener(type, onTouchEnd, false);
        }
        
        public function detachAndDelete(dispatcher:EventDispatcher):void
        {
            detach(dispatcher);
            delete dispatchers[dispatcher];
        }
        
        protected function dispatch(dispatcher:EventDispatcher, id:int):void
        {
            var history:History = dispatchers[dispatcher];
            var first:TouchEvent, last:TouchEvent, lock:TouchEvent;
            var event:MultitouchDragZoomEvent;
            
            first = history.getFirst(id);
            last = history.getLast(id);
            lock = history.getLock(id);
            if(first && last && lock && first != last)
            {
                event = process(last, first, lock);
                event && dispatcher.dispatchEvent(event);
            }
        }
        
        protected function onTouchBegin(event:TouchEvent):void
        {
            event.touchPointID = event.isPrimaryTouchPoint ? 0 : 1;
            
            var history:History = dispatchers[event.currentTarget];
            history.update(event);
        }
        
        protected function onTouchMove(event:TouchEvent):void
        {
            event.touchPointID = event.isPrimaryTouchPoint ? 0 : 1;
            
            var id:int = event.touchPointID;
            var dispatcher:EventDispatcher = 
                EventDispatcher(event.currentTarget);
            var history:History = dispatchers[dispatcher];
            history.update(event);
            dispatch(dispatcher, id);
            history.removePrevious(id);
        }
        
        protected function onTouchEnd(event:TouchEvent):void
        {
            event.touchPointID = event.isPrimaryTouchPoint ? 0 : 1;
            
            var id:int = event.touchPointID;
            var history:History = dispatchers[event.currentTarget];
            history.remove(id);
        }
        
        private static function process(event:TouchEvent, first:TouchEvent, 
            lock:TouchEvent):MultitouchDragZoomEvent
        {
            var distanceX0:Number = first.stageX - lock.stageX;
            var distanceY0:Number = first.stageY - lock.stageY;
            
            var distanceX1:Number = event.stageX - lock.stageX;
            var distanceY1:Number = event.stageY - lock.stageY;
            
            var scale:Number =
                Math.sqrt(distanceX1 * distanceX1 + distanceY1 * distanceY1) /
                Math.sqrt(distanceX0 * distanceX0 + distanceY0 * distanceY0);
            
            if(isNaN(scale) || !isFinite(scale))
                return null;
            
            var rad1:Number = Math.atan2(distanceY0, distanceX0);
            var rad2:Number = Math.atan2(distanceY1, distanceX1);
            var rotation:Number = (rad2 - rad1) * 180 / Math.PI;
            
            var type:String = MultitouchDragZoomEvent.DRAG_ZOOM;
            var point:Point = new Point(lock.stageX, lock.stageY);
            return new MultitouchDragZoomEvent(
                type, event, point, scale, rotation);
        }
    }
}

import flash.events.TouchEvent;

internal class History
{
    private var events0:Vector.<TouchEvent> = new Vector.<TouchEvent>;
    private var events1:Vector.<TouchEvent> = new Vector.<TouchEvent>;
    
    public function getFirst(id:int):TouchEvent
    {
        if(id == 0)
            return events0.length ? events0[0] : null;
        return events1.length ? events1[0] : null;
    }
    
    public function getLast(id:int):TouchEvent
    {
        if(id == 0)
            return events0.length ? events0[events0.length - 1] : null; 
        return events1.length ? events1[events1.length - 1] : null;
    }
    
    public function getLock(id:int):TouchEvent
    {
        return getFirst(id == 0 ? 1 : 0);
    }
    
    public function update(event:TouchEvent):void
    {
        if(event.touchPointID == 0)
            events0.push(event);
        else
            events1.push(event);
    }
    
    public function remove(id:int):void
    {
        if(id == 0)
            events0.length = 0;
        else
            events1.length = 0;
    }
    
    public function removePrevious(id:int):void
    {
        if(id == 0)
            events0.length && events0.splice(0, events0.length - 1);
        else
            events1.length && events1.splice(0, events1.length - 1);
    }
}