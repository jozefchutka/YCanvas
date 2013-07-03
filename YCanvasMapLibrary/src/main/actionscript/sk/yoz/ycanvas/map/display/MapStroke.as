package sk.yoz.ycanvas.map.display
{
    import sk.yoz.ycanvas.map.utils.PathSimplify;
    import sk.yoz.ycanvas.stage3D.elements.Stroke;
    
    public class MapStroke extends Stroke
    {
        private var _originalPoints:Vector.<Number>;
        private var _originalThickness:Number;
        
        public function MapStroke(points:Vector.<Number>, thickness:Number=1, 
            color:uint=16777215, alpha:Number=1)
        {
            _originalPoints = points;
            _originalThickness = thickness;
            
            var x:Number = -(points[0] + points[points.length / 2] + points[points.length - 2]) / 3;
            var y:Number = -(points[1] + points[points.length / 2 + 1] + points[points.length - 1]) / 3;
            super(null, thickness, color, alpha, true, false);
            pivotX = x;
            pivotY = y;
        }
        
        public function get originalPoints():Vector.<Number>
        {
            return _originalPoints;
        }
        
        public function get originalThickness():Number
        {
            return _originalThickness;
        }
        
        override public function set thickness(value:Number):void
        {
            if(thickness == value)
                return;
            
            resetPoints();
            super.thickness = value;
        }
        
        private function resetPoints():void
        {
            var autoUpdate:Boolean = this.autoUpdate;
            this.autoUpdate = false;
            points = null;
            this.autoUpdate = autoUpdate;
        }
        
        private function validatePoints():void
        {
            if(points)
                return;
            
            var autoUpdate:Boolean = this.autoUpdate;
            this.autoUpdate = false;
            points = getSimplifiedPoints(originalPoints, pivotX, pivotY, thickness);
            this.autoUpdate = autoUpdate;
        }
        
        override public function update():void
        {
            validatePoints();
            super.update();
        }
        
        private static function getSimplifiedPoints(points:Vector.<Number>, x:Number, y:Number, thickness:Number):Vector.<Number>
        {
            var l:uint = points.length;
            var tolerance:Number = simplifyTolerance(thickness);
            var d0:Date = new Date;
            points = PathSimplify.simplify(points, tolerance, false);
            // tol .5: 748 - 768
            // tol 1: 784 - 746
            // tol 2: 784 - 708
            
            trace("from:", l, "to:", points.length, "("+tolerance+")", new Date().time - d0.time);
            
            for(var i:uint = 0, lenght:uint = points.length; i < lenght; i += 2)
                points[i] += x, points[i + 1] += y;
            
            return points;
        }
        
        private static function simplifyTolerance(thickness:Number):Number
        {
            return thickness / 2;
        }
    }
}