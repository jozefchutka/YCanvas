package sk.yoz.ycanvas.map.layers
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.interfaces.IPartition;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    import sk.yoz.ycanvas.starling.interfaces.ILayerStarling;
    import sk.yoz.ycanvas.starling.interfaces.IPartitionStarling;
    
    import starling.display.DisplayObjectContainer;
    import starling.display.Sprite;
    
    /**
    * An implementaion of YCanvas layer.
    */
    public class Layer implements ILayerStarling
    {
        /**
        * A map configuration.
        */
        public var config:MapConfig;
        
        private var partitionFactory:IPartitionFactory;
        
        private var _level:uint;
        private var _center:Point = new Point;
        private var _partitions:Vector.<IPartition> = new Vector.<IPartition>;
        private var _content:Sprite = new Sprite;
        
        public function Layer(level:uint, config:MapConfig,
            partitionFactory:IPartitionFactory)
        {
            _level = level;
            this.config = config;
            this.partitionFactory = partitionFactory;
            content.touchable = false;
        }
        
        /**
        * Returns the main container.
        */
        public function get content():DisplayObjectContainer
        {
            return _content;
        }
        
        /**
        * YCanvas center point coordinates.
        */
        public function set center(value:Point):void
        {
            _center = value;
            var length:uint = partitions.length;
            for(var i:uint = 0; i < length; i++)
                positionPartition(partitions[i]);
        }
        
        public function get center():Point
        {
            return _center;
        }
        
        /**
        * YCanvas scale.
        */
        public function set scale(value:Number):void
        {
            content.scaleX = content.scaleY = value;
        }
        
        /**
        * Returns level of the layer.
        */
        public function get level():uint
        {
            return _level;
        }
        
        /**
        * Returns the list of available partitions.
        */
        public function get partitions():Vector.<IPartition>
        {
            return _partitions;
        }
        
        /**
        * Returns expected partition width.
        */
        public function get partitionWidth():uint
        {
            return config.tileWidth;
        }
        
        /**
        * Returns expected partition height.
        */
        public function get partitionHeight():uint
        {
            return config.tileHeight;
        }
        
        /**
        * Adds a partition.
        */
        public function addPartition(partition:IPartition):void
        {
            if(partitions.indexOf(partition) != -1)
                return;
            
            partitions.push(partition);
            positionPartition(partition);
            content.addChild((partition as IPartitionStarling).content);
        }
        
        /**
        * Returns available partition with specific coordinates.
        */
        public function getPartition(x:int, y:int):IPartition
        {
            var length:uint = partitions.length;
            var partition:IPartition;
            for(var i:uint = 0; i < length; i++)
            {
                partition = partitions[i];
                if(partition.x == x && partition.y == y)
                    return partition;
            }
            return null;
        }
        
        /**
        * Removes a partition.
        */
        public function removePartition(partition:IPartition):void
        {
            var partitionStarling:IPartitionStarling = partition as IPartitionStarling;
            if(partitionStarling.content)
                content.removeChild(partitionStarling.content);
            
            var index:int = partitions.indexOf(partition);
            if(index != -1)
                partitions.splice(index, 1);
        }
        
        /**
        * Dispopses itself and all its content.
        */
        public function dispose():void
        {
            if(!partitions.length)
                return;
            
            var partition:IPartition;
            var list:Vector.<IPartition> = partitions.concat();
            for(var i:uint = 0, length:uint = list.length; i < length; i++)
            {
                partition = list[i];
                removePartition(partition);
                partitionFactory.disposePartition(partition);
            }
        }
        
        /**
        * Repositions a partition according to current YCanvas transformation.
        */
        private function positionPartition(partition:IPartition):void
        {
            var partitionStarling:IPartitionStarling = partition as IPartitionStarling;
            partitionStarling.content.x = (partition.x - center.x) / level;
            partitionStarling.content.y = (partition.y - center.y) / level;
        }
        
        /**
        * Returns a string interpretation of the layer.
        */
        public function toString():String
        {
            return "Layer: [level:" + level + "]";
        }
    }
}