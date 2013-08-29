package sk.yoz.math
{
    import flash.geom.Point;
    
    public class GeometryMath extends Object
    {
        public static const TO_RADIANS:Number = Math.PI / 180;
        public static const TO_DEGREEES:Number = 180 / Math.PI;
        
        public static function degreesToRadians(degrees:Number):Number
        {
            return degrees * TO_RADIANS;
        }
        
        public static function radiansToDegrees(radians:Number):Number
        {
            return radians * TO_DEGREEES;
        }
        
        public static function isLine(point1:Point, point2:Point, 
            point3:Point, orderSensitive:Boolean = true):Boolean
        {
            var x1:Number = point1.x - point2.x;
            var x2:Number = point2.x - point3.x;
            var y1:Number = point1.y - point2.y;
            var y2:Number = point2.y - point3.y;
            
            if(orderSensitive && ((x1 > 0 && x2 < 0) || (x1 < 0 && x2 > 0) 
                || (y1 < 0 && y2 > 0) || (y1 < 0 && y2 > 0)))
                return false;
            else if(!y2)
                return !y1;
            else if(!x2)
                return !x1;
            else
                return x1 / x2 == y1 / y2;
        }
        
        public static function rotatePoint(source:Point, lock:Point, 
            degrees:Number):Point
        {
            return rotatePointByRadians(source, lock, degrees * TO_RADIANS);
        }
        
        public static function rotatePointByRadians(source:Point, lock:Point, 
            radians:Number):Point
        {
            var dx:Number = source.x - lock.x;
            var dy:Number = source.y - lock.y;
            var distance:Number = Math.sqrt(dx * dx + dy * dy);
            var rad:Number = radians + Math.atan2(dx, -dy);
            return new Point(
                Math.sin(rad) * distance + lock.x, 
                -Math.cos(rad) * distance + lock.y);
        }
        
        public static function angleOf3Points(cx:Number, cy:Number, 
            p0x:Number, p0y:Number, p1x:Number, p1y:Number):Number
        {
            var a:Number = Math.sqrt((cx - p0x) * (cx - p0x) + (cy - p0y) * (cy - p0y));
            var b:Number = Math.sqrt((p0x - p1x) * (p0x - p1x) + (p0y - p1y) * (p0y - p1y));
            var c:Number = Math.sqrt((p1x - cx) * (p1x - cx) + (p1y - cy) * (p1y - cy));
            return Math.acos(((a * a) + (c * c) - (b * b)) / (2 * a * c));
        }
    }
}