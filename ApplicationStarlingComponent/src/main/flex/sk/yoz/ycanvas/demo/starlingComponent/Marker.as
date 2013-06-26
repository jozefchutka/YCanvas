package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.geom.Point;
    
    import starling.display.Image;
    import starling.textures.Texture;
    
    public class Marker extends Image
    {
        private var location:Point;
        
        private var _canvasCenter:Point;
        
        public function Marker(location:Point, texture:Texture, pivotX:Number = 0, pivotY:Number = 0)
        {
            super(texture);
            this.location = location;
            this.pivotX = pivotX;
            this.pivotY = pivotY;
        }
        
        public function set canvasCenter(value:Point):void
        {
            x = location.x - value.x;
            y = location.y - value.y;
        }
        
        public function set canvasScale(value:Number):void
        {
            //scaleX = scaleY = 1 / value * .2;
        }
        
        public function set canvasRotation(value:Number):void
        {
            //rotation = -value;
        }
    }
}