package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.geom.Point;
    
    import starling.display.Image;
    import starling.textures.Texture;
    
    public class Marker extends Image
    {
        public var location:Point;
        
        public function Marker(location:Point, texture:Texture)
        {
            super(texture);
            this.location = location;
        }
    }
}