package sk.yoz.ycanvas.map.layers
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.ILayerFactory;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    
    public class LayerFactory implements ILayerFactory
    {
        private var layers:Vector.<Layer> = new Vector.<Layer>();
        
        public function LayerFactory(config:MapConfig, partitionFactory:IPartitionFactory)
        {
            for(var level:uint = 1; level <= 32768; level *= 2)
                layers.push(new Layer(level, config, partitionFactory));
        }
        
        public function create(scale:Number, center:Point):ILayer
        {
            return getLayerByScale(scale);
        }
        
        public function disposeLayer(layer:ILayer):void
        {
            Layer(layer).dispose();
        }
        
        private function getLayerByScale(scale:Number):Layer
        {
            return layers[getLayerIndex(scale)];
        }
        
        protected function getLayerIndex(scale:Number):uint
        {
            var zoom:Number = 1 / scale;
            var length:uint = layers.length;
            for(var i:uint = 0; i < length; i++)
                if(zoom < 1.5 * (1<<i))
                    break;
            return int(Math.min(length - 1, i));
        }
    }
}