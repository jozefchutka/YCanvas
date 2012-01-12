package sk.yoz.ycanvas.demo.explorer.modes.onboard
{
    import sk.yoz.ycanvas.demo.explorer.modes.LayerFactory;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.FactoryData;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class OnBoardLayerFactory extends LayerFactory
    {
        public static const MAX_LEVEL:uint = 32;
        public static const PARTITION_WIDTH:uint = 256;
        public static const PARTITION_HEIGHT:uint = 256;
        
        public function OnBoardLayerFactory(partitionFactory:IPartitionFactory, 
            factoryData:FactoryData):void
        {
            super(partitionFactory, factoryData);
            createLayers();
        }
    }
}