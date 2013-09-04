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
    import flash.utils.setTimeout;
    
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
                setTimeout(onDelay, delay);
        }
        
        public function get dispatcher():EventDispatcher
        {
            return loader is Loader 
                ? (loader as Loader).contentLoaderInfo 
                : (loader as URLLoader);
        }
        
        public function get ready():Boolean
        {
            return _ready;
        }
        
        public function load():void
        {
            if(loader is Loader)
                (loader as Loader).load(request, context);
            else if(loader is URLLoader)
                (loader as URLLoader).load(request);
        }
        
        public function close():void
        {
            try
            {
                if(loader is Loader)
                    (loader as Loader).close();
                else if(loader is URLLoader)
                    (loader as URLLoader).close();
            }
            catch(error:Error){}
        }
        
        protected function onDelay(event:TimerEvent):void
        {
            _ready = true;
            buffer.loadNext();
        }
        
        public static function getLoader(event:Event):EventDispatcher
        {
            return event.target is LoaderInfo
                ? (event.target as LoaderInfo).loader 
                : (event.target as URLLoader);
        }
    }
}