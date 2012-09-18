package sk.yoz.ycanvas.demo.markers.ycanvas
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.demo.markers.valueObjects.FactoryData;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.ILayerFactory;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    public class LayerFactory implements ILayerFactory
    {
        protected var partitionFactory:IPartitionFactory;
        protected var factoryData:FactoryData;
        protected var layers:Vector.<Layer> = new Vector.<Layer>();
        
        public function LayerFactory(partitionFactory:IPartitionFactory, 
            factoryData:FactoryData)
        {
            this.partitionFactory = partitionFactory;
            this.factoryData = factoryData;
            createLayers();
        }
        
        public function create(scale:Number, center:Point):ILayer
        {
            return getLayerByScale(scale);
        }
        
        public function disposeLayer(layer:ILayer):void
        {
            Layer(layer).dispose();
        }
        
        protected function createLayers():void
        {
            var max:uint = factoryData.layerMaxLevel;
            var step:uint = factoryData.layerStep;
            var w:uint = factoryData.partitionWidth;
            var h:uint = factoryData.partitionHeight;
            for(var level:uint = 1; level <= max; level *= step)
                layers.push(new Layer(level, w, h, partitionFactory));
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