package sk.yoz.ycanvas.demo.explorer.modes.onboard
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.Partition;
    import sk.yoz.ycanvas.demo.explorer.modes.PartitionFactory;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    
    public class OnBoardPartitionFactory extends PartitionFactory
    {
        public function OnBoardPartitionFactory(dispatcher:IEventDispatcher)
        {
            super(dispatcher);
        }
        
        override public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new OnBoardPartition(layer as Layer, x, y, 
                layer.partitionWidth, layer.partitionHeight, dispatcher);
        }
    }
}