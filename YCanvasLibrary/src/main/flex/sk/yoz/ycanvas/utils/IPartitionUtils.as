package sk.yoz.ycanvas.utils
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.valueObjects.LayerPartitions;
    
    /**
     * An utility class for partition livecycle optimization.
     */
    public class IPartitionUtils
    {
        private static const OVERLAP_ALL:uint = 0;
        private static const OVERLAP_LOWER:uint = 1;
        private static const OVERLAP_UPPER:uint = 2;
        
        /**
        * Returns partitions in other layers that overlaps the partition.
        * 
        * @param layer A layer containing the partition.
        * @param partition A partition to be tested.
        */
        public static function getOverlaping(canvas:AbstractYCanvas, 
            layer:ILayer, partition:IPartition):Vector.<LayerPartitions>
        {
            return getOverlapingByMode(canvas, layer, partition, OVERLAP_ALL);
        }
        
        /**
         * Returns partitions in lower layers that overlaps the partition.
         * 
         * @param layer A layer containing the partition.
         * @param partition A partition to be tested.
         */
        public static function getLower(canvas:AbstractYCanvas, layer:ILayer, 
            partition:IPartition):Vector.<LayerPartitions>
        {
            return getOverlapingByMode(canvas, layer, partition, OVERLAP_LOWER);
        }
        
        /**
         * Returns partitions in upper layers that overlaps the partition.
         * 
         * @param layer A layer containing the partition.
         * @param partition A partition to be tested.
         */
        public static function getUpper(canvas:AbstractYCanvas, layer:ILayer, 
            partition:IPartition):Vector.<LayerPartitions>
        {
            return getOverlapingByMode(canvas, layer, partition, OVERLAP_UPPER);
        }
        
        /**
        * Returns partitions in layers that overlaps (based on mode) a 
        * custom partition in a layer.
        */
        private static  function getOverlapingByMode(canvas:AbstractYCanvas,
            layer:ILayer, partition:IPartition, mode:uint):
            Vector.<LayerPartitions>
        {
            var layers:Vector.<ILayer> = canvas.layers;
            var iLayer:ILayer, iLength:uint, iPartition:IPartition;
            var iPartitions:Vector.<IPartition>;
            var isLower:Boolean = mode == OVERLAP_LOWER;
            var isUpper:Boolean = mode == OVERLAP_UPPER;
            var list:Vector.<LayerPartitions> = new Vector.<LayerPartitions>();
            var layerPartitions:LayerPartitions;
            for(var i:uint = 0, length:uint = layers.length; i < length; i++)
            {
                iLayer = layers[i];
                if(iLayer == layer
                    || (isLower && iLayer.level > layer.level)
                    || (isUpper && iLayer.level < layer.level))
                    continue;
                
                iPartitions = iLayer.partitions.concat();
                iLength = iPartitions.length;
                layerPartitions = new LayerPartitions;
                layerPartitions.layer = iLayer;
                layerPartitions.partitions = new Vector.<IPartition>();
                list.push(layerPartitions);
                
                for(var j:uint = 0; j < iLength; j++)
                {
                    iPartition = iPartitions[j];
                    if(isOverlaping(layer, partition, iLayer, iPartition))
                        layerPartitions.partitions.push(iPartition);
                }
            }
            return list;
        }
        
        /**
         * Disposes all partitions on all layers that does not hit viewPort.
         */
        public static function disposeInvisible(canvas:AbstractYCanvas):void
        {
            var layers:Vector.<ILayer> = canvas.layers;
            var layer:ILayer, partitions:Vector.<IPartition>;
            for(var i:uint = 0, length:uint = layers.length; i < length; i++)
            {
                layer = layers[i];
                partitions = getInvisible(canvas, layer);
                dispose(canvas, layer, partitions);
            }
        }
        
        /**
        * Disposes a list of partitions in layer.
        */
        public static function dispose(canvas:AbstractYCanvas, layer:ILayer, 
            partitions:Vector.<IPartition>):void
        {
            var length:uint = partitions.length;
            for(var i:uint = 0; i < length; i++)
                canvas.disposePartition(layer, partitions[i]);
        }
        
        /**
        * Disposes a list of LayerPartitions.
        */
        public static function diposeLayerPartitionsList(canvas:AbstractYCanvas,
            layerPartitions:Vector.<LayerPartitions>):void
        {
            var length:uint = layerPartitions.length;
            for(var i:uint = 0; i < length; i++)
                dispose(canvas, layerPartitions[i].layer, 
                    layerPartitions[i].partitions);
        }
        
        /**
        * Returns partitions on all levels overlaping specified point.
        */
        public static function getAt(canvas:AbstractYCanvas, point:Point):
            Vector.<LayerPartitions>
        {
            var layers:Vector.<ILayer> = canvas.layers;
            var layer:ILayer, partition:IPartition;
            var partitionsLength:uint;
            var layerPartitions:LayerPartitions;
            var list:Vector.<LayerPartitions> = new Vector.<LayerPartitions>();
            for(var i:uint = 0, length:uint = layers.length; i < length; i++)
            {
                layer = layers[i];
                partitionsLength = layer.partitions.length;
                
                layerPartitions = new LayerPartitions;
                layerPartitions.layer = layers[i];
                layerPartitions.partitions = new Vector.<IPartition>();
                list.push(layerPartitions);
                
                for(var j:uint = 0; j < partitionsLength; j++)
                {
                    partition = layer.partitions[j];
                    if(isOverlapingPoint(point, layer, partition))
                        layerPartitions.partitions.push(partition);
                }
            }
            return list;
        }
        
        /**
        * Tests whether partition on one layer overlaps another partition
        * in a different layer.
        */
        private static function isOverlaping(layer1:ILayer, 
            partition1:IPartition, layer2:ILayer, partition2:IPartition):Boolean
        {
            var lowLayer:ILayer = layer1;
            var lowPartition:IPartition = partition1;
            var upLayer:ILayer = layer2;
            var upPartition:IPartition = partition2;
            
            if(layer1.level > layer2.level)
            {
                lowLayer = layer2;
                lowPartition = partition2;
                upLayer = layer1;
                upPartition = partition1;
            }
            
            return lowPartition.x >= upPartition.x
                && lowPartition.x < upPartition.x 
                    + upPartition.expectedWidth * upLayer.level
                && lowPartition.y >= upPartition.y 
                && lowPartition.y < upPartition.y 
                    + upPartition.expectedHeight * upLayer.level;
        }
        
        /**
        * Tests whether partition on a layer overlaps a specific point.
        */
        private static function isOverlapingPoint(point:Point, layer:ILayer, 
            partition:IPartition):Boolean
        {
            return point.x >= partition.x
                && point.x < partition.x 
                + partition.expectedWidth * layer.level
                && point.y >= partition.y 
                && point.y < partition.y 
                + partition.expectedHeight * layer.level;
        }
        
        /**
        * Returns a list of partitions available in layer but invisible in 
        * viewPort.
        */
        private static function getInvisible(
            canvas:AbstractYCanvas, layer:ILayer):Vector.<IPartition>
        {
            var w:uint = layer.partitionWidth * layer.level;
            var h:uint = layer.partitionHeight * layer.level;
            var partitions:Vector.<IPartition> = layer.partitions.concat();
            var partition:IPartition;
            var result:Vector.<IPartition> = new Vector.<IPartition>;
            var length:uint = partitions.length;
            for(var i:uint = 0; i < length; i++)
            {
                partition = partitions[i];
                if(!canvas.isCollision(
                    canvas.marginPoints, partition.x, partition.y, w, h))
                    result.push(partition);
            }
            
            return result;
        }
    }
}