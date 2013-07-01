package sk.yoz.ycanvas.map.partitions
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.net.URLRequestBuffer;
    import sk.yoz.ycanvas.map.layers.Layer;
    import sk.yoz.ycanvas.map.valueObjects.Mode;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class PartitionFactory implements IPartitionFactory
    {
        public var mode:Mode;
        
        private var dispatcher:IEventDispatcher;
        private var buffer:URLRequestBuffer;
        
        public function PartitionFactory(mode:Mode, dispatcher:IEventDispatcher, buffer:URLRequestBuffer)
        {
            this.mode = mode;
            this.dispatcher = dispatcher;
            this.buffer = buffer;
        }
        
        public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new Partition(x, y, layer as Layer, mode, dispatcher, buffer);
        }
        
        public function disposePartition(partition:IPartition):void
        {
            Partition(partition).dispose();
        }
    }
}