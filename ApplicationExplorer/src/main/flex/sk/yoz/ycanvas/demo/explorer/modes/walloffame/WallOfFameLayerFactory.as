package sk.yoz.ycanvas.demo.explorer.modes.walloffame
{
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.LayerFactory;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class WallOfFameLayerFactory extends LayerFactory
    {
        public static const MAX_LEVEL:uint = 9;
        public static const PARTITION_WIDTH:uint = 512;
        public static const PARTITION_HEIGHT:uint = 512;
        
        public function WallOfFameLayerFactory(partitionFactory:IPartitionFactory)
        {
            super(partitionFactory);
            createLayers(MAX_LEVEL, PARTITION_WIDTH, PARTITION_HEIGHT);
        }
    
        override protected function createLayers(maxLevel:uint, partitionWidth:uint, 
            partitionHeight:uint):void
        {
            for(var level:uint = 1; level <= maxLevel; level *= 3)
                layers.push(new Layer(
                    level, partitionWidth, partitionHeight, partitionFactory));
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