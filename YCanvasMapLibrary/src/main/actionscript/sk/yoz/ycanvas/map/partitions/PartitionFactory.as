package sk.yoz.ycanvas.map.partitions
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.net.URLRequestBuffer;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    
    /**
    * An implementation of YCanvas partition factory.
    */
    public class PartitionFactory implements IPartitionFactory
    {
        /**
        * A map config reference.
        */
        public var config:MapConfig;
        
        protected var dispatcher:IEventDispatcher;
        protected var buffer:URLRequestBuffer;
        
        public function PartitionFactory(config:MapConfig, 
            dispatcher:IEventDispatcher, buffer:URLRequestBuffer)
        {
            this.config = config;
            this.dispatcher = dispatcher;
            this.buffer = buffer;
        }
        
        /**
        * Creates and returns a partition with proper coordinates and layer.
        */
        public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new Partition(x, y, layer, config, dispatcher, buffer);
        }
        
        /**
        * Disposes a partition.
        */
        public function disposePartition(partition:IPartition):void
        {
            Partition(partition).dispose();
        }
    }
}