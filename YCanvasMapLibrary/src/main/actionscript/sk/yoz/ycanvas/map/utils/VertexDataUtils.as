package sk.yoz.ycanvas.map.utils
{
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.map.valueObjects.PartialBounds;
    
    import starling.utils.VertexData;

    public class VertexDataUtils
    {
        /**
        * Starling 1.3 has broken implementation of VertexData.getBounds().
        * This is a simplified and optimized version.
        */
        public static function getBounds(vertexData:VertexData, vertexID:int,
            numVertices:int):Rectangle
        {
            var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
            var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
            var offsetX:int = vertexID * VertexData.ELEMENTS_PER_VERTEX 
                + VertexData.POSITION_OFFSET;
            var offestY:int = offsetX + 1;
            for(var i:uint = 0; i < numVertices; ++i)
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
        
        /**
        * Creates partial bounds from vertex data.
        */
        public static function getPartialBoundsList(vertexData:VertexData, 
            verticesPerPartialBounds:uint):Vector.<PartialBounds>
        {
            var result:Vector.<PartialBounds> = new Vector.<PartialBounds>;
            var step:uint = verticesPerPartialBounds - 2;
            var bounds:PartialBounds;
            var count:uint;
            var maxIndice:uint = (vertexData.numVertices - 3) * 3;
            var length:uint = vertexData.numVertices;
            for(var i:uint = 0; i < length; i += step)
            {
                count = verticesPerPartialBounds;
                if(i + count > length)
                    count = length - i;
                
                bounds = new PartialBounds;
                bounds.rectangle = getBounds(vertexData, i, count);
                bounds.vertexIndexMin = i;
                bounds.vertexIndexMax = i + count - 1;
                bounds.indiceIndexMin = bounds.vertexIndexMin < 2 
                    ? 0 : (bounds.vertexIndexMin - 2) * 3;
                bounds.indiceIndexMax = bounds.vertexIndexMax * 3 > maxIndice 
                    ? maxIndice : bounds.vertexIndexMax * 3;
                result.push(bounds);
            }
            return result;
        }
    }
}