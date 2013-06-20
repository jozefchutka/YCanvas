package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.utils.TransformationUtils;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    
    public class YCanvasStarlingComponent extends Sprite
    {
        public var controller:YCanvasStarlingComponentController;
        
        private var position:Point;
        
        private var _width:Number = 200;
        private var _height:Number = 200;
        private var _controllerViewPort:Rectangle;
        
        public function YCanvasStarlingComponent(partitionConstructor:Class)
        {
            super();
            
            controller = new YCanvasStarlingComponentController(controllerViewPort, partitionConstructor);
            addChild(controller.component);
            
            addEventListener(TouchEvent.TOUCH, onTouch);
        }
        
        override public function set width(value:Number):void
        {
            _width = value;
            _controllerViewPort = null;
            updateViewPort();
        }
        
        override public function get width():Number
        {
            return _width;
        }
        
        override public function set height(value:Number):void
        {
            _height = value;
            _controllerViewPort = null;
            updateViewPort();
        }
        
        override public function get height():Number
        {
            return _height;
        }
        
        private function get globalViewPort():Rectangle
        {
            var globalPoint:Point = localToGlobal(new Point(0, 0));
            return new Rectangle(globalPoint.x, globalPoint.y, width, height);
        }
        
        private function get controllerViewPort():Rectangle
        {
            if(!_controllerViewPort)
                _controllerViewPort = new Rectangle(0, 0, width, height);
            return _controllerViewPort;
        }
        
        override public function render(support:RenderSupport, alpha:Number):void
        {
            support.finishQuadBatch()
            
            Starling.context.setScissorRectangle(globalViewPort);
            super.render(support,alpha);
            support.finishQuadBatch();
            
            Starling.context.setScissorRectangle(null);
        }
        
        override public function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            var globalPoint:Point = localToGlobal(localPoint);
            return globalViewPort.contains(globalPoint.x, globalPoint.y) ? this : null;
        }
        
        private function updateViewPort():void
        {
            controller.viewPort = controllerViewPort;
            controller.render();
        }
        
        private function touchBegan(touch:Touch):void
        {
            position = controller.globalToCanvas(new Point(touch.globalX, touch.globalY));
        }
        
        private function touchMoved(touch:Touch):void
        {
            var current:Point = controller.globalToCanvas(new Point(touch.globalX, touch.globalY));
            var center:Point = new Point(
                controller.center.x - current.x + position.x, 
                controller.center.y - current.y + position.y);
            TransformationUtils.moveTo(controller, center);
            position = controller.globalToCanvas(new Point(touch.globalX, touch.globalY));
            controller.render();
        }
        
        private function touchEnded(touch:Touch):void
        {
            position = null;
        }
        
        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch;
            
            touch = event.getTouch(this, TouchPhase.BEGAN);
            if(touch)
                return touchBegan(touch);
            
            touch = event.getTouch(this, TouchPhase.MOVED);
            if(touch)
                return touchMoved(touch);
            
            touch = event.getTouch(this, TouchPhase.ENDED);
            if(touch)
                return touchEnded(touch);
        }
    }
}