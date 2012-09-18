package sk.yoz.ycanvas.demo.markers.events
{
    import flash.events.Event;
    
    public class CanvasEvent extends Event
    {
        public static const TRANSFORMATION_STARTED:String = "canvasTransformationStarted";
        public static const TRANSFORMATION_FINISHED:String = "canvasTransformationFinished";
        
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