package sk.yoz.ycanvas.interfaces
{
    public interface IYCanvasRoot
    {
        /**
        * Indicates the x coordinate of the IYCanvasRoot instance relative 
        * to the local coordinates of the parent DisplayObjectContainer.
        */
        function set x(value:Number):void
        
        /**
        * Indicates the y coordinate of the IYCanvasRoot instance relative 
        * to the local coordinates of the parent DisplayObjectContainer.
        */
        function set y(value:Number):void
        
        /**
        * Indicates the rotation of the IYCanvasRoot instance, in radians.
        */
        function set rotation(value:Number):void
        
        /**
        * Indicates both horizontal and vertical scale (percentage) of the 
        * object.
        */
        function set scale(value:Number):void
        
        /**
        * A list of available layers.
        */
        function get layers():Vector.<ILayer>
        
        /**
        * A method for adding a layer.
        */
        function addLayer(layer:ILayer):void
        
        /**
        * A method for removing a layer.
        */
        function removeLayer(layer:ILayer):void
        
        /**
        * Completely disposes root.
        */
        function dispose():void
    }
}