package sk.yoz.ycanvas.map.display
{
    import flash.geom.Point;
    
    import starling.display.Sprite;
    
    /**
    * Base implementation for any map layer.
    */
    public class MapLayer extends Sprite
    {
        private var _width:Number;
        private var _height:Number;
        private var _center:Point = new Point;
        private var _scale:Number;
        
        /**
        * Width of the component is handled custom for positioning purposes.
        */
        override public function set width(value:Number):void
        {
            if(width == value)
                return;
            
            _width = value;
            updatePosition();
        }
        
        override public function get width():Number
        {
            return _width;
        }
        
        /**
        * Height of the component is handled custom for positioning purposes.
        */
        override public function set height(value:Number):void
        {
            if(height == value)
                return;
            
            _height = value;
            updatePosition();
        }
        
        override public function get height():Number
        {
            return _height;
        }
        
        /**
        * YCanvas center point coordinates.
        */
        public function set center(value:Point):void
        {
            if(center == value)
                return;
            
            _center = value;
            updatePosition();
        }
        
        public function get center():Point
        {
            return _center;
        }
        
        /**
        * YCanvas scale.
        */
        public function set scale(value:Number):void
        {
            if(scale == value)
                return;
            
            _scale = scaleX = scaleY = value;
            updatePosition();
        }
        
        public function get scale():Number
        {
            return _scale;
        }
        
        /**
        * YCanvas rotation.
        */
        override public function set rotation(value:Number):void
        {
            if(rotation == value)
                return;
            
            super.rotation = value;
            updatePosition();
        }
        
        /**
        * Calculates x, y of map layer based on YCanvas transformation.
        */
        private function updatePosition():void
        {
            var x:Number = -center.x * scale;
            var y:Number = -center.y * scale;
            var sin:Number = Math.sin(rotation);
            var cos:Number = Math.cos(rotation);
            
            this.x = cos * x - sin * y + width / 2;
            this.y = cos * y + sin * x + height / 2;
        }
    }
}