package sk.yoz.ycanvas.map.display
{
    import flash.events.IEventDispatcher;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    
    public class MapComponent extends Sprite
    {
        public static const VIEWPORT_UPDATED:String = "viewPortUpdated";
        
        private var dispatcher:IEventDispatcher;
        
        private var _width:Number = 200;
        private var _height:Number = 200;
        private var _localViewPort:Rectangle;
        
        public function MapComponent(dispatcher:IEventDispatcher)
        {
            super();
            
            this.dispatcher = dispatcher;
        }
        
        override public function get width():Number
        {
            return _width;
        }
        
        override public function set width(value:Number):void
        {
            _width = value;
            validateViewPort();
        }
        
        override public function get height():Number
        {
            return _height;
        }
        
        override public function set height(value:Number):void
        {
            _height = value;
            validateViewPort();
        }
        
        override public function set x(value:Number):void
        {
            super.x = value;
            validateViewPort();
        }
        
        override public function set y(value:Number):void
        {
            super.y = value;
            validateViewPort();
        }
        
        override public function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            var localX:Number = localPoint.x;
            var localY:Number = localPoint.y;
            var object:DisplayObject = super.hitTest(localPoint, forTouch);
            if(object)
                return object;
            
            var starlingPoint:Point = localToGlobal(new Point(localX, localY));
            return localViewPort.contains(starlingPoint.x, starlingPoint.y) ? this : null;
        }
        
        override public function render(support:RenderSupport, alpha:Number):void
        {
            support.finishQuadBatch()
            
            Starling.context.setScissorRectangle(localViewPort);
            super.render(support,alpha);
            support.finishQuadBatch();
            
            Starling.context.setScissorRectangle(null);
        }
        
        private function validateViewPort():void
        {
            _localViewPort = null;
            dispatchEventWith(VIEWPORT_UPDATED);
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
    }
}