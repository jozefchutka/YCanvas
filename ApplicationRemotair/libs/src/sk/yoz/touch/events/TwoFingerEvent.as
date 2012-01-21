package sk.yoz.touch.events
{
    import flash.events.Event;
    import flash.events.TouchEvent;
    import flash.geom.Point;
    
    public class TwoFingerEvent extends Event
    {
        public static const SCALE_AND_ROTATE:String = "twoFingerScaleAndRotate";
        
        private var _source:TouchEvent;
        private var _lock:Point;
        private var _scale:Number;
        private var _rotation:Number;
        
        public function TwoFingerEvent(type:String, source:TouchEvent, 
            lock:Point, scale:Number, rotation:Number)
        {
            super(type, false, true);
            
            _source = source;
            _lock = lock;
            _scale = scale;
            _rotation = rotation;
        }
        
        public function get source():TouchEvent
        {
            return _source;
        }
        
        public function get lock():Point
        {
            return _lock;
        }
        
        public function get scale():Number
        {
            return _scale;
        }
        
        public function get rotation():Number
        {
            return _rotation;
        }
        
        override public function clone():Event
        {
            return new TwoFingerEvent(type, source, lock, scale, rotation);
        }
    }
}