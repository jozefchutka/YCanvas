package sk.yoz.ycanvas.utils
{
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.interfaces.ILayer;
    
    /**
    * An utility class for layer livecycle optimization.
    */
    public class ILayerUtils
    {
        /**
        * Disposes all layers from a canvas layer list based on z index.
        * 
        * @param depth Indicates amount of layers on top of the display list 
        * to be skipped.
        */
        public static function disposeDeep(canvas:AbstractYCanvas, 
            depth:uint = 1):void
        {
            var layers:Vector.<ILayer> = canvas.layers.concat();
            var length:uint = Math.max(layers.length - depth, 0);
            for(var i:uint = 0; i < length; i++)
                canvas.disposeLayer(layers[i]);
        }
        
        /**
        * Disposes all layers without partition.
        */
        public static function disposeEmpty(canvas:AbstractYCanvas):void
        {
            var layers:Vector.<ILayer> = canvas.layers.concat();
            for(var i:uint = 0, length:uint = layers.length; i < length; i++)
                if(!layers[i].partitions.length)
                    canvas.disposeLayer(layers[i]);
        }
    }
}