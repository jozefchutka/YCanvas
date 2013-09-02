package sk.yoz.ycanvas.demo.explorer.modes.jotwol
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.Partition;
    
    public class JotwolPartition extends Partition
    {
        public function JotwolPartition(layer:Layer, x:int, y:int,
            requestedWidth:uint, requestedHeight:uint, dispatcher:IEventDispatcher)
        {
            super(layer, x, y, requestedWidth, requestedHeight, dispatcher);
        }
        
        override protected function get url():String
        {
            var x:int = this.x / layer.level / expectedWidth;
            var y:int = this.y / layer.level / expectedHeight;
            var url:String = "http://www.jotwol.com/back_image.php?name="
                + (x >= 0 ? "p" : "n") + Math.abs(x)
                + "_"
                + (y >= 0 ? "p" : "n") + Math.abs(y)
                + ".png"
                + "&height=" + expectedWidth
                + "&width=" + expectedHeight
                + "&randno=" + uint(Math.random() * uint.MAX_VALUE);
                
            return "http://www.yoz.sk/proxy.php?url=" + encodeURIComponent(url);
        }
    }
}