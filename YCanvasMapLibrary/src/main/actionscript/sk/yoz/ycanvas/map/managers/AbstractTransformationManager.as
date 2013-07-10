package sk.yoz.ycanvas.map.managers
{
    import com.greensock.TweenMax;
    
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.display.MapStroke;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.valueObjects.CanvasLimit;
    import sk.yoz.ycanvas.map.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.utils.TransformationUtils;

    public class AbstractTransformationManager
    {
        public static const PI2:Number = Math.PI * 2;
        
        protected var canvas:MapController;
        protected var transformation:CanvasTransformation = new CanvasTransformation;
        protected var transformationTarget:CanvasTransformation = new CanvasTransformation;
        
        private var limit:CanvasLimit;
        private var tween:TweenMax;
        
        private var _allowMove:Boolean;
        private var _allowZoom:Boolean;
        private var _allowRotate:Boolean;
        private var _allowInteractions:Boolean;
        private var _transforming:Boolean;
        
        public function AbstractTransformationManager(canvas:MapController, limit:CanvasLimit)
        {
            this.canvas = canvas;
            this.limit = limit;
            
            allowMove = true;
            allowZoom = true;
            allowRotate = true;
            
            updateTransformation();
            
            canvas.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
        }
        
        public function dispose():void
        {
            stop();
            
            allowMove = false;
            allowZoom = false;
            allowRotate = false;
            allowInteractions = false;
            
            canvas.removeEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
            
            canvas = null;
        }
        
        public function set allowMove(value:Boolean):void
        {
            if(allowMove == value)
                return;
            
            _allowMove = value;
            validateInteractions();
        }
        
        public function get allowMove():Boolean
        {
            return _allowMove;
        }
        
        public function set allowZoom(value:Boolean):void
        {
            if(allowZoom == value)
                return;
            
            _allowZoom = value;
            validateInteractions();
        }
        
        public function get allowZoom():Boolean
        {
            return _allowZoom;
        }
        
        public function set allowRotate(value:Boolean):void
        {
            if(allowRotate == value)
                return;
            
            _allowRotate = value;
            validateInteractions();
        }
        
        public function get allowRotate():Boolean
        {
            return _allowRotate;
        }
        
        protected function set allowInteractions(value:Boolean):void
        {
            if(allowInteractions == value)
                return;
            
            _allowInteractions = value;
        }
        
        protected function get allowInteractions():Boolean
        {
            return _allowInteractions;
        }
        
        protected function set transforming(value:Boolean):void
        {
            if(transforming == value)
                return;
            
            _transforming = value;
        }
        
        protected function get transforming():Boolean
        {
            return _transforming;
        }
        
        protected static function normalizeRadians(radians:Number):Number
        {
            radians %= PI2;
            if(radians > Math.PI)
                radians -= PI2;
            else if(radians < -Math.PI)
                radians += PI2;
            return radians;
        }
        
        protected function limitScale(scale:Number):Number
        {
            if(scale > limit.minScale)
                return limit.minScale;
            if(scale < limit.maxScale)
                return limit.maxScale;
            return scale;
        }
        
        protected function limitCenterX(centerX:Number):Number
        {
            if(centerX < limit.minCenterX)
                return limit.minCenterY;
            if(centerX > limit.maxCenterX)
                return limit.maxCenterX;
            return centerX;
        }
        
        protected function limitCenterY(centerY:Number):Number
        {
            if(centerY < limit.minCenterY)
                return limit.minCenterY;
            if(centerY > limit.maxCenterY)
                return limit.maxCenterY;
            return centerY;
        }
        
        protected function stop():void
        {
        }
        
        private function validateInteractions():void
        {
            allowInteractions = allowMove || allowZoom || allowRotate;
        }
        
        private function updateTransformation():void
        {
            transformationTarget.centerX = transformation.centerX = canvas.center.x;
            transformationTarget.centerY = transformation.centerY = canvas.center.y;
            transformationTarget.scale = transformation.scale = canvas.scale;
            transformationTarget.rotation = transformation.rotation = canvas.rotation;
        }
        
        public function moveByTween(deltaX:Number, deltaY:Number):void
        {
            moveToTween(
                transformationTarget.centerX + deltaX, 
                transformationTarget.centerY + deltaY);
        }
        
        public function moveToTween(centerX:Number, centerY:Number):void
        {
            doTween(centerX, centerY, NaN, NaN, onMoveToTweenUpdate);
        }
        
        public function moveRotateToTween(centerX:Number, centerY:Number, rotation:Number):void
        {
            var delta:Number = normalizeRadians(rotation - transformationTarget.rotation);
            rotation = transformationTarget.rotation + delta;
            doTween(centerX, centerY, NaN, rotation, onMoveRotateToTweenUpdate);
        }
        
        public function moveRotateScaleToTween(centerX:Number, centerY:Number,
            rotation:Number, scale:Number):void
        {
            var delta:Number = normalizeRadians(rotation - transformationTarget.rotation);
            rotation = transformationTarget.rotation + delta;
            doTween(centerX, centerY, scale, rotation, onMoveRotateScaleToTweenUpdate);
        }
        
        public function rotateByTween(delta:Number, lock:Point=null):void
        {
            rotateToTween(transformationTarget.rotation + delta);
        }
        
        public function rotateToTween(rotation:Number, lock:Point=null):void
        {
            var delta:Number = normalizeRadians(rotation - transformationTarget.rotation);
            rotation = transformationTarget.rotation + delta;
            doTween(NaN, NaN, NaN, rotation, onRotateToTweenUpdate(lock));
        }
        
        public function rotateScaleToTween(rotation:Number, scale:Number):void
        {
            var delta:Number = normalizeRadians(rotation - transformationTarget.rotation);
            rotation = transformationTarget.rotation + delta;
            doTween(NaN, NaN, scale, rotation, onRotateScaleToTweenUpdate);
        }
        
        public function scaleByTween(delta:Number, lock:Point=null):void
        {
            scaleToTween(transformationTarget.scale * delta, lock);
        }
        
        public function scaleToTween(scale:Number, lock:Point=null):void
        {
            doTween(NaN, NaN, scale, NaN, onScaleToTweenUpdate(lock));
        }
        
        public function showBoundsTween(left:Number, right:Number, top:Number, bottom:Number):void
        {
            var centerX:Number = (left + right) / 2;
            var centerY:Number = (top + bottom) / 2;
            
            var targetLeftTop:Point = canvas.canvasToViewPort(new Point(left, top));
            var targetRightBottom:Point = canvas.canvasToViewPort(new Point(right, bottom));
            var targetMinX:Number = Math.min(targetLeftTop.x, targetRightBottom.x);
            var targetMaxX:Number = Math.max(targetLeftTop.x, targetRightBottom.x);
            var targetMinY:Number = Math.min(targetLeftTop.y, targetRightBottom.y);
            var targetMaxY:Number = Math.max(targetLeftTop.y, targetRightBottom.y);
            
            var deltaScaleX:Number = 
                Math.abs(canvas.viewPort.width) /
                Math.abs(targetMaxX - targetMinX);
            
            var deltaScaleY:Number = 
                Math.abs(canvas.viewPort.height) /
                Math.abs(targetMaxY - targetMinY);
            
            var deltaScale:Number = Math.min(deltaScaleX, deltaScaleY);
            var scale:Number = canvas.scale * deltaScale;
            
            doTween(centerX, centerY, scale, canvas.rotation, onMoveScaleToTweenUpdate);
        }
        
        public function showStrokeTween(stroke:MapStroke):void
        {
            showBoundsTween(
                stroke.bounds.left - stroke.pivotX,
                stroke.bounds.right - stroke.pivotX,
                stroke.bounds.top - stroke.pivotY,
                stroke.bounds.bottom - stroke.pivotY);
        }
        
        private function doTween(centerX:Number, centerY:Number, scale:Number, 
            rotation:Number, updateCallback:Function):void
        {
            var data:Object = {onUpdate:updateCallback, onComplete:onTweenComplete};
            if(isNaN(centerX))
                transformationTarget.centerX = transformation.centerX = canvas.center.x;
            else
                transformationTarget.centerX = data.centerX = limitCenterX(centerX);
            
            if(isNaN(centerY))
                transformationTarget.centerY = transformation.centerY = canvas.center.y;
            else
                transformationTarget.centerY = data.centerY = limitCenterY(centerY);
            
            if(isNaN(scale))
                transformationTarget.scale = transformation.scale = canvas.scale;
            else
                transformationTarget.scale = data.scale = limitScale(scale);
            
            if(isNaN(rotation))
                transformationTarget.rotation = transformation.rotation = canvas.rotation;
            else
                transformationTarget.rotation = data.rotation = rotation;
            
            tween && tween.kill();
            tween = TweenMax.to(transformation, .5, data);
            transforming = true;
            canvas.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_STARTED));
        }
        
        private function onTweenComplete():void
        {
            canvas.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
        }
        
        private function onMoveToTweenUpdate():void
        {
            TransformationUtils.moveTo(canvas, 
                new Point(transformation.centerX, transformation.centerY));
        }
        
        private function onMoveRotateToTweenUpdate():void
        {
            TransformationUtils.moveRotateTo(canvas, 
                new Point(transformation.centerX, transformation.centerY), 
                transformation.rotation);
        }
        
        private function onMoveRotateScaleToTweenUpdate():void
        {
            TransformationUtils.moveRotateTo(canvas, 
                new Point(transformation.centerX, transformation.centerY), 
                transformation.rotation);
            canvas.scale = transformation.scale;
        }
        
        private function onRotateToTweenUpdate(lock:Point):Function
        {
            return function():void
            {
                TransformationUtils.rotateTo(canvas, transformation.rotation, lock);
                transformationTarget.centerX = transformation.centerX = canvas.center.x;
                transformationTarget.centerY = transformation.centerY = canvas.center.y;
            }
        }
        
        private function onRotateScaleToTweenUpdate():void
        {
            TransformationUtils.rotateScaleTo(canvas, transformation.rotation, transformation.scale);
        }
        
        private function onScaleToTweenUpdate(lock:Point):Function
        {
            return function():void
            {
                TransformationUtils.scaleTo(canvas, transformation.scale, lock);
                transformationTarget.centerX = transformation.centerX = canvas.center.x;
                transformationTarget.centerY = transformation.centerY = canvas.center.y;
            }
        }
        
        private function onMoveScaleToTweenUpdate():void
        {
            TransformationUtils.scaleTo(canvas, transformation.scale,
                new Point(transformationTarget.centerX, transformationTarget.centerY));
            canvas.center = new Point(transformation.centerX, transformation.centerY);
        }
        
        private function onCanvasTransformationFinished(event:CanvasEvent):void
        {
            transforming = false;
            updateTransformation();
        }
    }
}