package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.starlingComponent.partitions.AbstractPartition;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class PartitionFactory implements IPartitionFactory
    {
        private var partitionConstructor:Class;
        private var dispatcher:IEventDispatcher;
        
        public function PartitionFactory(partitionConstructor:Class, dispatcher:IEventDispatcher)
        {
            this.partitionConstructor = partitionConstructor;
            this.dispatcher = dispatcher;
        }
        
        public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new partitionConstructor(layer, x, y, dispatcher);
        }
        
        public function disposePartition(partition:IPartition):void
        {
            AbstractPartition(partition).dispose();
        }
    }
}