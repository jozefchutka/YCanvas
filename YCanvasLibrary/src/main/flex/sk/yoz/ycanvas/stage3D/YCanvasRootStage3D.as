package sk.yoz.ycanvas.stage3D
{
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.interfaces.IYCanvasRoot;
    import sk.yoz.ycanvas.stage3D.interfaces.ILayerStage3D;
    
    import starling.display.Sprite;
    
    /**
    * A Stage3D implementation of root interface.
    */
    public class YCanvasRootStage3D extends Sprite implements IYCanvasRoot
    {
        /**
        * An internal list of layers.
        */
        private var _layers:Vector.<ILayer> = new Vector.<ILayer>;
        
        /**
        * A list of available layers.
        */
        public function get layers():Vector.<ILayer>
        {
            return _layers;
        }
        
        /**
        * Indicates both horizontal and vertical scale (percentage) of the 
        * object.
        */
        public function set scale(value:Number):void
        {
            scaleX = scaleY = value;
        }
        
        /**
        * A method for adding a layer. A Layer is added at the end of list, 
        * and with a highest index so it appears on top.
        */
        public function addLayer(layer:ILayer):void
        {
            var layerStage3D:ILayerStage3D = layer as ILayerStage3D;
            var index:int = layers.indexOf(layer);
            if(index == -1)
            {
                addChild(layerStage3D.content);
                layers.push(layer);
            }
            else if(index != layers.length - 1)
            {
                setChildIndex(layerStage3D.content, numChildren - 1);
                layers.splice(index, 1);
                layers.push(layer);
            }
        }
        
        /**
        * A method for removing a layer.
        */
        public function removeLayer(layer:ILayer):void
        {
            var layerStage3D:ILayerStage3D = layer as ILayerStage3D;
            removeChild(layerStage3D.content);
            
            var index:int = layers.indexOf(layer);
            layers.splice(index, 1);
        }
    }
}