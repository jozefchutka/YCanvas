package sk.yoz.ycanvas.map.managers
{
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.Dictionary;
    
    import sk.yoz.net.URLRequestBuffer;
    import sk.yoz.net.URLRequestBufferItem;

    public class LoaderOptimizer
    {
        private var created:Dictionary = new Dictionary(true);
        private var released:Dictionary = new Dictionary(true);
        private var buffer:URLRequestBuffer = new URLRequestBuffer(6, 15000);
        
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
                buffer.removeActiveById(item.id);
            else if(released)
                released[loader] = true;
        }
        
        public function dispose():void
        {
            for(var loader:Loader in created)
            {
                release(loader);
                loader.unloadAndStop(true);
            }
            
            created = null;
            released = null;
        }
        
        private function create():Loader
        {
            for(var loader:Loader in released)
            {
                delete released[loader];
                return loader;
            }
            
            loader = new Loader;
            created[loader] = true;
            return loader;
        }
    }
}