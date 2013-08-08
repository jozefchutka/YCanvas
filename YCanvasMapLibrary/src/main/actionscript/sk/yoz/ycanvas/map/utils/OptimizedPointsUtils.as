package sk.yoz.ycanvas.map.utils
{
    import sk.yoz.ycanvas.map.valueObjects.OptimizedPoints;

    public class OptimizedPointsUtils
    {
        /**
        * Items with large x, y values causes scattered rendering with map 
        * panning. This method distributes large coordinates into pivot values.
        */
        public static function calculate(points:Vector.<Number>):OptimizedPoints
        {
            var pointsLength:uint = points.length;
            var index:uint = uint(pointsLength / 4);
            
            var result:OptimizedPoints = new OptimizedPoints;
            result.pivotX = -points[index * 2];
            result.pivotY = -points[index * 2 + 1];
            result.points = points.concat();
            
            for(var x:uint = 0, y:uint = 1; x < pointsLength; x += 2, y += 2)
            {
                result.points[x] += result.pivotX;
                result.points[y] += result.pivotY;
            }
            
            return result;
        }
    }
}