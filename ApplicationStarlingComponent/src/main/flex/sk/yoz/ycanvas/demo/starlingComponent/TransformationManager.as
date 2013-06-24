package sk.yoz.ycanvas.demo.starlingComponent
{
    import com.greensock.TweenMax;
    
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.demo.starlingComponent.events.CanvasEvent;
    import sk.yoz.ycanvas.demo.starlingComponent.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.utils.TransformationUtils;
    
    import starling.core.Starling;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    
    public class TransformationManager
    {
        public static const PI2:Number = Math.PI * 2;
        
        public var minScale:Number = 1;
        public var maxScale:Number = 1 / 12;
        
        private var transformation:CanvasTransformation = new CanvasTransformation;
        private var transformationTarget:CanvasTransformation = new CanvasTransformation;
        
        private var last:Point;
        
        private var tween:TweenMax;
        private var dispatcher:IEventDispatcher;
        private var component:YCanvasStarlingComponent;
        private var stage:Stage;
        
        private var _allowMove:Boolean;
        private var _allowZoom:Boolean;
        private var _allowInteractions:Boolean;
        
        public function TransformationManager(component:YCanvasStarlingComponent, 
            dispatcher:IEventDispatcher, stage:Stage):void
        {
            this.component = component;
            this.dispatcher = dispatcher;
            this.stage = stage;
            
            allowMove = true;
            allowZoom = true;
            
            updateTransformation();
            
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
        }
        
        public function dispose():void
        {
            dispatcher.removeEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
            
            component = null;
        }
        
        public function set allowMove(value:Boolean):void
        {
            if(allowMove == value)
                return;
            
            _allowMove = value;
            validateInteractions();
            
            if(allowMove)
                component.addEventListener(TouchEvent.TOUCH, onTouch);
            else
                component.removeEventListener(TouchEvent.TOUCH, onTouch);
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
        
        private function get canvas():AbstractYCanvas
        {
            return component.controller;
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
        
        private function updateTransformation():void
        {
            transformationTarget.centerX = transformation.centerX = canvas.center.x;
            transformationTarget.centerY = transformation.centerY = canvas.center.y;
            transformationTarget.scale = transformation.scale = canvas.scale;
            transformationTarget.rotation = transformation.rotation = canvas.rotation;
        }
        
        private function stop():void
        {
        }
        
        private function touchBegan(touch:Touch):void
        {
            last = globalPointInTweenTarget;
        }
        
        private function touchMoved(touch:Touch):void
        {
            var current:Point = globalPointInTweenTarget;
            moveByTween(last.x - current.x, last.y - current.y);
            last = globalPointInTweenTarget;
        }
        
        private function touchEnded(touch:Touch):void
        {
            stop();
        }
        
        private function moveByTween(deltaX:Number, deltaY:Number):void
        {
            moveToTween(
                transformationTarget.centerX + deltaX, 
                transformationTarget.centerY + deltaY);
        }
        
        private function moveToTween(centerX:Number, centerY:Number):void
        {
            doTween(centerX, centerY, NaN, NaN, onMoveToTweenUpdate);
        }
        
        private function rotateByTween(delta:Number, lock:Point=null):void
        {
            rotateToTween(transformationTarget.rotation + delta);
        }
        
        private function rotateToTween(rotation:Number, lock:Point=null):void
        {
            var delta:Number = normalizeRadians(rotation - transformationTarget.rotation);
            rotation = transformationTarget.rotation + delta;
            doTween(NaN, NaN, NaN, rotation, onRotateToTweenUpdate(lock));
        }
        
        private function scaleByTween(delta:Number, lock:Point=null):void
        {
            scaleToTween(transformationTarget.scale * delta, lock);
        }
        
        private function scaleToTween(scale:Number, lock:Point=null):void
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
                transformationTarget.centerX = data.centerX = centerX;
            
            if(isNaN(centerY))
                transformationTarget.centerY = transformation.centerY = canvas.center.y;
            else
                transformationTarget.centerY = data.centerY = centerY;
            
            if(isNaN(scale))
                transformationTarget.scale = transformation.scale = canvas.scale;
            else
                transformationTarget.scale = data.scale = scale;
            
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
        
        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch;
            
            touch = event.getTouch(component, TouchPhase.BEGAN);
            if(touch)
                return touchBegan(touch);
            
            touch = event.getTouch(component, TouchPhase.MOVED);
            if(touch)
                return touchMoved(touch);
            
            touch = event.getTouch(component, TouchPhase.ENDED);
            if(touch)
                return touchEnded(touch);
        }
        
        private function onStageMouseWheel(event:MouseEvent):void
        {
            var engine:Starling = Starling.current;
            var starlingPoint:Point = new Point(stage.mouseX - engine.viewPort.x, stage.mouseY - engine.viewPort.y);
            if(engine.stage.hitTest(starlingPoint) != component)
                return;
            
            const step:Number = 1.25;
            var delta:Number = event.delta < 0 ? 1 / step : step;
            scaleByTween(delta, globalPointOnCanvas);
        }
        
        private function onStageMouseLeave(event:Event):void
        {
            stop();
        }
    }
}