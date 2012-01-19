package sk.yoz.ycanvas.demo.remotair
{
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import sk.yoz.math.GeometryMath;
    import sk.yoz.ycanvas.AbstractYCanvas;

    public class CanvasTransformation
    {
        public var centerX:Number = 0;
        public var centerY:Number = 0;
        public var scale:Number = 1;
        public var rotation:Number = 0;
        
        public function get center():Point
        {
            return new Point(centerX, centerY);
        }
        
        public function set center(value:Point):void
        {
            centerX = value.x;
            centerY = value.y;
        }
        
        public function toCanvas(canvas:AbstractYCanvas):void
        {
            canvas.center = center;
            canvas.rotation = rotation;
            canvas.scale = scale;
        }
        
        public function fromCanvas(canvas:AbstractYCanvas):void
        {
            center = canvas.center;
            scale = canvas.scale;
            rotation = canvas.rotation;
        }
        
        public function applyScaleRotation(scale:Number, rotation:Number, 
            globalPoint:Point, canvas:AbstractYCanvas):void
        {
            var lock:Point = globalPointInTweenTarget(canvas, globalPoint);
            var radians:Number = minifyRotation(rotation * GeometryMath.TO_RADIANS);
            var c:Number = 1 - 1 / scale;
            
            center = GeometryMath.rotatePointByRadians(center, lock, -radians);
            centerX += (lock.x - centerX) * c;
            centerY += (lock.y - centerY) * c;
            this.rotation += radians;
            this.scale *= scale;
        }
        
        private function minifyRotation(rotation:Number):Number
        {
            while(rotation > Math.PI)   rotation -= Math.PI * 2;
            while(rotation < -Math.PI)  rotation += Math.PI * 2;
            return rotation;
        }
        
        private function globalPointInTweenTarget(canvas:AbstractYCanvas, 
            globalPoint:Point):Point
        {
            var point:Point = canvas.globalToViewPort(globalPoint);
            var matrix:Matrix = canvas.getConversionMatrix(
                center, scale, rotation, canvas.viewPort);
            matrix.invert();
            return matrix.transformPoint(point);
        }
    }
}