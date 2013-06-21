package sk.yoz.ycanvas.demo.starlingComponent.partitions
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.starlingComponent.Layer;
    
    public class ArcGisPartition extends AbstractPartition
    {
        public function ArcGisPartition(layer:Layer, x:int, y:int, dispatcher:IEventDispatcher)
        {
            super(layer, x, y, dispatcher);
        }
        
        override protected function get url():String
        {
            var level:uint = 18 - getPow(layer.level);
            var x:int = this.x / expectedWidth / layer.level;
            var y:int = this.y / expectedHeight / layer.level;
            var result:String = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/" 
                + level + "/" + y + "/" + x;
            return result;
        }
    }
}