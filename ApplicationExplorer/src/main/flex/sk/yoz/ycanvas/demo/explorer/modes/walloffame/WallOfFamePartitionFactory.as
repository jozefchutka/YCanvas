package sk.yoz.ycanvas.demo.explorer.modes.walloffame
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.PartitionFactory;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    
    public class WallOfFamePartitionFactory extends PartitionFactory
    {
        public function WallOfFamePartitionFactory(dispatcher:IEventDispatcher)
        {
            super(dispatcher);
        }
        
        override public function create(x:int, y:int, layer:ILayer):IPartition
        {
            return new WallOfFamePartition(layer as Layer, x, y, 
                layer.partitionWidth, layer.partitionHeight, dispatcher);
        }
    }
}