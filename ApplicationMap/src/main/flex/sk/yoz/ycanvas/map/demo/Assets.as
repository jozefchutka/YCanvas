package sk.yoz.ycanvas.map.demo
{
    import starling.textures.Texture;

    public class Assets
    {
        [Embed(source="/markers/green.png")]
        private static const MARKER_GREEN_CLASS:Class;
        
        [Embed(source="/markers/pink.png")]
        private static const MARKER_PINK_CLASS:Class;
        
        private static var _MARKER_GREEN_TEXTURE:Texture;
        
        public static function get MARKER_GREEN_TEXTURE():Texture
        {
            if(!_MARKER_GREEN_TEXTURE)
                _MARKER_GREEN_TEXTURE = Texture.fromBitmap(new MARKER_GREEN_CLASS);
            return _MARKER_GREEN_TEXTURE;
        }
    }
}