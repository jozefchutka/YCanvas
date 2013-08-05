package sk.yoz.ycanvas.map.utils
{
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.map.valueObjects.PartialBounds;

    public class PartialBoundsUtils
    {
        /**
        * Creates bounds from a list of partial bounds.
        */
        public static function mergeListToRectangle(
            list:Vector.<PartialBounds>):Rectangle
        {
            var item:PartialBounds = list[0];
            var rectangle:Rectangle = item.rectangle;;
            var minX:Number = rectangle.x;
            var minY:Number = rectangle.y;
            var maxX:Number = rectangle.x + rectangle.width;
            var maxY:Number = rectangle.y + rectangle.height;
            for(var i:uint = 1, length:uint = list.length; i < length; i++)
            {
                item = list[i];
                rectangle = item.rectangle;
                if(rectangle.x < minX)
                    minX = rectangle.x;
                if(rectangle.y < minY)
                    minY = rectangle.y;
                if(rectangle.x + rectangle.width > maxX)
                    maxX = rectangle.x + rectangle.width;
                if(rectangle.y + rectangle.height > maxY)
                    maxY = rectangle.y + rectangle.height;
            }
            
            return new Rectangle(minX, minY, maxX - minX, maxY - minY);
        }
    }
}