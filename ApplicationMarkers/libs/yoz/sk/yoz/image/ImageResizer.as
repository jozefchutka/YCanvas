package sk.yoz.image
{
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import sk.yoz.math.ResizeMath;
    
    public class ImageResizer extends Object
    {
        public function ImageResizer()
        {
        }
        
        public static function bilinear(source:BitmapData, width:uint, 
            height:uint, method:String, allowEnlarging:Boolean=true):BitmapData
        {
            var scale:Point = ResizeMath.scale(
                new Point(source.width, source.height), 
                new Point(width, height), method, allowEnlarging);
            var result:BitmapData = new BitmapData(width, height, true, 0x0);
            var matrix:Matrix = new Matrix();
            matrix.scale(scale.x, scale.y);
            matrix.tx = (width - source.width * scale.x) / 2;
            matrix.ty = (height - source.height * scale.y) / 2;
            result.draw(source, matrix, null, null, null, true);
            return result;
        }
        
        public static function bilinearIterative(source:BitmapData, width:uint, 
            height:uint, method:String, allowEnlarging:Boolean = true,
            iterationMultiplier:Number = 2):BitmapData
        {
            var w:uint = source.width;
            var h:uint = source.height;
            var result:BitmapData;
            while(!result || w != width || h != height)
            {
                w = source.width > width 
                    ? Math.max(w / iterationMultiplier, width) 
                    : Math.min(w * iterationMultiplier, width);
                h = source.height > height 
                    ? Math.max(h / iterationMultiplier, height) 
                    : Math.min(h * iterationMultiplier, height);
                result = bilinear(result || source, w, h, method, 
                    allowEnlarging);
            }
            return result;
        }
    }
}