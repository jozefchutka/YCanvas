package sk.yoz.ycanvas.map.partitions
{
    import com.greensock.TweenNano;
    
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
    import flash.system.ImageDecodingPolicy;
    import flash.system.LoaderContext;
    
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.map.events.PartitionEvent;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    import sk.yoz.ycanvas.starling.interfaces.IPartitionStarling;
    
    import starling.display.BlendMode;
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
        private var error:Boolean;
        private var loader:Loader;
        private var tween:TweenNano;
        
        public function Partition(x:int, y:int, layer:ILayer, config:MapConfig,
            dispatcher:IEventDispatcher)
        {
            _x = x;
            _y = y;
            _layer = layer;
            _config = config;
            this.dispatcher = dispatcher;
            
            validateEmptyTexture();
            
            _content = new Image(EMPTY_TEXTURE);
            content.touchable = false;
            content.x = x;
            content.y = y;
            content.alpha = 0;
            
            super();
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
        protected function get url():String
        {
            var templates:Vector.<String> = config.urlTemplates;
            var id:int = x / 5 + y / 3 + layer.level;
            var url:String = templates[(id < 0 ? -id : id) % templates.length];
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
            
            var context:LoaderContext = new LoaderContext(true);
            context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
            
            loader = new Loader;
            loader.load(new URLRequest(url), context);
            
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
            disposeTween();
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
        * Disposees the tween.
        */
        private function disposeTween():void
        {
            if(!tween)
                return;
            
            tween.kill();
            tween = null;
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
            tween = TweenNano.to(content, .5, {alpha:1,
                onComplete:disposeTween});
            
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