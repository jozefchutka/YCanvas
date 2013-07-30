package sk.yoz.ycanvas.map.display
{
    import sk.yoz.ycanvas.map.utils.PathSimplify;
    import sk.yoz.ycanvas.starling.elements.Stroke;
    
    public class MapStroke extends Stroke
    {
        public var simplifyTolerance:Number = 4;
        
        private var _originalPoints:Vector.<Number>;
        private var _originalThickness:Number;
        
        private var _layerScale:Number;
        
        public function MapStroke(points:Vector.<Number>, thickness:Number=1, 
            color:uint=16777215, alpha:Number=1)
        {
            _originalPoints = points.concat();
            _originalThickness = thickness;
            
            super(null, thickness, color, alpha, false);
            
            var length:uint = originalPoints.length;
            pivotX = -(originalPoints[0] + originalPoints[length - 2]) / 2;
            pivotY = -(originalPoints[1] + originalPoints[length - 1]) / 2;
            
            for(var x:uint = 0, y:uint = 1; x < length; x += 2, y += 2)
            {
                originalPoints[x] += pivotX;
                originalPoints[y] += pivotY;
            }
        }
        
        public function get originalPoints():Vector.<Number>
        {
            return _originalPoints;
        }
        
        public function get originalThickness():Number
        {
            return _originalThickness;
        }
        
        public function set layerScale(value:Number):void
        {
            if(layerScale == value)
                return;
            
            _layerScale = value;
            thickness = originalThickness / layerScale;
            resetPoints();
        }
        
        public function get layerScale():Number
        {
            return _layerScale;
        }
        
        private function resetPoints():void
        {
            if(!simplifyTolerance)
                return;
            
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
            
            var tolerance:Number = simplifyTolerance / layerScale;
            points = simplifyTolerance
                ? PathSimplify.simplify(originalPoints, tolerance, false)
                : originalPoints.concat();
            
            this.autoUpdate = autoUpdate;
        }
        
        override public function update():void
        {
            validatePoints();
            super.update();
        }
    }
}