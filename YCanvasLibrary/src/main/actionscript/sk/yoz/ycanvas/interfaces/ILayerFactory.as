package sk.yoz.ycanvas.interfaces
{
    import flash.geom.Point;

    public interface ILayerFactory
    {
        /**
        * Provides a layer reference (or creates one) for custom parameters. 
        */
        function create(scale:Number, center:Point):ILayer
        
        /**
        * Disposes a layer.
        */
        function disposeLayer(layer:ILayer):void
    }
}