package sk.yoz.ycanvas.utils
{
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.valueObjects.PartialBounds;
    
    import starling.utils.VertexData;

    public class VertexDataUtils
    {
        /* while native VertexData.getBounds() seems to be broken */
        public static function getBounds(vertexData:VertexData, vertexID:int, numVertices:int):Rectangle
        {
            var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
            var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
            var offsetX:int = vertexID * VertexData.ELEMENTS_PER_VERTEX + VertexData.POSITION_OFFSET;
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
        
        public static function getPartialBoundsList(vertexData:VertexData, 
            verticesPerRectangle:uint):Vector.<PartialBounds>
        {
            var result:Vector.<PartialBounds> = new Vector.<PartialBounds>;
            var step:uint = verticesPerRectangle - 2;
            var partialBounds:PartialBounds;
            var count:uint;
            var maxIndice:uint = (vertexData.numVertices - 3) * 3;
            for(var i:uint = 0, length:uint = vertexData.numVertices; i < length; i += step)
            {
                count = verticesPerRectangle;
                if(i + count > length)
                    count = length - i;
                
                partialBounds = new PartialBounds;
                partialBounds.rectangle = getBounds(vertexData, i, count);
                partialBounds.vertexIndexMin = i;
                partialBounds.vertexIndexMax = i + count - 1;
                partialBounds.indiceIndexMin = partialBounds.vertexIndexMin < 2 ? 0 : (partialBounds.vertexIndexMin - 2) * 3;
                partialBounds.indiceIndexMax = partialBounds.vertexIndexMax * 3 > maxIndice ? maxIndice : partialBounds.vertexIndexMax * 3;
                result.push(partialBounds);
            }
            return result;
        }
    }
}