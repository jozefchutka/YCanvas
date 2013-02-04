package sk.yoz.ycanvas.stage3D.interfaces
{
    import sk.yoz.ycanvas.interfaces.ILayer;
    
    import starling.display.DisplayObjectContainer;
    
    /**
    * A stage3D layer interface.
    */
    public interface ILayerStage3D extends ILayer
    {
        /**
        * A content holder based on starling.display.DisplayObjectContainer.
        */
        function get content():DisplayObjectContainer
    }
}