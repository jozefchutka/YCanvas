package sk.yoz.ycanvas.utils
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IPartition;
    
    /**
     * An utility class for partition livecycle optimization.
     */
    public class PartitionOptimizationUtils
    {
        private static const OVERLAP_ALL:uint = 0;
        private static const OVERLAP_LOWER:uint = 1;
        private static const OVERLAP_UPPER:uint = 2;
        
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
        * Disposes partitions in other layers that overlaps the partition.
        * 
        * @param layer A layer containing the partition.
        * @param partition A partition to be tested.
        */
        public static function disposeOverlaping(
            canvas:AbstractYCanvas, layer:ILayer, partition:IPartition):void
        {
            disposeOverlapingByMode(canvas, layer, partition, OVERLAP_ALL);
        }
        
        /**
         * Disposes partitions in lower layers that overlaps the partition.
         * 
         * @param layer A layer containing the partition.
         * @param partition A partition to be tested.
         */
        public static function disposeLower(
            canvas:AbstractYCanvas, layer:ILayer, partition:IPartition):void
        {
            disposeOverlapingByMode(canvas, layer, partition, OVERLAP_LOWER);
        }
        
        /**
         * Disposes partitions in upper layers that overlaps the partition.
         * 
         * @param layer A layer containing the partition.
         * @param partition A partition to be tested.
         */
        public static function disposeUpper(
            canvas:AbstractYCanvas, layer:ILayer, partition:IPartition):void
        {
            disposeOverlapingByMode(canvas, layer, partition, OVERLAP_UPPER);
        }
        
        
        /**
        * Disposes a list of partitions in layer.
        */
        private static function dispose(canvas:AbstractYCanvas, layer:ILayer, 
            partitions:Vector.<IPartition>):void
        {
            var length:uint = partitions.length;
            for(var i:uint = 0; i < length; i++)
                canvas.disposePartition(layer, partitions[i]);
        }
        
        /**
        * Disposes partitions in layers (based on mode) that overlaps the 
        * partition.
        */
        private static  function disposeOverlapingByMode(canvas:AbstractYCanvas,
            layer:ILayer, partition:IPartition, mode:uint):void
        {
            var layers:Vector.<ILayer> = canvas.layers;
            var iLayer:ILayer, iLength:uint, iPartition:IPartition;
            var iPartitions:Vector.<IPartition>;
            var isLower:Boolean = mode == OVERLAP_LOWER;
            var isUpper:Boolean = mode == OVERLAP_UPPER;
            for(var i:uint = 0, length:uint = layers.length; i < length; i++)
            {
                iLayer = layers[i];
                if(iLayer == layer
                    || (isLower && iLayer.level > layer.level)
                    || (isUpper && iLayer.level < layer.level))
                    continue;
                
                iPartitions = iLayer.partitions.concat();
                iLength = iPartitions.length;
                for(var j:uint = 0; j < iLength; j++)
                {
                    iPartition = iPartitions[j];
                    if(isOverlaping(layer, partition, iLayer, iPartition))
                        canvas.disposePartition(iLayer, iPartition);
                }
            }
        }
        
        /**
        * Returns partitions on all levels overlaping specified point.
        */
        public static function getAt(canvas:AbstractYCanvas, point:Point):
            Vector.<IPartition>
        {
            var layers:Vector.<ILayer> = canvas.layers;
            var layer:ILayer, partition:IPartition;
            var partitions:Vector.<IPartition> = new Vector.<IPartition>();
            var partitionsLength:uint;
            for(var i:uint = 0, length:uint = layers.length; i < length; i++)
            {
                layer = layers[i];
                partitionsLength = layer.partitions.length;
                for(var j:uint = 0; j < partitionsLength; j++)
                {
                    partition = layer.partitions[j];
                    if(isOverlapingPoint(point, layer, partition))
                        partitions.push(partition);
                }
            }
            return partitions;
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