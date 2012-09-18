package sk.yoz.ycanvas.demo.markers.modes.mapquest
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.markers.Utils;
    import sk.yoz.ycanvas.demo.markers.ycanvas.Layer;
    import sk.yoz.ycanvas.demo.markers.ycanvas.Partition;
    
    public class MapQuestPartition extends Partition
    {
        public function MapQuestPartition(layer:Layer, x:int, y:int, 
            requestedWidth:uint, requestedHeight:uint, dispatcher:IEventDispatcher)
        {
            super(layer, x, y, requestedWidth, requestedHeight, dispatcher);
        }
        
        override protected function get url():String
        {
            var level:uint = 18 - Utils.getPow(layer.level);
            var x:int = this.x / expectedWidth / layer.level;
            var y:int = this.y / expectedHeight / layer.level;
            var server:uint = Math.abs(x + y) % 4 + 1;
            var result:String = "http://mtile0" + server + ".mqcdn.com/tiles/1.0.0/vy/map/" 
                + level + "/" + x + "/" + y + ".jpg";
            return result;
        }
    }
}