package sk.yoz.ycanvas.interfaces
{
    import flash.display.DisplayObject;
    import flash.geom.Matrix;

    public interface IPartition
    {
        /**
        * X coordinate of left-top point of a partition.
        */ 
        function get x():int
        
        /**
        * Y coordinate of left-top point of a partition.
        */
        function get y():int
        
        /**
        * Expected partition width.
        */
        function get expectedWidth():uint
        
        /**
        * Expected partition height.
        */
        function get expectedHeight():uint
        
        /**
        * A Matrix object representing the combined transformation matrixes
        * of the display object and all of its parent objects, back to the 
        * root level. 
        */
        function get concatenatedMatrix():Matrix
        
        /**
        * An API providing functionality to apply any 
        * flash.display.DisplayObject and its transformation matrix 
        * to a partition. Can
        * If a partition implementation is based on bitmapData, a method
        * implementation may look as simple as 
        * bitmapData.draw(source, matrix);.
        */
        function applyDisplayObject(source:DisplayObject, matrix:Matrix):void
        
        /**
        * Produces a readable partition description.
        */ 
        function toString():String
    }
}