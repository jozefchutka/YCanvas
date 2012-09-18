package sk.yoz.ycanvas.demo.markers.ycanvas
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.demo.markers.Assets;
    
    import starling.display.Image;
    import starling.textures.Texture;
    
    public class Marker extends Image
    {
        private static var greenMarker:Texture;
        private static var pinkMarker:Texture;
        
        private var location:Point;
        
        private var _canvasCenter:Point;
        
        public function Marker(location:Point)
        {
            this.location = location;
            
            var texture:Texture;
            if(!greenMarker)
                greenMarker = Texture.fromBitmap(new Assets.MARKER_GREEN_CLASS);
            if(!pinkMarker)
                pinkMarker = Texture.fromBitmap(new Assets.MARKER_PINK_CLASS);
            texture = Math.random() > .5 ? greenMarker : pinkMarker;
            super(texture);
            pivotX = texture.width / 2;
            pivotY = texture.height;
        }
        
        public function set canvasCenter(value:Point):void
        {
            x = location.x - value.x;
            y = location.y - value.y;
        }
        
        public function set canvasScale(value:Number):void
        {
            scaleX = scaleY = 1 / value * .2;
        }
        
        public function set canvasRotation(value:Number):void
        {
            rotation = -value;
        }
    }
}