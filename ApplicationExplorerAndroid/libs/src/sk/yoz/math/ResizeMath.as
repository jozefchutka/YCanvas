package sk.yoz.math
{
    import flash.geom.Point;
    
    public class ResizeMath extends Object
    {
        public static const METHOD_PAN_AND_SCAN:String = "panAndScan";
        public static const METHOD_LETTERBOX:String = "letterbox";
        public static const METHOD_RAW:String = "raw";
        
        public function ResizeMath()
        {
        }
        
        public static function fixMethod(method:String):String
        {
            return (method == METHOD_PAN_AND_SCAN || method == METHOD_LETTERBOX)
                ? method : METHOD_RAW;
        }
        
        public static function newDimensions(origDimensions:Point, 
            containerDimensions:Point, method:String, 
            allowEnlarging:Boolean = true):Point
        {
            var s:Point = scale(origDimensions, containerDimensions, method, allowEnlarging);
            return new Point(s.x * origDimensions.x, s.y * origDimensions.y);
        }
        
        public static function scale(origDimensions:Point, 
            containerDimensions:Point, method:String, 
            allowEnlarging:Boolean = true):Point
        {
            var sw:Number = containerDimensions.x / origDimensions.x;
            var sh:Number = containerDimensions.y / origDimensions.y;
            var sx:Number = sw; 
            var sy:Number = sh;
            if(method == METHOD_PAN_AND_SCAN)
                sx = sy = Math.max(sw, sh);
            else if(method == METHOD_LETTERBOX)
                sx = sy = Math.min(sw, sh);
            return new Point((sx > 1 && !allowEnlarging) ? 1 : sx, 
                (sy > 1 && !allowEnlarging) ? 1 : sy);
        }
    }
}