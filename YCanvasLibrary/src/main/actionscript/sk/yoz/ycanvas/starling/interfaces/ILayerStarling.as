package sk.yoz.ycanvas.starling.interfaces
{
    import sk.yoz.ycanvas.interfaces.ILayer;
    
    import starling.display.DisplayObjectContainer;
    
    /**
    * A stage3D layer interface.
    */
    public interface ILayerStarling extends ILayer
    {
        /**
        * A content holder based on starling.display.DisplayObjectContainer.
        */
        function get content():DisplayObjectContainer
    }
}