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
    
    public class Layer implements ILayerStarling
    {
        public var config:MapConfig;
        
        private var partitionFactory:IPartitionFactory;
        
        private var _level:uint;
        private var _center:Point = new Point;
        private var _partitions:Vector.<IPartition> = new Vector.<IPartition>;
        private var _content:Sprite = new Sprite;
        
        public function Layer(level:uint, config:MapConfig, partitionFactory:IPartitionFactory)
        {
            _level = level;
            this.config = config;
            this.partitionFactory = partitionFactory;
            content.touchable = false;
        }
        
        public function get content():DisplayObjectContainer
        {
            return _content;
        }
        
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
        
        public function set scale(value:Number):void
        {
            content.scaleX = content.scaleY = value;
        }
        
        public function get level():uint
        {
            return _level;
        }
        
        public function get partitions():Vector.<IPartition>
        {
            return _partitions;
        }
        
        public function get partitionWidth():uint
        {
            return config.tileWidth;
        }
        
        public function get partitionHeight():uint
        {
            return config.tileHeight;
        }
        
        public function addPartition(partition:IPartition):void
        {
            if(partitions.indexOf(partition) != -1)
                return;
            
            partitions.push(partition);
            positionPartition(partition);
            content.addChild((partition as IPartitionStarling).content);
        }
        
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
        
        public function removePartition(partition:IPartition):void
        {
            var partitionStarling:IPartitionStarling = partition as IPartitionStarling;
            
            if(partitionStarling.content)
                content.removeChild(partitionStarling.content);
            var index:int = partitions.indexOf(partition);
            if(index != -1)
                partitions.splice(index, 1);
        }
        
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
        
        private function positionPartition(partition:IPartition):void
        {
            var partitionStarling:IPartitionStarling = partition as IPartitionStarling;
            partitionStarling.content.x = (partition.x - center.x) / level;
            partitionStarling.content.y = (partition.y - center.y) / level;
        }
        
        public function toString():String
        {
            return "Layer: [level:" + level + "]";
        }
    }
}