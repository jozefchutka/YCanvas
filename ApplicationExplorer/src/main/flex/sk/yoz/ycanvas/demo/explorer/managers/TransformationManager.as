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
        private var isMouseDown:Boolean = false;
        private var isBoardOver:Boolean;
        
        private var isRotatorOver:Boolean;
        private var isRotatorDown:Boolean;
        private var rotator:Sprite = new Assets.DRAG_ROTATE_CLASS;
        
        private var isZoomerOver:Boolean;
        private var isZoomerDown:Boolean;
        private var zoomer:Sprite = new Assets.DRAG_ZOOM_CLASS;
        
        private var stage:Stage;
        private var tween:TweenMax;
        private var dispatcher:IEventDispatcher;
        private var canvas:AbstractYCanvas;
        private var running:Boolean;
        
        public function TransformationManager(canvas:AbstractYCanvas, 
            board:Board, dispatcher:IEventDispatcher, stage:Stage):void
        {
            this.canvas = canvas;
            this.dispatcher = dispatcher;
            this.stage = stage;
            
            rotator.buttonMode = true;
            rotator.doubleClickEnabled = true;
            board.addChild(rotator);
            
            zoomer.buttonMode = true;
            board.addChild(zoomer);
            
            resize();
            updateTransformation();
            
            board.addEventListener(MouseEvent.MOUSE_OVER, onBoardOver);
            board.addEventListener(MouseEvent.MOUSE_DOWN, onBoardDown);
            board.addEventListener(MouseEvent.MOUSE_WHEEL, onBoardWheel);
            board.addEventListener(MouseEvent.DOUBLE_CLICK, onBoardDoubleClick);
            board.addEventListener(MouseEvent.ROLL_OVER, onBoardRollOver);
            board.addEventListener(MouseEvent.ROLL_OUT, onBoardRollOut);
            
            rotator.addEventListener(MouseEvent.MOUSE_OVER, onRotatorOver);
            rotator.addEventListener(MouseEvent.MOUSE_DOWN, onRotatorDown);
            rotator.addEventListener(MouseEvent.ROLL_OUT, onRotatorRollOut);
            rotator.addEventListener(MouseEvent.DOUBLE_CLICK, onRotatorDoubleClick);
            
            zoomer.addEventListener(MouseEvent.MOUSE_OVER, onZoomerOver);
            zoomer.addEventListener(MouseEvent.MOUSE_DOWN, onZoomerDown);
            zoomer.addEventListener(MouseEvent.ROLL_OUT, onZoomerRollOut);
            
            stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
            
            dispatcher.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onCanvasTransformationFinished);
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
        
        private function start():void
        {
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMove);
            
            if(isRotatorDown)
                last = globalPointCenteredOnCanvasCenter;
            else if(isZoomerDown)
                last = new Point(zoomer.mouseX, zoomer.mouseY);
            else
                last = globalPointInTweenTarget;
        }
        
        private function stop():void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
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
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_STARTED));
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
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_STARTED));
        }
        
        private function scaleByTween(delta:Number, lock:Point=null):void
        {
            scaleToTween(transformationTarget.scale * delta, lock);
        }
        
        private function scaleToTween(scale:Number, lock:Point=null):void
        {
            scale = Math.max(maxScale, Math.min(minScale, scale));
            doTween(NaN, NaN, scale, NaN, onScaleToTweenUpdate(lock));
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_STARTED));
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
        }
        
        private function onTweenComplete():void
        {
            dispatcher.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
        }
        
        private function onBoardOver(event:MouseEvent):void
        {
            if(event.relatedObject == zoomer)
                isZoomerOver = false;
            if(event.relatedObject == rotator)
                isRotatorOver = false;
        }
        
        private function onBoardDown(event:MouseEvent):void
        {
            start();
            isMouseDown = true;
        }
        
        private function onBoardRollOver(event:MouseEvent):void
        {
            isBoardOver = true;
        }
        
        private function onBoardRollOut(event:MouseEvent):void
        {
            isBoardOver = false;
        }
        
        private function onBoardDoubleClick(event:MouseEvent):void
        {
            scaleToTween(minScale, globalPointOnCanvas);
        }
        
        private function onBoardWheel(event:MouseEvent):void
        {
            const delta:Number = 1.25; 
            scaleByTween(event.delta < 0 ? 1 / delta : delta, globalPointOnCanvas);
        }
        
        private function onRotatorOver(event:MouseEvent):void
        {
            if(running)
                return;
            isRotatorOver = true;
        }
        
        private function onRotatorDown(event:MouseEvent):void
        {
            isRotatorDown = true;
            start();
        }
        
        private function onRotatorRollOut(event:MouseEvent):void
        {
            isRotatorOver = false;
        }
        
        private function onRotatorDoubleClick(event:MouseEvent):void
        {
            rotateToTween(0);
        }
        
        private function onZoomerOver(event:MouseEvent):void
        {
            if(running)
                return;
            isZoomerOver = true;
        }
        
        private function onZoomerDown(event:MouseEvent):void
        {
            isZoomerDown = true;
            start();
        }
        
        private function onZoomerRollOut(event:MouseEvent):void
        {
            isZoomerOver = false;
        }
        
        private function onStageMove(event:MouseEvent):void
        {
            if(isRotatorDown)
            {
                var position:Point = globalPointCenteredOnCanvasCenter;
                var rad1:Number = Math.atan2(last.y, last.x);
                var rad2:Number = Math.atan2(position.y, position.x);
                rotateByTween(rad2 - rad1);
                last = position;
            }
            else if(isZoomerDown)
            {
                scaleByTween(1 - (zoomer.mouseY - last.y) / 200);
                last = new Point(zoomer.mouseX, zoomer.mouseY);
            }
            else
            {
                var current:Point = globalPointInTweenTarget;
                moveByTween(last.x - current.x, last.y - current.y);
                last = globalPointInTweenTarget;
            }
        }
        
        private function onStageUp(event:MouseEvent):void
        {
            stop();
            isMouseDown = false;
            isRotatorDown = false;
            isZoomerDown = false;
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
        
        private function onCanvasTransformationFinished(event:CanvasEvent):void
        {
            updateTransformation();
        }
    }
}