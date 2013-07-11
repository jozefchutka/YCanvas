package sk.yoz.ycanvas.map.display
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    
    public class MapComponent extends Sprite
    {
        public static const VIEWPORT_UPDATED:String = "viewPortUpdated";
        
        private var _width:Number = 200;
        private var _height:Number = 200;
        private var _globalViewPort:Rectangle;
        
        override public function get width():Number
        {
            return _width;
        }
        
        override public function set width(value:Number):void
        {
            _width = value;
            invalidateGlobalViewPort();
        }
        
        override public function get height():Number
        {
            return _height;
        }
        
        override public function set height(value:Number):void
        {
            _height = value;
            invalidateGlobalViewPort();
        }
        
        override public function set x(value:Number):void
        {
            super.x = value;
            invalidateGlobalViewPort();
        }
        
        override public function set y(value:Number):void
        {
            super.y = value;
            invalidateGlobalViewPort();
        }
        
        private function get globalViewPort():Rectangle
        {
            if(!_globalViewPort)
            {
                var globalPoint:Point = localToGlobal(new Point(0, 0));
                _globalViewPort = new Rectangle(globalPoint.x, globalPoint.y, width, height);
            }
            
            return _globalViewPort;
        }
        
        override public function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            var localX:Number = localPoint.x;
            var localY:Number = localPoint.y;
            var object:DisplayObject = super.hitTest(localPoint, forTouch);
            if(object)
                return object;
            
            var globalPoint:Point = localToGlobal(new Point(localX, localY));
            return globalViewPort.contains(globalPoint.x, globalPoint.y) ? this : null;
        }
        
        override public function render(support:RenderSupport, alpha:Number):void
        {
            support.finishQuadBatch()
            
            Starling.context.setScissorRectangle(globalViewPort);
            super.render(support,alpha);
            support.finishQuadBatch();
            
            Starling.context.setScissorRectangle(null);
        }
        
        public function invalidateGlobalViewPort():void
        {
            _globalViewPort = null;
            dispatchEventWith(VIEWPORT_UPDATED);
        }
    }
}