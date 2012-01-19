package sk.yoz.ycanvas.utils
{
    import flash.geom.Point;
    
    import sk.yoz.math.GeometryMath;
    import sk.yoz.ycanvas.AbstractYCanvas;
    
    /**
     * An utility class for canvas transformation.
     */
    public class TransformationUtils
    {
        /**
        * Moves canvas center to a custom position.
        */
        public static function moveTo(canvas:AbstractYCanvas, center:Point):void
        {
            canvas.center = center;
        }
        
        /**
        * Scales canvas to a custom scale keeping the lock point on the same 
        * place.
        * 
        * @param scale Target scale.
        * @param lock Canvas point around which canvas scales.
        */
        public static function scaleTo(canvas:AbstractYCanvas, scale:Number, 
            lock:Point=null):void
        {
            if(!lock)
                lock = canvas.center;
            
            var c:Number = 1 - canvas.scale / scale;
            canvas.center = new Point(
                canvas.center.x + (lock.x - canvas.center.x) * c,
                canvas.center.y + (lock.y - canvas.center.y) * c
            );
            canvas.scale = scale;
        }
        
        /**
        * Rotates canvas to a custom rotation keeping lock point on the same 
        * place.
        * 
        * @param rotation Target rotation in radians.
        * @param lock Canvas point around which canvas rotates.
        */
        public static function rotateTo(canvas:AbstractYCanvas, rotation:Number,
            lock:Point=null):void
        {
            if(!lock)
                lock = canvas.center;
            
            var delta:Number = canvas.rotation - rotation;
            canvas.center = GeometryMath.rotatePointByRadians(
                canvas.center, lock, delta);
            canvas.rotation = rotation;
        }
        
        /**
        * Rotates and scales canvas to a custom values keeping lock point on 
        * the same place.
        * 
        * @param rotation Target rotation in radians.
        * @param scale Target scale.
        * @param lock Canvas point around which canvas transforms.
        */
        public static function rotateScaleTo(canvas:AbstractYCanvas, 
            rotation:Number, scale:Number, lock:Point=null):void
        {
            if(!lock)
                lock = canvas.center;
            
            var delta:Number = canvas.rotation - rotation;
            var center:Point = GeometryMath.rotatePointByRadians(
                canvas.center, lock, delta);
            var c:Number = 1 - canvas.scale / scale;
            center.x += (lock.x - center.x) * c;
            center.y += (lock.y - center.y) * c;
            
            canvas.center = center;
            canvas.rotation = rotation;
            canvas.scale = scale;
        }
    }
}