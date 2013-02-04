package sk.yoz.ycanvas.valueObjects
{
    import flash.geom.Point;
    
    /**
    * A value object holding 4 x:y value pairs.
    */
    public class MarginPoints
    {
        public var x1:Number;
        public var y1:Number;
        public var x2:Number;
        public var y2:Number;
        public var x3:Number;
        public var y3:Number;
        public var x4:Number;
        public var y4:Number;
        
        public function getMinX():Number
        {
            return Math.min(x1, x2, x3, x4);
        }
        
        public function getMaxX():Number
        {
            return Math.max(x1, x2, x3, x4);
        }
        
        public function getMinY():Number
        {
            return Math.min(y1, y2, y3, y4);
        }
        
        public function getMaxY():Number
        {
            return Math.max(y1, y2, y3, y4);
        }
        
        public static function fromPoints(
            p1:Point, p2:Point, p3:Point, p4:Point):MarginPoints
        {
            var result:MarginPoints = new MarginPoints;
            result.x1 = p1.x;
            result.y1 = p1.y;
            result.x2 = p2.x;
            result.y2 = p2.y;
            result.x3 = p3.x;
            result.y3 = p3.y;
            result.x4 = p4.x;
            result.y4 = p4.y;
            return result;
        }
    }
}