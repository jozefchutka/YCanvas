package sk.yoz.ycanvas.utils
{
    import flash.geom.Rectangle;
    
    import starling.utils.VertexData;

    public class VertexDataUtils
    {
        /* while native VertexData.getBounds() seems to be broken */
        public static function getBounds(vertexData:VertexData, vertexID:int=0, numVertices:int=-1):Rectangle
        {
            if (numVertices < 0 || vertexID + numVertices > vertexData.numVertices)
                numVertices = vertexData.numVertices - vertexID;
            
            var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
            var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
            var offsetX:int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
            var offestY:int = offsetX + 1;
            for(var i:uint = vertexID, length:uint = numVertices + vertexID; i < length; ++i)
            {
                var x:Number = vertexData.rawData[offsetX];
                var y:Number = vertexData.rawData[offestY];
                offsetX += VertexData.ELEMENTS_PER_VERTEX;
                offestY = offsetX + 1;
                
                if(minX > x)
                    minX = x;
                if(maxX < x)
                    maxX = x;
                if(minY > y)
                    minY = y;
                if(maxY < y)
                    maxY = y;
            }
            
            return new Rectangle(minX, minY, maxX - minX, maxY - minY);
        }
    }
}