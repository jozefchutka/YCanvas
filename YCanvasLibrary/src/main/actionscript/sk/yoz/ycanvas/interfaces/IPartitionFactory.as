package sk.yoz.ycanvas.interfaces
{
    public interface IPartitionFactory
    {
        /**
        * Provides a partition reference (or creates one) for custom parameters.
        */
        function create(x:int, y:int, layer:ILayer):IPartition
        
        /**
        * Disposes a partition.
        */
        function disposePartition(partition:IPartition):void
    }
}