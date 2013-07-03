package simplify {
    import flash.geom.Point;
    
    public class Simplify {
        public function Simplify() {
        }
        
        public static function getSquareDistance(p1:Point, p2:Point):Number { // square distance between 2 points
            
            var dx:Number = p1.x - p2.x, dy:Number = p1.y - p2.y;
            return dx * dx + dy * dy;
        }
        
        public static function getSquareSegmentDistance(p:Point, p1:Point, p2:Point):Number { // square distance from a point to a segment
            
            var x:Number = p1.x;
            var y:Number = p1.y;
            var dx:Number = p2.x - x;
            var dy:Number = p2.y - y;
            var t:Number;
            
            if (dx !== 0 || dy !== 0) {
                
                t = ((p.x - x) * dx + (p.y - y) * dy) / (dx * dx + dy * dy);
                
                if (t > 1) {
                    x = p2.x;
                    y = p2.y;
                    
                } else if (t > 0) {
                    x += dx * t;
                    y += dy * t;
                }
            }
            
            dx = p.x - x;
            dy = p.y - y;
            
            return dx * dx + dy * dy;
        }
        
        // the rest of the code doesn't care for the point format
        
        
        public static function simplifyRadialDistance(points:Vector.<Point>, sqTolerance:Number):Vector.<Point> { // distance-based simplification
            
            var i:int;
            var len:int = points.length;
            var point:Point;
            var prevPoint:Point = points[0];
            var newPoints:Vector.<Point> = null;
            newPoints = Vector.<Point>([prevPoint]);
            
            for (i = 1; i < len; i++) {
                point = points[i];
                
                if (getSquareDistance(point, prevPoint) > sqTolerance) {
                    newPoints.push(point);
                    prevPoint = point;
                }
            }
            
            if (prevPoint !== point) {
                newPoints.push(point);
            }
            
            return newPoints;
        }
        
        
        // simplification using optimized Douglas-Peucker algorithm with recursion elimination
        
        public static function simplifyDouglasPeucker(points:Vector.<Point>, sqTolerance:Number):Vector.<Point> {
            
            var len:int = points.length;
            
            var markers:Vector.<int> = null;
            markers = new Vector.<int>(len);
            var first:int = 0;
            var last:int = len - 1;
            
            var i:int;
            var maxSqDist:Number;
            var sqDist:Number;
            var index:int;
            
            var firstStack:Vector.<int> = null;
            firstStack = new Vector.<int>();
            var lastStack:Vector.<int> = null;
            lastStack = new Vector.<int>();
            
            var newPoints:Vector.<Point> = null;
            newPoints = new Vector.<Point>();
            
            markers[first] = markers[last] = 1;
            
            while (last) {
                maxSqDist = 0;
                
                for (i = first + 1; i < last; i++) {
                    sqDist = getSquareSegmentDistance(points[i], points[first], points[last]);
                    
                    if (sqDist > maxSqDist) {
                        index = i;
                        maxSqDist = sqDist;
                    }
                }
                
                if (maxSqDist > sqTolerance) {
                    markers[index] = 1;
                    
                    firstStack.push(first);
                    lastStack.push(index);
                    
                    firstStack.push(index);
                    lastStack.push(last);
                }
                
                first = firstStack.pop();
                last = lastStack.pop();
            }
            
            for (i = 0; i < len; i++) {
                if (markers[i]) {
                    newPoints.push(points[i]);
                }
            }
            
            return newPoints;
        }
        
        public static function simplify(points:Vector.<Point>, tolerance:Number = 1, highestQuality:Boolean =
                                        false):Vector.<Point> {
            
            var sqTolerance:Number = tolerance * tolerance;
            
            if (!highestQuality) {
                points = simplifyRadialDistance(points, sqTolerance);
            }
            points = simplifyDouglasPeucker(points, sqTolerance);
            
            return points;
        }
    }
}
