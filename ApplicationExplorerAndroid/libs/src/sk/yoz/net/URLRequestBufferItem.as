package sk.yoz.net
{
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.Timer;
    
    public class URLRequestBufferItem extends Object
    {
        public var buffer:URLRequestBuffer;
        public var id:uint;
        public var loader:EventDispatcher;
        public var request:URLRequest;
        public var context:LoaderContext;
        public var priority:uint;
        public var delay:uint;
        
        protected var _ready:Boolean;
        
        public function URLRequestBufferItem(
            buffer:URLRequestBuffer, 
            id:uint, 
            loader:EventDispatcher, 
            request:URLRequest, 
            context:LoaderContext,
            priority:uint, 
            delay:uint = 0):void
        {
            super();
            
            if(!(loader is Loader || loader is URLLoader))
                throw new Error("loader must be instance of Loader or " + 
                        "URLLoader class");
            
            this.buffer = buffer;
            this.id = id;
            this.loader = loader;
            this.request = request;
            this.context = context;
            this.priority = priority;
            this.delay = delay;
            _ready = delay ? false : true;
            
            if(delay)
            {
                var timer:Timer = new Timer(delay, 1);
                timer.addEventListener(TimerEvent.TIMER_COMPLETE, onDelay);
                timer.start();
            }
        }
        
        public function get dispatcher():EventDispatcher
        {
            return loader is Loader 
                ? Loader(loader).contentLoaderInfo 
                : URLLoader(loader);
        }
        
        public function get ready():Boolean
        {
            return _ready;
        }
        
        public function load():void
        {
            if(loader is Loader)
                Loader(loader).load(request, context);
            else
                URLLoader(loader).load(request);
        }
        
        public function close():void
        {
            try
            {
                if(loader is Loader)
                    Loader(loader).close();
                else if(loader is URLLoader)
                    URLLoader(loader).close();
            }
            catch(error:Error){}
        }
        
        protected function onDelay(event:TimerEvent):void
        {
            var timer:Timer = Timer(event.currentTarget);
            var type:String = TimerEvent.TIMER_COMPLETE;
            timer.removeEventListener(type, onDelay);
            _ready = true;
            buffer.loadNext();
        }
        
        public static function getLoader(event:Event):EventDispatcher
        {
            return event.target is LoaderInfo
                ? LoaderInfo(event.target).loader 
                : URLLoader(event.target);
        }
    }
}