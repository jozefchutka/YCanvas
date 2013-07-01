package sk.yoz.ycanvas.map
{
    import com.greensock.TweenMax;
    
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.utils.TransformationUtils;
    
    public class TransformationManager
    {
        public static const PI2:Number = Math.PI * 2;
        
        public var minScale:Number;
        public var maxScale:Number;
        public var minCenterX:Number;
        public var maxCenterX:Number;
        public var minCenterY:Number;
        public var maxCenterY:Number;
        
        private var transformation:CanvasTransformation = new CanvasTransformation;
        private var transformationTarget:CanvasTransformation = new CanvasTransformation;
        
        private var last:Point;
        
        private var tween:TweenMax;
        private var dispatcher:IEventDispatcher;
        private var canvas:MapController;
        private var stage:flash.display.Stage;
        
        private var _allowMove:Boolean;
        private var _allowZoom:Boolean;
        private var _allowInteractions:Boolean;
        
        public function TransformationManager(canvas:MapController, 
            dispatcher:IEventDispatcher, stage:flash.display.Stage):void
        {
            this.canvas = canvas;
            this.dispatcher = dispatcher;
            this.stage = stage;
            
            allowMove = true;
            allowZoom = true;
            
            updateTransformation();
            
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
        }
        
        public function dispose():void
        {
            stop();
            
            allowMove = false;
            allowZoom = false;
            allowInteractions = false;
            
            dispatcher.removeEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
            
            canvas = null;
        }
        
        public function set allowMove(value:Boolean):void
        {
            if(allowMove == value)
                return;
            
            _allowMove = value;
            validateInteractions();
            
            if(allowMove)
                stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
            else
                stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
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
            
            if(allowZoom)
                stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
            else
                stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
        }
        
        public function get allowZoom():Boolean
        {
            return _allowZoom;
        }
        
        private function set allowInteractions(value:Boolean):void
        {
            if(allowInteractions == value)
                return;
            
            _allowInteractions = value;
            if(allowInteractions)
                stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
            else
                stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
        }
        
        private function get allowInteractions():Boolean
        {
            return _allowInteractions;
        }
        
        private function get globalPointInTweenTarget():Point
        {
            var targetCenter:Point =
                new Point(transformationTarget.centerX, transformationTarget.centerY);
            var globalPoint:Point = new Point(stage.mouseX, stage.mouseY);
            var point:Point = canvas.globalToViewPort(globalPoint);
            var matrix:Matrix = canvas.getConversionMatrix(
                targetCenter, 
                transformationTarget.scale, 
                transformationTarget.rotation, canvas.viewPort);
            matrix.invert();
            return matrix.transformPoint(point);
        }
        
        private function get globalPointOnCanvas():Point
        {
            return canvas.globalToCanvas(new Point(stage.mouseX, stage.mouseY));
        }
        
        private function validateInteractions():void
        {
            allowInteractions = allowMove || allowZoom;
        }
        
        private static function normalizeRadians(radians:Number):Number
        {
            radians %= PI2;
            if(radians > Math.PI)
                radians -= PI2;
            else if(radians < -Math.PI)
                radians += PI2;
            return radians;
        }
        
        private function hitTest(x:Number, y:Number):Boolean
        {
            return canvas.hitTestComponent(x, y);
        }
        
        protected function limitScale(scale:Number):Number
        {
            if(scale > minScale)
                return minScale;
            if(scale < maxScale)
                return maxScale;
            return scale;
        }
        
        protected function limitCenterX(centerX:Number):Number
        {
            if(centerX < minCenterX)
                return minCenterY;
            if(centerX > maxCenterX)
                return maxCenterX;
            return centerX;
        }
        
        protected function limitCenterY(centerY:Number):Number
        {
            if(centerY < minCenterY)
                return minCenterY;
            if(centerY > maxCenterY)
                return maxCenterY;
            return centerY;
        }
        
        private function updateTransformation():void
        {
            transformationTarget.centerX = transformation.centerX = canvas.center.x;
            transformationTarget.centerY = transformation.centerY = canvas.center.y;
            transformationTarget.scale = transformation.scale = canvas.scale;
            transformationTarget.rotation = transformation.rotation = canvas.rotation;
        }
        
        private function stop():void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
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
        
        public function scaleByTween(delta:Number, lock:Point=null):void
        {
            scaleToTween(transformationTarget.scale * delta, lock);
        }
        
        public function scaleToTween(scale:Number, lock:Point=null):void
        {
            scale = Math.max(maxScale, Math.min(minScale, scale));
            doTween(NaN, NaN, scale, NaN, onScaleToTweenUpdate(lock));
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
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_STARTED));
        }
        
        private function onTweenComplete():void
        {
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
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
            updateTransformation();
        }
        
        private function onStageMouseDown(event:MouseEvent):void
        {
            if(!hitTest(event.stageX, event.stageY))
                return;
            
            last = globalPointInTweenTarget;
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
        }
        
        private function onStageMouseMove(event:MouseEvent):void
        {
            var current:Point = globalPointInTweenTarget;
            moveByTween(last.x - current.x, last.y - current.y);
            last = globalPointInTweenTarget;
        }
        
        private function onStageMouseUp(event:MouseEvent):void
        {
            stop();
        }
        
        private function onStageMouseWheel(event:MouseEvent):void
        {
            if(!hitTest(event.stageX, event.stageY))
                return;
            
            const step:Number = 1.25;
            var delta:Number = event.delta < 0 ? 1 / step : step;
            var point:Point = globalPointOnCanvas;
            point.x = limitCenterX(point.x);
            point.y = limitCenterY(point.y);
            scaleByTween(delta, point);
        }
        
        private function onStageMouseLeave(event:Event):void
        {
            stop();
        }
    }
}