package sk.yoz.ycanvas.map.partitions
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.net.URLRequestBuffer;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    import sk.yoz.ycanvas.map.layers.Layer;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    
    public class PartitionFactory implements IPartitionFactory
    {
        public var config:MapConfig;
        
        private var dispatcher:IEventDispatcher;
        private var buffer:URLRequestBuffer;
        
        public function PartitionFactory(config:MapConfig, dispatcher:IEventDispatcher, buffer:URLRequestBuffer)
        {
            this.config = config;
            this.dispatcher = dispatcher;
            this.buffer = buffer;
        }
        
        public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new Partition(x, y, layer as Layer, config, dispatcher, buffer);
        }
        
        public function disposePartition(partition:IPartition):void
        {
            Partition(partition).dispose();
        }
    }
}