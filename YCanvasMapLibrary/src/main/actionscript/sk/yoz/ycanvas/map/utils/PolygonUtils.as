/*
* Inspired by:
* http://wiki.unity3d.com/index.php?title=Triangulator
*/

package sk.yoz.ycanvas.map.utils
{
    import flash.geom.Rectangle;
    
    import starling.utils.VertexData;

    public class PolygonUtils
    {
        public static function triangulate(points:Vector.<Number>):Vector.<uint>
        {
            return new PolygonUtilsTriangulator(points).triangulate();
        }
        
        public static function pointsToVertexData(points:Vector.<Number>):VertexData
        {
            var pointsCount:uint = points.length / 2;
            var result:VertexData = new VertexData(pointsCount);
            for(var i:uint = 0; i < pointsCount; i++)
            {
                var xi:uint = i * 2;
                var yi:uint = i * 2 + 1;
                result.setPosition(i, points[xi], points[yi]);
            }
            return result;
        }
        
        public static function getRectangle(points:Vector.<Number>):Rectangle
        {
            var minX:Number = points[0];
            var maxX:Number = points[0];
            var minY:Number = points[1];
            var maxY:Number = points[1];
            for(var i:uint = 0, length:uint = points.length / 2; i < length; i++)
            {
                var x:Number = points[i * 2];
                var y:Number = points[i * 2 + 1];
                if(x < minX)
                    minX = x;
                if(x > maxX)
                    maxX = x;
                if(y < minY)
                    minY = y;
                if(y > maxY)
                    maxY = y;
            }
            return new Rectangle(minX, minY, maxX - minX, maxY - minY);
        }
    }
}

import sk.yoz.math.FastCollisions;

class PolygonUtilsTriangulator
{
    private var points:Vector.<Number>;
    private var pointsCount:uint;
    
    public function PolygonUtilsTriangulator(points:Vector.<Number>)
    {
        this.points = points;
        pointsCount = points.length / 2;
    }
    
    public function triangulate():Vector.<uint>
    {
        var indices:Vector.<uint> = new Vector.<uint>();
        if(pointsCount < 3)
            return indices;
        
        var V:Vector.<uint> = new Vector.<uint>;
        var v:uint;
        if(area() > 0) 
            for(v = 0; v < pointsCount; v++)
                V[v] = v;
        else
            for(v = 0; v < pointsCount; v++)
                V[v] = (pointsCount - 1) - v;
        
        var nv:uint = pointsCount;
        var count:uint = 2 * nv;
        var m:uint = 0;
        for(v = nv - 1; nv > 2;)
        {
            if(count-- <= 0)
                return indices;
            
            var u:uint = v;
            if(nv <= u)
                u = 0;
            v = u + 1;
            if(nv <= v)
                v = 0;
            var w:uint = v + 1;
            if(nv <= w)
                w = 0;
            
            if(snip(u, v, w, nv, V))
            {
                indices.push(V[u], V[v], V[w]);
                m++;
                var s:uint = v;
                for (var t:uint = v + 1; t < nv; t++)
                {
                    V[s] = V[t];
                    s++;
                }
                nv--;
                count = 2 * nv;
            }
        }
        
        return indices;
    }
    
    private function area():Number
    {
        var A:Number = 0;
        var q:uint = 0;
        for (var p:uint = pointsCount - 1; q < pointsCount; p = q++)
        {
            var i:uint = p * 2;
            var px:Number = points[i];
            
            i++;
            var py:Number = points[i];
            
            i = q * 2;
            var qx:Number = points[i];
            
            i++;
            var qy:Number = points[i];
            A += px * qy - qx * py;
        }
        return A * 0.5;
    }
    
    private function snip(u:uint, v:uint, w:uint, n:uint, V:Vector.<uint>):Boolean
    {
        var i:uint = V[u] * 2;
        var ax:Number = points[i];
        i++;
        var ay:Number = points[i];
        
        i = V[v] * 2;
        var bx:Number = points[i];
        
        i++;
        var by:Number = points[i];
        
        i = V[w] * 2;
        var cx:Number = points[i];
        
        i++;
        var cy:Number = points[i];
        
        if((bx - ax) * (cy - ay) < (by - ay) * (cx - ax))
            return false;
        
        for(var p:uint = 0; p < n; p++)
        {
            if(p == u || p == v || p == w)
                continue;
            
            i = V[p] * 2;
            var px:Number = points[i];
            
            i++;
            var py:Number = points[i];
            if(FastCollisions.pointInTriangle(px, py, ax, ay, bx, by, cx, cy))
                return false;
        }
        return true;
    }
}