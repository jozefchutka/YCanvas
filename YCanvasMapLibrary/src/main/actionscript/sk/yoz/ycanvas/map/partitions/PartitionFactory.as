package sk.yoz.ycanvas.map.partitions
{
    import flash.events.IEventDispatcher;
    
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
        
        /**
        * For reasons related to loader usage, read IPartitionLoader docs.
        */
        protected var loader:IPartitionLoader;
        
        public function PartitionFactory(config:MapConfig, 
            dispatcher:IEventDispatcher, loader:IPartitionLoader=null)
        {
            this.config = config;
            this.dispatcher = dispatcher;
            this.loader = loader;
        }
        
        /**
        * Creates and returns a partition with proper coordinates and layer.
        */
        public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new Partition(x, y, layer, config, dispatcher, loader);
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