package sk.yoz.ycanvas.stage3D.interfaces
{
    import sk.yoz.ycanvas.interfaces.IPartition;
    
    import starling.display.DisplayObject;
    
    /**
    * A stage3D partition interface.
    */
    public interface IPartitionStage3D extends IPartition
    {
        /**
        * A content holder based on starling.display.DisplayObject.
        */
        function get content():DisplayObject
    }
}