package sk.yoz.ycanvas.demo.remotair
{
    import com.greensock.TweenMax;
    
    import flash.events.TouchEvent;
    import flash.geom.Point;
    
    import sk.yoz.touch.MultitouchDragZoom;
    
    public class TransitionMultitouch extends MultitouchDragZoom
    {
        private var position0:Point;
        private var position1:Point;
        private var point0:Boolean;
        private var point1:Boolean;
        private var clone:TouchEvent;
        
        private function definePosition(event:TouchEvent):void
        {
            if(event.isPrimaryTouchPoint)
                position0 = new Point(event.localX, event.localY);
            else
                position1 = new Point(event.localX, event.localY);
        }
        
        private function definePoint(event:TouchEvent, value:Boolean):void
        {
            if(event.isPrimaryTouchPoint)
                point0 = value;
            else
                point1 = value;
        }
        
        public function get hasTwoPoints():Boolean
        {
            return point0 && point1;
        }
        
        override protected function onTouchBegin(event:TouchEvent):void
        {
            definePoint(event, true);
            definePosition(event);
            if(hasTwoPoints)
            {
                super.onTouchEnd(event);
                super.onTouchBegin(event);
            }
        }
        
        override protected function onTouchEnd(event:TouchEvent):void
        {
            definePoint(event, false);
            super.onTouchEnd(event);
        }
        
        override protected function onTouchMove(event:TouchEvent):void
        {
            if(event == clone)
                return super.onTouchMove(event);
            
            if(!hasTwoPoints)
            {
                onTouchEnd(event);
                onTouchBegin(event);
                return;
            }
            
            event.stopImmediatePropagation();
            var target:Point = event.isPrimaryTouchPoint ? position0 : position1;
            TweenMax.to(target, 2, {x:event.localX, y:event.localY, 
                onUpdate:function():void
                {
                    clone = event.clone() as TouchEvent;
                    clone.localX = target.x;
                    clone.localY = target.y;
                    event.currentTarget.dispatchEvent(clone);
                }});
        }
    }
}