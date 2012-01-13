package sk.yoz.ycanvas.demo.explorer.modes.webcanvas
{
    import sk.yoz.ycanvas.demo.explorer.modes.LayerFactory;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.FactoryData;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class WebCanvasLayerFactory extends LayerFactory
    {
        public function WebCanvasLayerFactory(partitionFactory:IPartitionFactory, factoryData:FactoryData)
        {
            super(partitionFactory, factoryData);
        }
        
        override protected function getLayerIndex(scale:Number):uint
        {
            var zoom:Number = 1 / scale;
            if(zoom < 3)
                return 0;
            if(zoom < 15)
                return 1;
            return 2;
        }
    }
}