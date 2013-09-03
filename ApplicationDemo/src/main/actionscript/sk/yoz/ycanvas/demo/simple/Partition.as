package sk.yoz.ycanvas.demo.simple
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.IBitmapDrawable;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.geom.Matrix;
    import flash.net.URLRequest;
    import flash.system.ImageDecodingPolicy;
    import flash.system.LoaderContext;
    
    import sk.yoz.ycanvas.interfaces.ILayer;
    import sk.yoz.ycanvas.starling.interfaces.IPartitionStarling;
    
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.textures.Texture;
    
    public class Partition implements IPartitionStarling
    {
        private var _x:int;
        private var _y:int;
        private var _content:starling.display.DisplayObject;
        private var _layer:ILayer;
        
        private var bitmapData:BitmapData;
        private var error:Boolean;
        private var loader:Loader;
        
        public function Partition(layer:ILayer, x:int, y:int)
        {
            _layer = layer;
            _x = x;
            _y = y;
            
            _content = new Image(Texture.fromBitmapData(new BitmapData(256, 256, true, 0x0)));
            content.x = x;
            content.y = y;
        }
        
        public function get content():starling.display.DisplayObject
        {
            return _content;
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
            return 256;
        }
        
        public function get expectedHeight():uint
        {
            return 256;
        }
        
        public function get concatenatedMatrix():Matrix
        {
            return content.getTransformationMatrix(content.stage);;
        }
        
        public function get loading():Boolean
        {
            return loader != null;
        }
        
        public function get loaded():Boolean
        {
            return bitmapData || error;
        }
        
        private function get layer():ILayer
        {
            return _layer;
        }
        
        private function get url():String
        {
            var level:uint = 18 - getPow(layer.level);
            var x:int = this.x / expectedWidth / layer.level;
            var y:int = this.y / expectedHeight / layer.level;
            var server:String = getServer(Math.abs(x + y) % 3);
            var result:String = "http://" + server + ".tile.openstreetmap.org/" 
                + level + "/" + x + "/" + y + ".png";
            return result;
        }
        
        public function load():void
        {
            var context:LoaderContext = new LoaderContext(true);
            context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
            
            loader = new Loader;
            loader.load(new URLRequest(url), context);
            
            var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
            loaderInfo.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
            loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
        }
        
        public function stopLoading():void
        {
            if(!loading)
                return;
            
            try
            {
                loader.close();
            }
            catch(error:Error){}
            
            var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
            if(loaderInfo)
            {
                loaderInfo.removeEventListener(Event.COMPLETE, onComplete, false);
                loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError, false);
            }
            
            loader = null;
        }
        
        public function applyIBitmapDrawable(source:IBitmapDrawable, 
            matrix:Matrix):void
        {
        }
        
        public function toString():String
        {
            return "Partition: [x:" + x + ", y:" + y + "]";
        }
        
        public function dispose():void
        {
            stopLoading();
            bitmapData && bitmapData.dispose();
            bitmapData = null;
            if(content)
            {
                Image(content).texture.base.dispose();
                Image(content).texture.dispose();
                content.dispose();
            }
        }
        
        private function getPow(value:uint):uint
        {
            var i:uint = 0;
            while(value > 1)
            {
                value /= 2;
                i++;
            }
            return i;
        }
        
        private function getServer(value:uint):String
        {
            if(value == 1)
                return "a";
            if(value == 2)
                return "b";
            return "c";
        }
        
        private function onComplete(event:Event):void
        {
            var loaderInfo:LoaderInfo = LoaderInfo(event.target);
            bitmapData = Bitmap(loaderInfo.content).bitmapData;
			(content as Image).texture.base.dispose();
			(content as Image).texture.dispose();
    		(content as Image).texture = Texture.fromBitmapData(bitmapData);
            stopLoading();
        }
        
        private function onError(event:Event):void
        {
            error = true;
            stopLoading();
        }
    }
}