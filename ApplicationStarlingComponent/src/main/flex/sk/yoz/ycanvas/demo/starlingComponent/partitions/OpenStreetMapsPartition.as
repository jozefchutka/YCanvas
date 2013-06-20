package sk.yoz.ycanvas.demo.starlingComponent.partitions
{
    import sk.yoz.ycanvas.interfaces.ILayer;

    public class OpenStreetMapsPartition extends AbstractPartition
    {
        public function OpenStreetMapsPartition(layer:ILayer, x:int, y:int)
        {
            super(layer, x, y);
        }
        
        override protected function get url():String
        {
            var level:uint = 18 - getPow(layer.level);
            var x:int = this.x / expectedWidth / layer.level;
            var y:int = this.y / expectedHeight / layer.level;
            var server:String = getServer(Math.abs(x + y) % 3);
            var result:String = "http://" + server + ".tile.openstreetmap.org/" 
                + level + "/" + x + "/" + y + ".png";
            return result;
        }
        
        private function getServer(value:uint):String
        {
            if(value == 1)
                return "a";
            if(value == 2)
                return "b";
            return "c";
        }
    }
}