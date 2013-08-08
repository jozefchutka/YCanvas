package sk.yoz.ycanvas.map.utils
{
    import flash.geom.Rectangle;
    
    import sk.yoz.math.FastCollisions;
    
    import starling.utils.VertexData;

    public class PolygonUtils
    {
        /**
        * This algorithm triangulates polygon points and returns an array of
        * indices. Algorithm inspired by:
        * http://wiki.unity3d.com/index.php?title=Triangulator
        */
        public static function triangulate(points:Vector.<Number>):Vector.<uint>
        {
            var pointsCount:uint = points.length / 2;
            var indices:Vector.<uint> = new Vector.<uint>();
            if(pointsCount < 3)
                return indices;
            
            var V:Vector.<uint> = new Vector.<uint>;
            var v:uint;
            if(triangulateArea(points) > 0) 
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
                
                if(triangulateSnip(points, u, v, w, nv, V))
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
        
        private static function triangulateArea(points:Vector.<Number>):Number
        {
            var pointsCount:uint = points.length / 2;
            var A:Number = 0;
            var q:uint = 0;
            for(var p:uint = pointsCount - 1; q < pointsCount; p = q++)
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
        
        private static function triangulateSnip(points:Vector.<Number>, u:uint, 
            v:uint, w:uint, n:uint, V:Vector.<uint>):Boolean
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
        
        /**
        * Converts x, y list to VertexData.
        */
        public static function pointsToVertexData(points:Vector.<Number>):VertexData
        {
            var length:uint = points.length;
            var result:VertexData = new VertexData(length / 2);
            var i:uint = 0;
            for(var xi:uint = 0, yi:uint = 1; xi < length; xi += 2, yi += 2)
                result.setPosition(i++, points[xi], points[yi]);
            return result;
        }
        
        /**
        * Returns x, y list bounds.
        */
        public static function getRectangle(points:Vector.<Number>):Rectangle
        {
            var length:uint = points.length;
            var minX:Number = points[0];
            var maxX:Number = points[0];
            var minY:Number = points[1];
            var maxY:Number = points[1];
            for(var xi:uint = 0, yi:uint = 1; xi < length; xi += 2, yi += 2)
            {
                var x:Number = points[xi];
                if(x < minX)
                    minX = x;
                else if(x > maxX)
                    maxX = x;
                
                var y:Number = points[yi];
                if(y < minY)
                    minY = y;
                else if(y > maxY)
                    maxY = y;
            }
            return new Rectangle(minX, minY, maxX - minX, maxY - minY);
        }
    }
}