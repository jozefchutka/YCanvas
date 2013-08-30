package sk.yoz.ycanvas.map.utils
{
    import sk.yoz.ycanvas.map.valueObjects.PartialBounds;
    
    import starling.utils.VertexData;

    public class VertexDataUtils
    {
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
                bounds.rectangle = vertexData.getBounds(null, i, count);//getBounds(vertexData, i, count);
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