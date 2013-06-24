package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.display.Stage;
    import flash.events.EventDispatcher;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.demo.starlingComponent.valueObjects.Mode;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    
    public class YCanvasStarlingComponent extends Sprite
    {
        private var dispatcher:EventDispatcher;
        
        private var _controller:YCanvasStarlingComponentController;
        private var _transformationManager:TransformationManager;
        private var _width:Number = 200;
        private var _height:Number = 200;
        private var _localViewPort:Rectangle;
        private var _globalViewPort:Rectangle;
        
        public function YCanvasStarlingComponent(mode:Mode, stage:flash.display.Stage)
        {
            super();
            
            dispatcher = new EventDispatcher();
            
            _controller = new YCanvasStarlingComponentController(globalViewPort, mode, dispatcher);
            addChild(controller.component);
            
            _transformationManager = new TransformationManager(this, dispatcher, stage);
            transformationManager.minScale = 1;
            transformationManager.maxScale = 1 / (2 << 15);
        }
        
        public function get controller():YCanvasStarlingComponentController
        {
            return _controller;
        }
        
        public function get transformationManager():TransformationManager
        {
            return _transformationManager;
        }
        
        override public function set x(value:Number):void
        {
            super.x = value;
            invalidateViewPort();
        }
        
        override public function set y(value:Number):void
        {
            super.y = value;
            invalidateViewPort();
        }
        
        override public function set width(value:Number):void
        {
            _width = value;
            validateViewPort();
        }
        
        override public function get width():Number
        {
            return _width;
        }
        
        override public function set height(value:Number):void
        {
            _height = value;
            validateViewPort();
        }
        
        override public function get height():Number
        {
            return _height;
        }
        
        public function set mode(value:Mode):void
        {
            controller.mode = value;
        }
        
        public function get mode():Mode
        {
            return controller.mode;
        }
        
        private function get localViewPort():Rectangle
        {
            if(!_localViewPort)
            {
                var starlingPoint:Point = localToGlobal(new Point(0, 0));
                _localViewPort = new Rectangle(starlingPoint.x, starlingPoint.y, width, height);
            }
            
            return _localViewPort;
        }
        
        private function get globalViewPort():Rectangle
        {
            if(!_globalViewPort)
                _globalViewPort = new Rectangle(
                    Starling.current.viewPort.x + localViewPort.x, 
                    Starling.current.viewPort.y + localViewPort.y, 
                    width, height);
            return _globalViewPort;
        }
        
        override public function render(support:RenderSupport, alpha:Number):void
        {
            support.finishQuadBatch()
            
            Starling.context.setScissorRectangle(localViewPort);
            super.render(support,alpha);
            support.finishQuadBatch();
            
            Starling.context.setScissorRectangle(null);
        }
        
        override public function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            var starlingPoint:Point = localToGlobal(localPoint);
            return localViewPort.contains(starlingPoint.x, starlingPoint.y) ? this : null;
        }
        
        public function invalidateViewPort():void
        {
            _localViewPort = null;
            _globalViewPort = null;
        }
        
        public function validateViewPort():void
        {
            invalidateViewPort();
            controller.viewPort = globalViewPort;
            controller.render();
        }
    }
}