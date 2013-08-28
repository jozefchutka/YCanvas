// Copyright (c) 2013, Vladimir Agafonkin
// Simplify.js is a high-performance JS polyline simplification library
// mourner.github.io/simplify-js

package sk.yoz.utils
{
    /**
    * PathSimplify is a tiny high-performance 2D polyline simplification 
    * library originaly written by Vladimir Agafonkin, extracted from Leaflet,
    * a JS interactive maps library of the same author. It uses a combination
    * of Douglas-Peucker and Radial Distance algorithms.
    */
    public class PathSimplify
    {
        /**
        * Returns square distance from a point to a segment.
        */ 
        public static function getSquareSegmentDistance(px:Number, py:Number,
            p1x:Number, p1y:Number, p2x:Number, p2y:Number):Number
        {
            var x:Number = p1x;
            var y:Number = p1y;
            var dx:Number = p2x - x;
            var dy:Number = p2y - y;
            
            if (dx !== 0 || dy !== 0)
            {
                var t:Number = ((px - x) * dx + (py - y) * dy) / (dx * dx + dy * dy);
                if (t > 1)
                {
                    x = p2x;
                    y = p2y;
                }
                else if (t > 0)
                {
                    x += dx * t;
                    y += dy * t;
                }
            }
            
            dx = px - x;
            dy = py - y;
            return dx * dx + dy * dy;
        }
        
        /**
        * The rest of the code doesn't care for the point format
        * basic distance-based simplification
        */
        public static function simplifyRadialDistance(points:Vector.<Number>,
            sqTolerance:Number):Vector.<Number>
        {
            var prevPointX:Number = points[0];
            var prevPointY:Number = points[1];
            var newPoints:Vector.<Number> = Vector.<Number>([prevPointX, prevPointY]);
            var pointX:Number, pointY:Number;
            
            for(var i:uint = 2, j:uint = 3, len:uint = points.length; i < len; i += 2, j += 2)
            {
                pointX = points[i];
                pointY = points[j];
                
                
                var dx:Number = pointX - prevPointX;
                var dy:Number = pointY - prevPointY;
                if(dx * dx + dy * dy > sqTolerance)
                {
                    newPoints.push(pointX, pointY);
                    prevPointX = pointX;
                    prevPointY = pointY;
                }
            }
            
            if(prevPointX != pointX || prevPointY != pointY)
                newPoints.push(pointX, pointY);
            
            return newPoints;
        }
        
        /**
        * Simplification using optimized Douglas-Peucker algorithm with 
        * recursion elimination.
        */
        public static function simplifyDouglasPeucker(points:Vector.<Number>,
            sqTolerance:Number):Vector.<Number>
        {
            var len:uint = points.length;
            var markers:Vector.<Boolean> = new Vector.<Boolean>(len);
            var first:uint = 0;
            var last:uint = len - 2;
            var i:uint;
            var maxSqDist:Number;
            var sqDist:Number;
            var index:uint;
            var firstStack:Vector.<uint> = new Vector.<uint>;
            var lastStack:Vector.<uint> = new Vector.<uint>;
            var newPoints:Vector.<Number> = new Vector.<Number>;
            
            markers[first] = markers[last] = true;
            
            while(true)
            {
                maxSqDist = 0;
                
                for(i = first + 2; i < last; i += 2)
                {
                    sqDist = getSquareSegmentDistance(
                        points[i], points[uint(i + 1)],
                        points[first], points[uint(first + 1)],
                        points[last], points[uint(last + 1)]);
                    if(sqDist > maxSqDist)
                    {
                        index = i;
                        maxSqDist = sqDist;
                    }
                }
                
                if(maxSqDist > sqTolerance)
                {
                    markers[index] = true;
                    firstStack.push(first, index);
                    lastStack.push(index, last);
                }
                
                if(!lastStack.length)
                    break;
                
                first = firstStack.pop();
                last = lastStack.pop();
            }
            
            for(i = 0; i < len; i += 2)
                if(markers[i])
                    newPoints.push(points[i], points[uint(i + 1)]);
            
            return newPoints;
        }
        
        /**
        * Both algorithms combined for awesome performance.
        */
        public static function simplify(points:Vector.<Number>, 
            tolerance:Number = 1, highestQuality:Boolean = false):Vector.<Number>
        {
            var sqTolerance:Number = tolerance * tolerance;
            if(!highestQuality)
                points = simplifyRadialDistance(points, sqTolerance);
            return simplifyDouglasPeucker(points, sqTolerance);
        }
    }
}