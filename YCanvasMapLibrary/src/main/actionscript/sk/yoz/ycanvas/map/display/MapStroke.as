package sk.yoz.ycanvas.map.display
{
    import sk.yoz.utils.PathSimplify;
    
    /**
    * Stroke extension for maps with simplify optimization.
    * 
    * The simplify algorithms are used to re-calculate stroke path at lower 
    * zoom. Simplifying reduces the points / triangles making it faster to 
    * evaluate hitTest() method.
    */
    public class MapStroke extends Stroke
    {
        /**
        * If 0 no stroke symplifying is applied. If > 0 a symplifying algorithm
        * is applied on stroke based on YCanvas scale.
        */
        public var simplifyTolerance:Number = 4;
        
        private var _basePoints:Vector.<Number>;
        private var _originalThickness:Number;
        private var _layerScale:Number;
        
        public function MapStroke(points:Vector.<Number>, thickness:Number=1, 
            color:uint=16777215, alpha:Number=1)
        {
            _basePoints = points.concat();
            _originalThickness = thickness;
            
            super(null, thickness, color, alpha, false);
        }
        
        /**
        * A copy of array of original points shifted by pivot.
        */
        public function get basePoints():Vector.<Number>
        {
            return _basePoints;
        }
        
        /**
        * Original thickness value.
        */
        public function get originalThickness():Number
        {
            return _originalThickness;
        }
        
        /**
        * Based on value of YCanvas scale, the thickness is recalculated.
        */
        public function set layerScale(value:Number):void
        {
            if(layerScale == value)
                return;
            
            _layerScale = value;
            thickness = originalThickness / layerScale;
            invalidatePoints();
        }
        
        public function get layerScale():Number
        {
            return _layerScale;
        }
        
        /**
        * Invalidates stroke points.
        */
        private function invalidatePoints():void
        {
            if(!simplifyTolerance)
                return;
            
            var autoUpdate:Boolean = this.autoUpdate;
            this.autoUpdate = false;
            points = null;
            this.autoUpdate = autoUpdate;
        }
        
        /**
        * Validates stroke points based on simplifyTolerance parameter and
        * current layer scale.
        */
        private function validatePoints():void
        {
            if(points)
                return;
            
            var autoUpdate:Boolean = this.autoUpdate;
            this.autoUpdate = false;
            
            var tolerance:Number = simplifyTolerance / layerScale;
            points = simplifyTolerance
                ? PathSimplify.simplify(basePoints, tolerance, false)
                : basePoints.concat();
            
            this.autoUpdate = autoUpdate;
        }
        
        /**
        * @inheritDoc
        */
        override public function update():void
        {
            validatePoints();
            super.update();
        }
    }
}