package sk.yoz.ycanvas.demo.starlingComponent
{
    import sk.yoz.ycanvas.demo.starlingComponent.partitions.AbstractPartition;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class PartitionFactory implements IPartitionFactory
    {
        private var partitionConstructor:Class;
        
        public function PartitionFactory(partitionConstructor:Class)
        {
            this.partitionConstructor = partitionConstructor;
        }
        
        public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new partitionConstructor(layer, x, y);
        }
        
        public function disposePartition(partition:IPartition):void
        {
            AbstractPartition(partition).dispose();
        }
    }
}