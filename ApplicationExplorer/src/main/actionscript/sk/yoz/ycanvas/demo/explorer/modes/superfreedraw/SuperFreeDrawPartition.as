package sk.yoz.ycanvas.demo.explorer.modes.superfreedraw
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.explorer.Utils;
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.Partition;
    
    public class SuperFreeDrawPartition extends Partition
    {
        public function SuperFreeDrawPartition(layer:Layer, x:int, y:int, 
            requestedWidth:uint, requestedHeight:uint, dispatcher:IEventDispatcher)
        {
            super(layer, x, y, requestedWidth, requestedHeight, dispatcher);
        }
        
        override protected function get url():String
        {
            var url:String = "http://tile.superfreedraw.com/tile.php" 
                + "?x=" + (x / layer.level / expectedWidth)
                + "&y=" + (y / layer.level / expectedHeight)
                + "&z=" + (8 - Utils.getPow(layer.level))
                + "&r=" + (new Date().minutes);
            
            return "http://www.yoz.sk/proxy.php?url=" + encodeURIComponent(url);
        }
    }
}