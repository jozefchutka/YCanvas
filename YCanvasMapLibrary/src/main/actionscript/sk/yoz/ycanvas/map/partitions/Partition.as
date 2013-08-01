package sk.yoz.ycanvas.map.partitions
{
    import com.greensock.TweenMax;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.IBitmapDrawable;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.geom.Matrix;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    import sk.yoz.net.URLRequestBuffer;
    import sk.yoz.net.URLRequestBufferItem;
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.map.events.PartitionEvent;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    import sk.yoz.ycanvas.starling.interfaces.IPartitionStarling;
    
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.textures.Texture;
    
    /**
    * An implementation of YCanvas partition (map tile).
    */
    public class Partition implements IPartitionStarling
    {
        private static var EMPTY_TEXTURE:Texture;
        
        private var _x:int;
        private var _y:int;
        private var _layer:ILayer;
        private var _config:MapConfig;
        private var _content:Image;
        private var _bitmapData:BitmapData;
        
        private var dispatcher:IEventDispatcher;
        private var buffer:URLRequestBuffer;
        private var error:Boolean;
        private var loader:Loader;
        private var tweener:TweenMax;
        
        public function Partition(x:int, y:int, layer:ILayer, config:MapConfig,
            dispatcher:IEventDispatcher, buffer:URLRequestBuffer)
        {
            _x = x;
            _y = y;
            _layer = layer;
            _config = config;
            this.dispatcher = dispatcher;
            this.buffer = buffer;
            
            validateEmptyTexture();
            
            _content = new Image(EMPTY_TEXTURE);
            content.touchable = false;
            content.x = x;
            content.y = y;
            content.alpha = 0;
        }
        
        /**
        * Returns main content (Image).
        */
        public function get content():starling.display.DisplayObject
        {
            return _content;
        }
        
        /**
        * Returns partition x coordinate.
        */
        public function get x():int
        {
            return _x;
        }
        
        /**
        * Returns partition y coordinate.
        */
        public function get y():int
        {
            return _y;
        }
        
        /**
        * Returns expected width of the partition.
        */
        public function get expectedWidth():uint
        {
            return config.tileWidth;
        }
        
        /**
        * Returns expected height of the partition.
        */
        public function get expectedHeight():uint
        {
            return config.tileHeight;
        }
        
        /**
        * Creates a matrix that represents the transformation of the partition
        * in stage coordinate system.
        */
        public function get concatenatedMatrix():Matrix
        {
            return content.getTransformationMatrix(content.stage);
        }
        
        /**
        * Returns true if partition is being loded.
        */
        public function get loading():Boolean
        {
            return loader != null;
        }
        
        /**
        * Returns true if partition has been properly loaded.
        */
        public function get loaded():Boolean
        {
            return bitmapData || error;
        }
        
        /**
        * Returns reference to a layer this partition is available in.
        */
        public function get layer():ILayer
        {
            return _layer;
        }
        
        /**
        * Returns url of partition to load based on map config template.
        */
        private function get url():String
        {
            var templates:Vector.<String> = config.urlTemplates;
            var url:String = templates[Math.abs(x + y) % templates.length];
            url = url.replace("${x}", x / expectedWidth / layer.level);
            url = url.replace("${y}", y / expectedHeight / layer.level);
            url = url.replace("${z}", 18 - getLevel(layer.level));
            return url;
        }   
        
        /**
        * Redefines map config.
        */
        public function set config(value:MapConfig):void
        {
            if(config == value)
                return;
            
            _config = value;
            load();
        }
        
        public function get config():MapConfig
        {
            return _config;
        }
        
        /**
        * Updates the partition BitmapData/Texture.
        */
        private function set bitmapData(value:BitmapData):void
        {
            if(bitmapData == value)
                return;
            
            disposeBitmapData();
            disposeTexture();
            _bitmapData = value;
            try
            {
                var texture:Texture = bitmapData 
                    ? Texture.fromBitmapData(bitmapData, false) : EMPTY_TEXTURE;
                _content.texture = texture;
                _content.readjustSize();
            }
            catch(error:Error)
            {
                // we are here because context has been disposed
                // (system logout/screensaver)
            }
        }
        
        private function get bitmapData():BitmapData
        {
            return _bitmapData;
        }
        
        /**
        * Converts YCanvas layer level to power of two factor.
        * (1..1, 2..2, 4..3, 8..4)
        */
        public function getLevel(value:uint):uint
        {
            var i:uint = 0;
            while(value > 1)
            {
                value /= 2;
                i++;
            }
            return i;
        }
        
        /**
        * Loads the content of the partition.
        */
        public function load():void
        {
            stopLoading();
            error = false;
            
            loader = new Loader;
            var request:URLRequest = new URLRequest(url);
            var context:LoaderContext = new LoaderContext(true);
            buffer.push(loader, request, context);
            
            var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
            loaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
            loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
        }
        
        /**
        * Cancels loading.
        */
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
                bufferItem && buffer.removeActiveById(bufferItem.id);
                
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
                loaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
                loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
            }
            loader = null;
        }
        
        /**
        * Applies any IBitmapDrawable into partition.
        */
        public function applyIBitmapDrawable(source:IBitmapDrawable, 
            matrix:Matrix):void
        {
        }
        
        /**
        * Disposes the partition.
        */
        public function dispose():void
        {
            stopLoading(true);
            if(tweener)
                tweener.kill();
            tweener = null;
            
            disposeBitmapData();
            disposeTexture();
            content.dispose();
        }
        
        /**
        * Disposes partition BitmapData.
        */
        private function disposeBitmapData():void
        {
            if(!bitmapData)
                return;
            
            bitmapData.dispose();
            _bitmapData = null;
        }
        
        /**
        * Disposes partition Texture.
        */
        private function disposeTexture():void
        {
            if(!content || !_content.texture 
                || _content.texture == EMPTY_TEXTURE)
                return;
            
            try
            {
                _content.texture.base.dispose();
            }
            catch(error:Error){}
            
            _content.texture.dispose();
        }
        
        /**
        * Validates empty texture.
        */
        private function validateEmptyTexture():void
        {
            if(EMPTY_TEXTURE)
                return;
            
            var bitmapData:BitmapData = new BitmapData(
                expectedWidth, expectedHeight, true, 0xffffff);
            EMPTY_TEXTURE = Texture.fromBitmapData(bitmapData);
        }
        
        /**
        * Returns a string interpretation of the partition.
        */
        public function toString():String
        {
            return "Partition: [x:" + x + ", y:" + y + "]";
        }
        
        /**
        * Listener for loader complete.
        */
        private function onLoaderComplete(event:Event):void
        {
            var loaderInfo:LoaderInfo = LoaderInfo(event.target);
            bitmapData = Bitmap(loaderInfo.content).bitmapData;
            stopLoading(false);
            tweener = TweenMax.to(content, .5, {alpha:1});
            
            var type:String = PartitionEvent.LOADED;
            dispatcher.dispatchEvent(new PartitionEvent(type, this));
        }
        
        /**
        * Listener for loader error.
        */
        private function onLoaderError(event:Event):void
        {
            error = true;
            bitmapData = null;
            stopLoading();
        }
    }
}