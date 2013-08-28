package sk.yoz.touch.simulator
{
    import flash.display.InteractiveObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    
    public class TouchPoint extends Sprite
    {
        public var touchPointID:uint;
        public var color:uint;
        public var targets:Vector.<InteractiveObject> = new Vector.<InteractiveObject>;
        
        public var vx:Number = 0;
        public var vy:Number = 0;
        
        private var _active:Boolean;
        
        public function TouchPoint(touchPointID:uint = 0, color:uint = 0xff0000)
        {
            this.touchPointID = touchPointID;
            this.color = color;
            render();
            
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
        
        public function set active(value:Boolean):void
        {
            if(active == value)
                return;
            
            _active = value;
            render();
            dispatch(value ? TouchEvent.TOUCH_BEGIN : TouchEvent.TOUCH_END);
        }
        
        public function get active():Boolean
        {
            return _active;
        }
        
        public function render():void
        {
            graphics.clear();
            graphics.beginFill(color, active ? 0.8 : 0.3);
            graphics.drawCircle(0, 0, 30);
            graphics.endFill();
        }
        
        public function dispatch(type:String):void
        {
            eachTarget(function(target:InteractiveObject):void
            {
                var isPrimaryTouchPoint:Boolean = touchPointID == 0;
                var localX:Number = x;
                var localY:Number = y;
                var sizeX:Number = NaN;
                var sizeY:Number = NaN;
                var pressure:Number = NaN;
                var relatedObject:InteractiveObject = null;
                var ctrlKey:Boolean = false;
                var altKey:Boolean = false;
                var shiftKey:Boolean = false;
                var event:TouchEvent = new TouchEvent(type, true, true, 
                    touchPointID, isPrimaryTouchPoint, localX, localY, sizeX, sizeY,
                    pressure, relatedObject, ctrlKey, altKey, shiftKey);
                target.dispatchEvent(event);
            });
        }
        
        private function eachTarget(callback:Function):void
        {
            for(var i:uint = 0; i < targets.length; i++)
                callback(targets[i]);
        }
        
        public function move():void
        {
            if(!stage)
                return;
            
            x += vx;
            y += vy;
            var point:Point = localToGlobal(new Point(0, 0));
            if(point.x <= 0 || point.x >= stage.stageWidth)
                vx = -vx;
            if(point.y <= 0 || point.y >= stage.stageHeight)
                vy = -vy;
            
            active && dispatch(TouchEvent.TOUCH_MOVE);
        }
        
        private function onMouseDown(event:MouseEvent):void
        {
            startDrag();
        }
        
        private function onMouseUp(event:MouseEvent):void
        {
            stopDrag();
        }
    }
}