package sk.yoz.ycanvas.map.display
{
    public class MapPolygon extends Polygon
    {
        public function MapPolygon(points:Vector.<Number>, color:uint=0xffffff, 
            alpha:Number=1)
        {
            var basePoints:Vector.<Number> = points.concat();
            
            var length:uint = basePoints.length;
            var pivotX:Number = -basePoints[0];
            var pivotY:Number = -basePoints[1];
            
            for(var x:uint = 0, y:uint = 1; x < length; x += 2, y += 2)
            {
                basePoints[x] += pivotX;
                basePoints[y] += pivotY;
            }
            
            super(basePoints, color, alpha, false);
            this.pivotX = pivotX;
            this.pivotY = pivotY;
            update();
        }
    }
}