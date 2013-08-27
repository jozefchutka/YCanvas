package sk.yoz.ycanvas.map.demo.partition
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.map.partitions.PartitionFactory;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    
    public class CustomPartitionFactory extends PartitionFactory
    {
        public function CustomPartitionFactory(config:MapConfig,
            dispatcher:IEventDispatcher)
        {
            super(config, dispatcher);
        }
        
        override public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new CustomPartition(x, y, layer, config, dispatcher);
        }
    }
}