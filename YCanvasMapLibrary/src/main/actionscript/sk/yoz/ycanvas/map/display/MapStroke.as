package sk.yoz.ycanvas.map.display
{
    import sk.yoz.ycanvas.map.utils.PathSimplify;
    import sk.yoz.ycanvas.stage3D.elements.Stroke;
    
    public class MapStroke extends Stroke
    {
        public var simplifyTolerance:Number = 4;
        
        private var _originalPoints:Vector.<Number>;
        private var _originalThickness:Number;
        
        private var _layerScale:Number;
        
        public function MapStroke(points:Vector.<Number>, thickness:Number=1, 
            color:uint=16777215, alpha:Number=1)
        {
            _originalPoints = points;
            _originalThickness = thickness;
            
            var x:Number = -(points[0] + points[points.length / 2] + points[points.length - 2]) / 3;
            var y:Number = -(points[1] + points[points.length / 2 + 1] + points[points.length - 1]) / 3;
            super(null, thickness, color, alpha, false);
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
            
            var simplifiedPoints:Vector.<Number> = simplifyTolerance
                ? PathSimplify.simplify(originalPoints, simplifyTolerance / layerScale, false)
                : originalPoints.concat();
            for(var i:uint = 0, lenght:uint = simplifiedPoints.length; i < lenght; i += 2)
                simplifiedPoints[i] += pivotX, simplifiedPoints[uint(i + 1)] += pivotY;
            
            points = simplifiedPoints;
            
            this.autoUpdate = autoUpdate;
        }
        
        override public function update():void
        {
            validatePoints();
            super.update();
        }
    }
}