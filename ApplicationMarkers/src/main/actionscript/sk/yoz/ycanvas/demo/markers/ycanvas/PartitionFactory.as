package sk.yoz.ycanvas.demo.markers.ycanvas
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.markers.valueObjects.FactoryData;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class PartitionFactory implements IPartitionFactory
    {
        protected var dispatcher:IEventDispatcher;
        protected var factoryData:FactoryData;
        
        public function PartitionFactory(dispatcher:IEventDispatcher, 
            factoryData:FactoryData)
        {
            this.dispatcher = dispatcher;
            this.factoryData = factoryData;
        }
        
        public function create(x:int, y:int, layer:ILayer):IPartition
        {
            var partitionClass:Class = factoryData.partitionClass;
            return new partitionClass(layer as Layer, x, y, 
                layer.partitionWidth, layer.partitionHeight, dispatcher);
        }
        
        public function disposePartition(partition:IPartition):void
        {
            Partition(partition).dispose();
        }
    }
}