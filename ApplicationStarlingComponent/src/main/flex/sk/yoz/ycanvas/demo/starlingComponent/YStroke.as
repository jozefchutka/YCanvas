package sk.yoz.ycanvas.demo.starlingComponent
{
    import sk.yoz.ycanvas.stage3D.elements.Stroke;
    
    public class YStroke extends Stroke
    {
        private var _originalThickness:Number;
        
        public function YStroke(points:Vector.<Number>, thickness:Number=1, 
            color:uint=16777215, alpha:Number=1)
        {
            _originalThickness = thickness;
            
            var x:Number = -(points[0] + points[points.length / 2] + points[points.length - 2]) / 3;
            var y:Number = -(points[1] + points[points.length / 2 + 1] + points[points.length - 1]) / 3;
            super(movePoints(points, x, y), thickness, color, alpha, true, false);
            pivotX = x;
            pivotY = y;
        }
        
        public function get originalPoints():Vector.<Number>
        {
            return movePoints(points, -pivotX, -pivotY);
        }
        
        public function get originalThickness():Number
        {
            return _originalThickness;
        }
        
        private static function movePoints(points:Vector.<Number>, x:Number, y:Number):Vector.<Number>
        {
            var result:Vector.<Number> = points.concat();
            for(var i:uint = 0, lenght:uint = points.length; i < lenght; i += 2)
                result[i] += x, result[i + 1] += y;
            return result;
        }
    }
}