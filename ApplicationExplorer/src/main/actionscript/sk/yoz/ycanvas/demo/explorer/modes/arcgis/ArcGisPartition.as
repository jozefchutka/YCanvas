package sk.yoz.ycanvas.demo.explorer.modes.arcgis
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.explorer.Utils;
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.Partition;
    
    public class ArcGisPartition extends Partition
    {
        public function ArcGisPartition(layer:Layer, x:int, y:int, 
            requestedWidth:uint, requestedHeight:uint, dispatcher:IEventDispatcher)
        {
            super(layer, x, y, requestedWidth, requestedHeight, dispatcher);
        }
        
        override protected function get url():String
        {
            var level:uint = 18 - Utils.getPow(layer.level);
            var x:int = this.x / expectedWidth / layer.level;
            var y:int = this.y / expectedHeight / layer.level;
            var result:String = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/" 
                + level + "/" + y + "/" + x;
            return result;
        }
    }
}