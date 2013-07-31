package sk.yoz.ycanvas.map.events
{
    import flash.events.Event;
    
    /**
    * A dummy event class with basic canvas events.
    */
    public class CanvasEvent extends Event
    {
        public static const TRANSFORMATION_STARTED:String = "canvasTransformationStarted";
        public static const TRANSFORMATION_FINISHED:String = "canvasTransformationFinished";
        
        public static const CENTER_CHANGED:String = "canvasCenterChanged";
        public static const SCALE_CHANGED:String = "canvasScaleChanged";
        public static const ROTATION_CHANGED:String = "canvasRotationChanged";
        
        public static const RENDERED:String = "canvasRendered";
        
        public function CanvasEvent(type:String)
        {
            super(type, false, true);
        }
        
        override public function clone():Event
        {
            return new CanvasEvent(type);
        }
    }
}