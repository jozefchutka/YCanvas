package sk.yoz.ycanvas.demo.explorer.managers
{
    import com.greensock.TweenMax;
    
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.demo.explorer.Assets;
    import sk.yoz.ycanvas.demo.explorer.events.CanvasEvent;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.CanvasLimits;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.demo.explorer.view.Board;
    import sk.yoz.ycanvas.utils.TransformationUtils;
    
    public class TransformationManager
    {
        public static const PI2:Number = Math.PI * 2;
        
        private var minScale:Number = 1;
        private var maxScale:Number = 1 / 12;
        
        private var transformation:CanvasTransformation = new CanvasTransformation;
        private var transformationTarget:CanvasTransformation = new CanvasTransformation;
        
        private var last:Point;
        private var rotator:Sprite = new Assets.DRAG_ROTATE_CLASS;
        private var zoomer:Sprite = new Assets.DRAG_ZOOM_CLASS;
        
        private var stage:Stage;
        private var tween:TweenMax;
        private var dispatcher:IEventDispatcher;
        private var canvas:AbstractYCanvas;
        private var board:Board;
        
        private var _allowMove:Boolean;
        private var _allowZoom:Boolean;
        private var _allowRotate:Boolean;
        private var _allowInteractions:Boolean;
        
        public function TransformationManager(canvas:AbstractYCanvas, 
            board:Board, dispatcher:IEventDispatcher, stage:Stage):void
        {
            this.canvas = canvas;
            this.dispatcher = dispatcher;
            this.stage = stage;
            this.board = board;
            
            rotator.buttonMode = true;
            rotator.doubleClickEnabled = true;
            
            zoomer.buttonMode = true;
            
            allowMove = true;
            allowZoom = true;
            allowRotate = true;
            
            resize();
            updateTransformation();
            
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
        }
        
        public function dispose():void
        {
            allowMove = false;
            allowZoom = false;
            allowRotate = false;
            
            stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
            stage = null;
            
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
                board.addEventListener(MouseEvent.MOUSE_DOWN, onBoardDown);
            else
                board.removeEventListener(MouseEvent.MOUSE_DOWN, onBoardDown);
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
            {
                board.addChild(zoomer);
                board.addEventListener(MouseEvent.MOUSE_WHEEL, onBoardWheel);
                board.addEventListener(MouseEvent.DOUBLE_CLICK, onBoardDoubleClick);
                zoomer.addEventListener(MouseEvent.MOUSE_DOWN, onZoomerDown);
            }
            else
            {
                board.removeChild(zoomer);
                board.removeEventListener(MouseEvent.MOUSE_WHEEL, onBoardWheel);
                board.removeEventListener(MouseEvent.DOUBLE_CLICK, onBoardDoubleClick);
                zoomer.removeEventListener(MouseEvent.MOUSE_DOWN, onZoomerDown);
            }
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
            
            if(allowRotate)
            {
                board.addChild(rotator);
                rotator.addEventListener(MouseEvent.MOUSE_DOWN, onRotatorDown);
                rotator.addEventListener(MouseEvent.DOUBLE_CLICK, onRotatorDoubleClick);
            }
            else
            {
                board.removeChild(rotator);
                rotator.removeEventListener(MouseEvent.MOUSE_DOWN, onRotatorDown);
                rotator.removeEventListener(MouseEvent.DOUBLE_CLICK, onRotatorDoubleClick);
            }
        }
        
        public function get allowRotate():Boolean
        {
            return _allowRotate;
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
        
        private function validateInteractions():void
        {
            allowInteractions = allowMove || allowZoom || allowRotate;
        }
        
        public function set limits(value:CanvasLimits):void
        {
            minScale = value.scaleMin;
            maxScale = value.scaleMax;
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
        
        private function get globalPointCenteredOnCanvasCenter():Point
        {
            var center:Point = canvas.canvasToGlobal(canvas.center);
            return new Point(stage.mouseX - center.x, stage.mouseY - center.y);
        }
        
        private function get globalPointOnCanvas():Point
        {
            return canvas.globalToCanvas(new Point(stage.mouseX, stage.mouseY));
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
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMoveRotator);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMoveZoomer);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMove);
        }
        
        public function resize():void
        {
            zoomer.x = 0;
            zoomer.y = canvas.viewPort.height / 2;
            rotator.x = canvas.viewPort.width;
            rotator.y = canvas.viewPort.height / 2;
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
        
        private function onBoardDown(event:MouseEvent):void
        {
            if(event.target != board)
                return;
            
            last = globalPointInTweenTarget;
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMove);
        }
        
        private function onBoardDoubleClick(event:MouseEvent):void
        {
            scaleToTween(minScale, globalPointOnCanvas);
        }
        
        private function onBoardWheel(event:MouseEvent):void
        {
            const step:Number = 1.25;
            var delta:Number = event.delta < 0 ? 1 / step : step;
            scaleByTween(delta, globalPointOnCanvas);
        }
        
        private function onRotatorDown(event:MouseEvent):void
        {
            last = globalPointCenteredOnCanvasCenter;
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMoveRotator);
        }
        
        private function onRotatorDoubleClick(event:MouseEvent):void
        {
            event.stopImmediatePropagation();
            rotateToTween(0);
        }
        
        private function onZoomerDown(event:MouseEvent):void
        {
            last = new Point(zoomer.mouseX, zoomer.mouseY);
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMoveZoomer);
        }
        
        private function onStageMove(event:MouseEvent):void
        {
            var current:Point = globalPointInTweenTarget;
            moveByTween(last.x - current.x, last.y - current.y);
            last = globalPointInTweenTarget;
        }
        
        private function onStageMoveRotator(event:MouseEvent):void
        {
            var position:Point = globalPointCenteredOnCanvasCenter;
            var rad1:Number = Math.atan2(last.y, last.x);
            var rad2:Number = Math.atan2(position.y, position.x);
            rotateByTween(rad2 - rad1);
            last = position;
        }
        
        private function onStageMoveZoomer(event:MouseEvent):void
        {
            var delta:Number = 1 - (zoomer.mouseY - last.y) / 200;
            scaleByTween(delta);
            last = new Point(zoomer.mouseX, zoomer.mouseY);
        }
        
        private function onStageUp(event:MouseEvent):void
        {
            stop();
        }
        
        private function onStageMouseLeave(event:Event):void
        {
            stop();
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
    }
}