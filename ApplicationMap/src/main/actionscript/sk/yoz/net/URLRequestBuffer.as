package sk.yoz.net
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.setTimeout;
    
    import __AS3__.vec.Vector;
    
    import sk.yoz.events.URLRequestBufferEvent;
    
    [Event(name="URLRequestBufferRequestTimeout",type="sk.yoz.events.URLRequestBufferEvent")]
    [Event(name="URLRequestBufferWaitingRequestAdded",type="sk.yoz.events.URLRequestBufferEvent")]
    [Event(name="URLRequestBufferWaitingRequestRemoved",type="sk.yoz.events.URLRequestBufferEvent")]
    [Event(name="URLRequestBufferActiveRequestAdded",type="sk.yoz.events.URLRequestBufferEvent")]
    [Event(name="URLRequestBufferActiveRequestRemoved",type="sk.yoz.events.URLRequestBufferEvent")]
    
    public class URLRequestBuffer extends EventDispatcher
    {
        private var maxRequests:uint = 2;
        private var timeout:uint;
        
        private var waitingList:Vector.<URLRequestBufferItem> = 
            new Vector.<URLRequestBufferItem>();
        private var activeList:Vector.<URLRequestBufferItem> = 
            new Vector.<URLRequestBufferItem>();
        private var nextID:uint = 0;
        
        public function URLRequestBuffer(maxRequests:uint, timeout:uint=3000)
        {
            super();
            this.maxRequests = Math.max(1, maxRequests);
            this.timeout = timeout;
        }
        
        public function push(loader:EventDispatcher, request:URLRequest, 
            context:LoaderContext = null, priority:uint = 0, delay:uint = 0)
            :URLRequestBufferItem
        {
            nextID++;
            var index:uint = getIndexForPriority(priority);
            var item:URLRequestBufferItem = new URLRequestBufferItem(
                this, nextID, loader, request, context, priority, delay)
            waitingList.splice(index, 0, item);
            
            var type:String = URLRequestBufferEvent.WAITING_REQUEST_ADDED;
            dispatchEvent(new URLRequestBufferEvent(type, false, false, item));
            
            loadNext();
            return item;
        }
        
        public function get countWaiting():uint
        {
            return waitingList.length;
        }
        
        public function get countActive():uint
        {
            return activeList.length;
        }
        
        public function getWaitingItem(index:uint):URLRequestBufferItem
        {
            return waitingList[index];
        }
        
        public function getActiveItem(index:uint):URLRequestBufferItem
        {
            return activeList[index];
        }
        
        protected function getIndexForPriority(priority:uint):uint
        {
            var length:uint = countWaiting;
            for(var i:uint = 0; i < length; i++)
                if(priority > waitingList[i].priority)
                    return i;
            return length;
        }
        
        protected function get firstWaitingReadyItem():URLRequestBufferItem
        {
            var item:URLRequestBufferItem;
            var length:uint = countWaiting;
            for(var i:uint = 0; i < length; i++)
            {
                item = waitingList[i];
                if(item.ready)
                    return item;
            }
            return null;
        }
        
        public function loadNext():void
        {
            if(countActive >= maxRequests || !countWaiting)
                return;
            var item:URLRequestBufferItem = firstWaitingReadyItem;
            if(!item)
                return;
            
            removeWaitingById(item.id);
            createListeners(item.dispatcher);
            item.load();
            activeList.push(item);
            
            setTimeout(onTimeout, timeout, item.id);
            
            var type:String = URLRequestBufferEvent.ACTIVE_REQUEST_ADDED;
            dispatchEvent(new URLRequestBufferEvent(type, false, false, item));
            loadNext();
        }
        
        protected function createListeners(dispatcher:EventDispatcher):void
        {
            dispatcher.addEventListener(Event.COMPLETE, onComplete);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
        }
        
        protected function removeListeners(dispatcher:EventDispatcher):void
        {
            dispatcher.removeEventListener(Event.COMPLETE, onComplete);
            dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
        }
        
        protected function onComplete(event:Event):void
        {
            var loader:EventDispatcher = URLRequestBufferItem.getLoader(event);
            var item:URLRequestBufferItem = getActiveByLoader(loader);
            if(item)
                removeActiveById(item.id);
            loadNext();
        }
        
        protected function onIOError(event:IOErrorEvent):void
        {
            var loader:EventDispatcher = URLRequestBufferItem.getLoader(event);
            var item:URLRequestBufferItem = getActiveByLoader(loader);
            if(item)
                removeActiveById(item.id);
            loadNext();
        }
        
        protected function onTimeout(id:uint):void
        {
            var item:URLRequestBufferItem = getActiveById(id);
            if(!item)
                return;
            
            removeActiveById(id);
            var type:String = URLRequestBufferEvent.REQUEST_TIMEOUT;
            dispatchEvent(new URLRequestBufferEvent(type, false, false, item));
        }
        
        public function getWaitingById(id:uint):URLRequestBufferItem
        {
            var length:uint = countWaiting;
            for(var i:uint = 0; i < length; i++)
                if(waitingList[i].id == id)
                    return waitingList[i];
            return null;
        }
        
        public function getWaitingByLoader(loader:EventDispatcher)
            :URLRequestBufferItem
        {
            var length:uint = countWaiting;
            for(var i:uint = 0; i < length; i++)
                if(waitingList[i].loader == loader)
                    return waitingList[i];
            return null;
        }
        
        public function removeWaitingById(id:uint):URLRequestBufferItem
        {
            var item:URLRequestBufferItem = getWaitingById(id);
            if(!item)
                return null;
            
            waitingList.splice(waitingList.indexOf(item), 1);
            
            var type:String = URLRequestBufferEvent.WAITING_REQUEST_REMOVED;
            dispatchEvent(new URLRequestBufferEvent(type, false, false, item));
            
            return item;
        }
        
        public function getActiveById(id:uint):URLRequestBufferItem
        {
            var length:uint = countActive;
            for(var i:uint = 0; i < length; i++)
                if(activeList[i].id == id)
                    return activeList[i];
            return null;
        }
        
        public function getActiveByLoader(loader:EventDispatcher):URLRequestBufferItem
        {
            var length:uint = countActive;
            for(var i:uint = 0; i < length; i++)
                if(activeList[i].loader == loader)
                    return activeList[i];
            return null;
        }
        
        public function removeActiveById(id:uint):URLRequestBufferItem
        {
            var item:URLRequestBufferItem = getActiveById(id);
            if(!item)
                return null;
            
            removeListeners(item.dispatcher);
            item.close();
            activeList.splice(activeList.indexOf(item), 1);
            
            var type:String = URLRequestBufferEvent.ACTIVE_REQUEST_REMOVED;
            dispatchEvent(new URLRequestBufferEvent(type, false, false, item));
            
            loadNext();
            return item;
        }
    }
}