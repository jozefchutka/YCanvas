package sk.yoz.ycanvas.demo.starlingComponent
{
    import sk.yoz.ycanvas.stage3D.elements.Stroke;
    
    public class YStroke extends Stroke
    {
        private var _originalThickness:Number;
        
        public function YStroke(points:Vector.<Number>, thickness:Number=1, 
            color:uint=16777215, alpha:Number=1)
        {
            super(points, thickness, color, alpha, false);
            
            _originalThickness = thickness;
        }
        
        public function get originalThickness():Number
        {
            return _originalThickness;
        }
    }
}