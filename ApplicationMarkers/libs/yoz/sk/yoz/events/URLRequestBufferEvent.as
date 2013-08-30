package sk.yoz.events
{
    import flash.events.Event;
    
    import sk.yoz.net.URLRequestBufferItem;
    
    public class URLRequestBufferEvent extends Event
    {
        public static const REQUEST_TIMEOUT:String = 
            "URLRequestBufferEventREQUEST_TIMEOUT";
        public static const WAITING_REQUEST_ADDED:String =
            "URLRequestBufferEventWAITING_REQUEST_ADDED";
        public static const WAITING_REQUEST_REMOVED:String = 
            "URLRequestBufferEventWAITING_REQUEST_REMOVED";
        public static const ACTIVE_REQUEST_ADDED:String = 
            "URLRequestBufferEventACTIVE_REQUEST_ADDED";
        public static const ACTIVE_REQUEST_REMOVED:String =
            "URLRequestBufferEventACTIVE_REQUEST_REMOVED";
        
        private var _item:URLRequestBufferItem;
        
        public function URLRequestBufferEvent(
            type:String, bubbles:Boolean=false, cancelable:Boolean=false, 
            item:URLRequestBufferItem=null):void
        {
            super(type, bubbles, cancelable);
            _item = item;
        }
        
        public function get item():URLRequestBufferItem
        {
            return _item;
        }
        
        override public function clone():Event
        {
            return new URLRequestBufferEvent(type, bubbles, cancelable, item);
        }
    }
}