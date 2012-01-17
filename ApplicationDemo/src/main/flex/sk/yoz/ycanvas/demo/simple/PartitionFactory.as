package sk.yoz.ycanvas.demo.simple
{
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class PartitionFactory implements IPartitionFactory
    {
        public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new Partition(layer, x, y);
        }
        
        public function disposePartition(partition:IPartition):void
        {
            Partition(partition).dispose();
        }
    }
}