package sk.yoz.ycanvas.map.demo.partition
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.map.demo.utils.BingMapsUtils;
    import sk.yoz.ycanvas.map.partitions.IPartitionLoader;
    import sk.yoz.ycanvas.map.partitions.Partition;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    
    public class CustomPartition extends Partition
    {
        public function CustomPartition(x:int, y:int, layer:ILayer, 
            config:MapConfig, dispatcher:IEventDispatcher, 
            partitionLoader:IPartitionLoader)
        {
            super(x, y, layer, config, dispatcher, partitionLoader);
        }
        
        override protected function get url():String
        {
            var url:String = super.url;
            if(url.indexOf("${bingMapsQuadKey}") > 0)
            {
                var quadKey:String = BingMapsUtils.tileXYToQuadKey(
                    x / expectedWidth / layer.level,
                    y / expectedHeight / layer.level,
                    18 - getLevel(layer.level));
                url = url.replace("${bingMapsQuadKey}", quadKey);
            }
            
            return url;
        }
    }
}