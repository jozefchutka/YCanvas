package sk.yoz.ycanvas.demo.explorer.modes
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.geom.Matrix;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    import sk.yoz.events.URLRequestBufferEvent;
    import sk.yoz.net.URLRequestBuffer;
    import sk.yoz.net.URLRequestBufferItem;
    import sk.yoz.ycanvas.demo.explorer.events.PartitionEvent;
    import sk.yoz.ycanvas.stage3D.interfaces.IPartitionStage3D;
    
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.textures.Texture;
    
    public class Partition implements IPartitionStage3D
    {
        protected var bitmapData:BitmapData;
        private static var cachedTexture:Texture;
        
        private var dispatcher:IEventDispatcher;
        private var error:Boolean;
        private var loader:Loader;
        private static const buffer:URLRequestBuffer = new URLRequestBuffer(6, 15000);
        
        private var _x:int;
        private var _y:int;
        private var _content:starling.display.DisplayObject;
        private var _layer:Layer;
        private var _requestedWidth:uint;
        private var _requestedHeight:uint;
        
        public function Partition(layer:Layer, x:int, y:int, 
            requestedWidth:uint, requestedHeight:uint, 
            dispatcher:IEventDispatcher)
        {
            _layer = layer;
            _x = x;
            _y = y;
            _requestedWidth = requestedWidth;
            _requestedHeight = requestedHeight;
            this.dispatcher = dispatcher;
            
            _content = new Image(getTexture(requestedWidth, requestedHeight));
            content.x = x;
            content.y = y;
            
            buffer.addEventListener(URLRequestBufferEvent.REQUEST_TIMEOUT, onRequestTimeout);
        }
        
        public function get x():int
        {
            return _x;
        }
        
        public function get y():int
        {
            return _y;
        }
        
        public function get expectedWidth():uint
        {
            return _requestedWidth;
        }
        
        public function get expectedHeight():uint
        {
            return _requestedHeight;
        }
        
        public function get content():starling.display.DisplayObject
        {
            return _content;
        }
        
        public function get layer():Layer
        {
            return _layer;
        }
        
        public function get loading():Boolean
        {
            return loader != null;
        }
        
        public function get loaded():Boolean
        {
            return bitmapData || error;
        }
        
        public function get concatenatedMatrix():Matrix
        {
            return content.getTransformationMatrix(content.stage);
        }
        
        protected function getTexture(width:uint, height:uint):Texture
        {
            if(cachedTexture && cachedTexture.width == width
                && cachedTexture.height == height)
                return cachedTexture;
            if(cachedTexture)
                cachedTexture.dispose();
            cachedTexture = Texture.fromBitmapData(
                new BitmapData(width, height, true, 0xffffff));
            return cachedTexture;
        }
        
        protected function get url():String
        {
            return null;
        }
        
        protected function set texture(value:BitmapData):void
        {
            if(content)
                Image(content).texture.dispose();
            Image(content).texture = Texture.fromBitmapData(bitmapData);
        }
        
        public function applyDisplayObject(source:flash.display.DisplayObject, 
            matrix:Matrix):void
        {
        }
        
        public function load():void
        {
            stopLoading();
            error = false;
            
            loader = new Loader;
            var request:URLRequest = new URLRequest(url);
            var context:LoaderContext = new LoaderContext(true);
            buffer.push(loader, request);
            
            var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
            loaderInfo.addEventListener(Event.COMPLETE, onComplete);
            loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
        }
        
        public function stopLoading(cancelRequest:Boolean = true):void
        {
            if(!loading)
                return;
            
            if(cancelRequest)
            {
                var bufferItem:URLRequestBufferItem;
                bufferItem = buffer.getWaitingByLoader(loader);
                bufferItem && buffer.removeWaitingById(bufferItem.id);
                bufferItem = buffer.getActiveByLoader(loader);
                bufferItem  && buffer.removeActiveById(bufferItem.id);
                
                try
                {
                    loader.close();
                }
                catch(error:Error){}
                
                try
                {
                    loader.unload();
                }
                catch(error:Error){}
                
            }
            
            var loaderInfo:LoaderInfo = loader.loaderInfo;
            if(loaderInfo)
            {
                loaderInfo.removeEventListener(Event.COMPLETE, onComplete);
                loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
            }
            loader = null;
        }
        
        public function dispose():void
        {
            stopLoading();
            bitmapData && bitmapData.dispose();
            bitmapData = null;
            content && content.removeFromParent(true);
        }
        
        public function toString():String
        {
            return "Partition: [x:" + x + ", y:" + y + ", " +
                "level:" + layer.level + "]";
        }
        
        protected function updateTexture():void
        {
            if(bitmapData)
                texture = bitmapData;
        }
        
        private function onComplete(event:Event):void
        {
            var loaderInfo:LoaderInfo = LoaderInfo(event.target);
            bitmapData = Bitmap(loaderInfo.content).bitmapData;
            updateTexture();
            stopLoading(false);
            
            var type:String = PartitionEvent.LOADED;
            dispatcher.dispatchEvent(new PartitionEvent(type, this));
        }
        
        private function onError(event:Event):void
        {
            error = true;
            updateTexture();
            stopLoading(false);
        }
        
        private function onRequestTimeout(event:URLRequestBufferEvent):void
        {
            stopLoading();
        }
    }
}