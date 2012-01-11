package sk.yoz.ycanvas.demo.explorer.modes
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class PartitionFactory implements IPartitionFactory
    {
        protected var dispatcher:IEventDispatcher;
        
        public function PartitionFactory(dispatcher:IEventDispatcher)
        {
            this.dispatcher = dispatcher;
        }
        
        public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return null;
        }
        
        public function disposePartition(partition:IPartition):void
        {
            Partition(partition).dispose();
        }
    }
}