package sk.yoz.ycanvas.demo.explorer.modes.walloffame
{
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.LayerFactory;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.FactoryData;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class WallOfFameLayerFactory extends LayerFactory
    {
        public function WallOfFameLayerFactory(partitionFactory:IPartitionFactory, 
            factoryData:FactoryData)
        {
            super(partitionFactory, factoryData);
        }
        
        override protected function getLayerIndex(scale:Number):uint
        {
            var zoom:Number = 1 / scale;
            if(zoom < 2)
                return 0;
            if(zoom < 6)
                return 1;
            return 2;
        }
    }
}