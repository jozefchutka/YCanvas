package sk.yoz.events
{
    import flash.events.Event;
    
    import sk.yoz.net.URLRequestBufferItem;
    
    public class URLRequestBufferEvent extends Event
    {
        public static const REQUEST_TIMEOUT:String = 
            "URLRequestBufferRequestTimeout";
        public static const WAITING_REQUEST_ADDED:String =
            "URLRequestBufferWaitingRequestAdded";
        public static const WAITING_REQUEST_REMOVED:String = 
            "URLRequestBufferWaitingRequestRemoved";
        public static const ACTIVE_REQUEST_ADDED:String = 
            "URLRequestBufferActiveRequestAdded";
        public static const ACTIVE_REQUEST_REMOVED:String =
            "URLRequestBufferActiveRequestRemoved";
        
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