package sk.yoz.net
{
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.Dictionary;

    public class LoaderOptimizer
    {
        private var created:Dictionary = new Dictionary(true);
        private var released:Dictionary = new Dictionary(true);
        private var buffer:URLRequestBuffer;
        
        public function LoaderOptimizer(buffer:URLRequestBuffer=null)
        {
            this.buffer = buffer ? buffer : new URLRequestBuffer(6, 15000);
        }
        
        public function load(request:URLRequest, context:LoaderContext):Loader
        {
            var loader:Loader = create();
            buffer.push(loader, request, context);
            return loader;
        }
        
        public function release(loader:Loader):void
        {
            var item:URLRequestBufferItem;
            
            item = buffer.getWaitingByLoader(loader);
            if(item)
                buffer.removeWaitingById(item.id);
            
            item = buffer.getActiveByLoader(loader);
            if(item)
            {
                buffer.removeActiveById(item.id);
            }
            
            /* Lets do not release active loaders. close() might not work as
               expected. */
            else if(released)
            {
                removeLoaderListeners(loader);
                released[loader] = true;
            }
        }
        
        public function dispose():void
        {
            for(var key:Object in created)
            {
                var loader:Loader = key as Loader;
                release(loader);
                removeLoaderListeners(loader);
                loader.unloadAndStop(true);
            }
            
            created = null;
            released = null;
            buffer = null;
        }
        
        private function removeLoaderListeners(loader:Loader):void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete, false);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError, false);
        }
        
        private function addLoaderListeners(loader:Loader):void
        {
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete, false, -10, true);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError, false, -10, true);
        }
        
        private function create():Loader
        {
            var loader:Loader;
            for(var key:Object in released)
            {
                loader = key as Loader;
                delete released[loader];
                break;
            }
            if(!loader)
            {
                loader = new Loader;
                created[loader] = true;
            }
            
            addLoaderListeners(loader);
            return loader;
        }
        
        private function onLoaderComplete(event:Event):void
        {
            release(LoaderInfo(event.target).loader);
        }
        
        private function onLoaderIOError(event:IOErrorEvent):void
        {
            release(LoaderInfo(event.target).loader);
        }
    }
}