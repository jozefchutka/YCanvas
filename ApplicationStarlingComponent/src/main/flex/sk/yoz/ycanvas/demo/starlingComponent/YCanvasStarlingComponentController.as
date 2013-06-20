package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.demo.starlingComponent.partitions.AbstractPartition;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.stage3D.YCanvasRootStage3D;
    import sk.yoz.ycanvas.utils.ILayerUtils;
    import sk.yoz.ycanvas.utils.IPartitionUtils;
    
    public class YCanvasStarlingComponentController extends AbstractYCanvas
    {
        public function YCanvasStarlingComponentController(viewPort:Rectangle, partitionConstructor:Class)
        {
            _root = new YCanvasRootStage3D;
            
            super(viewPort);
            
            partitionFactory = new PartitionFactory(partitionConstructor);
            layerFactory = new LayerFactory(partitionFactory);
            center = new Point(35e6, 25e6);
            scale = 1 / 16384;
            render();
        }
        
        public function get component():YCanvasRootStage3D
        {
            return root as YCanvasRootStage3D;
        }
        
        override public function render():void
        {
            super.render();
            IPartitionUtils.disposeInvisible(this);
            ILayerUtils.disposeEmpty(this);
            
            var main:Layer = layers[layers.length - 1] as Layer;
            for each(var layer:Layer in layers)
                (layer == main) ? startLoading(layer) : stopLoading(layer);
        }
        
        override protected function centerRoot():void
        {
            root.x = viewPort.x + viewPort.width / 2;
            root.y = viewPort.y + viewPort.height / 2;
        }
        
        private function startLoading(layer:Layer):void
        {
            var partition:AbstractPartition;
            var list:Vector.<IPartition> = layer.partitions;
            for(var i:uint = 0, length:uint = list.length; i < length; i++)
            {
                partition = list[i] as AbstractPartition;
                if(!partition.loading && !partition.loaded)
                    partition.load();
            }
        }
        
        private function stopLoading(layer:Layer):void
        {
            var partition:AbstractPartition;
            var list:Vector.<IPartition> = layer.partitions;
            for(var i:uint = 0, length:uint = list.length; i < length; i++)
            {
                partition = list[i] as AbstractPartition;
                if(partition.loading)
                    partition.stopLoading();
            }
        }
    }
}