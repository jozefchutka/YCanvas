package sk.yoz.ycanvas.utils
{
    import starling.utils.VertexData;

    public class StrokeUtils
    {
        /**
        * Converts points and thickness into vertex data.
        */
        public static function pointsToVertexData(points:Vector.<Number>,
            thickness:Number):VertexData
        {
            var vertices:Vector.<Number> = pointsToVertices(points, thickness);
            var result:VertexData = new VertexData(vertices.length / 2);
            var length:uint = vertices.length;
            for(var i:uint = 0, p:uint = 0; i < length; i += 4, p += 2)
            {
                var i1:uint = i + 1;
                var i2:uint = i + 2;
                var i3:uint = i + 3;
                result.setPosition(p, vertices[i], vertices[i1]);
                result.setPosition(p + 1, vertices[i2], vertices[i3]);
            }
            
            return result;
        }
        
        /**
        * Creates index data for properly ordered vertex data.
        */
        public static function vertexDataToIndexData(
            vertexData:VertexData):Vector.<uint>
        {
            var result:Vector.<uint> = new Vector.<uint>;
            var length:uint = vertexData.numVertices - 2;
            for(var i:uint = 0; i < length; i++)
                result.push(i, i + 1, i + 2);
            return result;
        }
        
        /**
        * Converts points and thickness into vertex coordinates.
        */
        private static function pointsToVertices(points:Vector.<Number>,
            thickness:Number):Vector.<Number>
        {
            var p0x:Number = points[0], p0y:Number = points[1];
            var xi:uint = 2, yi:uint = 3;
            var t2:Number = thickness / 2;
            var result:Vector.<Number> = new Vector.<Number>;
            
            for(var length:uint = points.length; xi < length; xi += 2, yi += 2)
            {
                var override:Boolean = false;
                var p1x:Number = points[xi], p1y:Number = points[yi];
                var rotation:Number = Math.atan2(p1y - p0y, p1x - p0x);
                var dx:Number = Math.sin(rotation) * t2;
                var dy:Number = Math.cos(rotation) * t2;
                var v0x:Number = p0x + dx, v0y:Number = p0y - dy;
                var v1x:Number = p0x - dx, v1y:Number = p0y + dy;
                
                if(v0x == v2x && v0y == v2y && v1x == v3x && v1y == v3y)
                    override = true;
                
                var v2x:Number = p1x + dx, v2y:Number = p1y - dy;
                var v3x:Number = p1x - dx, v3y:Number = p1y + dy;
                
                if(override)
                {
                    result.splice(result.length - 4, 4);
                    result.push(v2x, v2y, v3x, v3y);
                }
                else
                {
                    result.push(v0x, v0y, v1x, v1y, v2x, v2y, v3x, v3y);
                }
                
                p0x = p1x, p0y = p1y;
            }
            
            return result;
        }
    }
}