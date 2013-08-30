package sk.yoz.touch.simulator
{
    import flash.display.InteractiveObject;
    import flash.display.Sprite;
    import flash.events.Event;
    
    public class Layer extends Sprite
    {
        public static const BUTTONS_POSITION_LEFT:uint = 0;
        public static const BUTTONS_POSITION_RIGHT:uint = 1;
        
        private var targets:Vector.<InteractiveObject> = new Vector.<InteractiveObject>;
        private var points:Vector.<TouchPoint> = new Vector.<TouchPoint>;
        private var _perFrameDispatches:uint = 2;
        private var _buttonsPosition:uint = 0;
        private var pointsContainer:Sprite = new Sprite;
        private var buttonsContainer:Sprite = new Sprite;
        
        public function Layer()
        {
            addChild(pointsContainer);
            addChild(buttonsContainer);
            
            render();
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame, false, int.MAX_VALUE);
        }
        
        private function render():void
        {
            while(buttonsContainer.numChildren)
                buttonsContainer.removeChildAt(0);
            
            var i:uint = 0;
            eachPoint(function(point:TouchPoint):void
            {
                var button:Button = new Button(point);
                button.x = i * button.width + i++;
                buttonsContainer.addChild(button);
            });
            
            buttonsContainer.x = 0;
            if(buttonsPosition == BUTTONS_POSITION_RIGHT)
                buttonsContainer.x = stage.stageWidth - buttonsContainer.width;
        }
        
        public function set buttonsPosition(value:uint):void
        {
            if(value == buttonsPosition)
                return;
            
            _buttonsPosition = value;
            render();
        }
        
        public function get buttonsPosition():uint
        {
            return _buttonsPosition;
        }
        
        public function set perFrameDispatches(value:uint):void
        {
            _perFrameDispatches = value;
        }
        
        public function get perFrameDispatches():uint
        {
            return _perFrameDispatches;
        }
        
        public function addPoint(point:TouchPoint):void
        {
            addChild(point);
            points.push(point);
            point.targets = targets;
            render();
        }
        
        public function addTarget(target:InteractiveObject):void
        {
            targets.push(target);
            eachPoint(function(point:TouchPoint):void
            {
                point.targets = targets;
            });
        }
        
        private function eachPoint(callback:Function):void
        {
            for(var i:uint = 0; i < points.length; i++)
                callback(points[i]);
        }
        
        private function onEnterFrame(event:Event):void
        {
            for(var i:uint = 0; i < perFrameDispatches; i++)
                eachPoint(function(point:TouchPoint):void
                {
                    point.move();
                });
        }
    }
}