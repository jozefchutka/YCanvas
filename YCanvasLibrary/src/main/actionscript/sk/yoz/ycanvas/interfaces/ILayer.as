package sk.yoz.ycanvas.interfaces
{
    import flash.geom.Point;

    public interface ILayer
    {
        /**
        * A layer center point setter.
        */
        function set center(value:Point):void
        
        /**
        * A layer scale setter. 
        */
        function set scale(value:Number):void
        
        /**
        * Layer level getter.
        */
        function get level():uint
        
        /**
        * A list of partitions added to layer.
        */
        function get partitions():Vector.<IPartition>
        
        /**
        * Expected partition width for layer.
        */
        function get partitionWidth():uint
        
        /**
        * Expected partition height for layer.
        */
        function get partitionHeight():uint
        
        /**
        * Adds partition to layer. A custom implementation should take care of 
        * handling partitions that are already added.
        */
        function addPartition(partition:IPartition):void
        
        /**
        * Searches a partition by parameters.
        */
        function getPartition(x:int, y:int):IPartition
        
        /**
        * Removes partition from layer.
        */
        function removePartition(partition:IPartition):void
        
        /**
        * Produces a readable layer description.
        */
        function toString():String
    }
}