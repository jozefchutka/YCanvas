package sk.yoz.ycanvas.demo.starlingComponent.partitions
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.starlingComponent.Layer;

    public class MapQuestPartition extends AbstractPartition
    {
        public function MapQuestPartition(layer:Layer, x:int, y:int, dispatcher:IEventDispatcher)
        {
            super(layer, x, y, dispatcher);
        }
        
        override protected function get url():String
        {
            var level:uint = 18 - getPow(layer.level);
            var x:int = this.x / expectedWidth / layer.level;
            var y:int = this.y / expectedHeight / layer.level;
            var server:uint = Math.abs(x + y) % 4 + 1;
            var result:String = "http://mtile0" + server + ".mqcdn.com/tiles/1.0.0/vy/map/" 
                + level + "/" + x + "/" + y + ".jpg";
            return result;
        }
    }
}