package sk.yoz.ycanvas.demo.explorer
{
    import flash.text.Font;
    
    public class Assets
    {
        [Embed(source="/elements.swf", symbol="drag_rotate")]
        public static const DRAG_ROTATE_CLASS:Class;
        
        [Embed(source="/elements.swf", symbol="drag_zoom")]
        public static const DRAG_ZOOM_CLASS:Class;
    }
}