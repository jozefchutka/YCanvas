package sk.yoz.ycanvas.demo.remotair
{
    import com.greensock.TweenMax;
    
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.events.TimerEvent;
    import flash.events.TouchEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.ui.Keyboard;
    import flash.utils.Timer;
    
    import sk.yoz.remotair.events.GenericConnectorEvent;
    import sk.yoz.remotair.events.RemotairEvent;
    import sk.yoz.remotair.net.GenericConnector;
    import sk.yoz.remotair.net.Receiver;
    import sk.yoz.touch.TransitionMultitouch;
    import sk.yoz.touch.events.TwoFingerEvent;
    import sk.yoz.touch.simulator.Layer;
    import sk.yoz.touch.simulator.TouchPointOptim;
    import sk.yoz.ycanvas.AbstractYCanvas;
    import sk.yoz.ycanvas.utils.TransformationUtils;

    public class TransformationManager extends EventDispatcher
    {
        public var simulator:sk.yoz.touch.simulator.Layer = new sk.yoz.touch.simulator.Layer;
        
        private var renderTimer:Timer = new Timer(500, 1);
        private var multitouch:TransitionMultitouch = new TransitionMultitouch;
        private var canvas:AbstractYCanvas;
        private var transitionDuration:Number = 1;
        private var last:Point;
        private var transitionTarget:Point = new Point;
        private var transition:Point = new Point;
        private var point1:TouchPointOptim = new TouchPointOptim(0, 0xff0000);
        private var point2:TouchPointOptim = new TouchPointOptim(1, 0x00ff00);
        private var remotairWidth:uint = 800;
        private var remotairHeight:uint = 600;
        private var textField:TextField = new TextField;
        private var receiver:Receiver = new Receiver(
            GenericConnector.HANDSHAKE_URL,
            GenericConnector.DEVELOPER_KEY,
            GenericConnector.CHANNEL_SERVICE);
        
        public function TransformationManager(canvas:AbstractYCanvas)
        {
            this.canvas = canvas;
            resetTransitionTarget();
            
            renderTimer.addEventListener(TimerEvent.TIMER_COMPLETE, render);
            
            multitouch.attach(simulator);
            multitouch.transitionDuration = transitionDuration;
            
            simulator.addTarget(simulator);
            simulator.addEventListener(Event.ADDED_TO_STAGE, onSimulatorAddedToStage);
            simulator.addEventListener(TwoFingerEvent.SCALE_AND_ROTATE, onSimulatorScaleAndRotate);
            simulator.addEventListener(TouchEvent.TOUCH_BEGIN, onSimulatorTouchBegin);
            simulator.addEventListener(TouchEvent.TOUCH_MOVE, onSimulatorTouchMove, false, 1);
            simulator.addEventListener(TouchEvent.TOUCH_END, onSimulatorTouchEnd);
            
            receiver.addEventListener(GenericConnectorEvent.PEER_CONNECTED, onPeerConneceted);
            receiver.addEventListener(GenericConnectorEvent.PEER_DISCONNECTED, onPeerDisconneceted);
            receiver.addEventListener(GenericConnectorEvent.NET_DISCONNECTED, onNetDisconneceted);
            receiver.touchEvents.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchRecieved);
            receiver.touchEvents.addEventListener(TouchEvent.TOUCH_END, onTouchRecieved);
            receiver.touchEvents.addEventListener(TouchEvent.TOUCH_MOVE, onTouchRecieved);
            receiver.remotairEvents.addEventListener(RemotairEvent.STAGE_SIZE, onRemotairStageSize);
        }
        
        private function get stage():Stage
        {
            return simulator.stage;
        }
        
        private function render(...rest):void
        {
            dispatchEvent(new Event(Event.RENDER));
        }
        
        private function minifyRotation(rotation:Number):Number
        {
            while(rotation > Math.PI)   rotation -= Math.PI * 2;
            while(rotation < -Math.PI)  rotation += Math.PI * 2;
            return rotation;
        }
        
        private function renderLater():void
        {
            if(renderTimer.running)
                return;
            
            renderTimer.reset();
            renderTimer.start();
        }
        
        private function connect(channel:String):void
        {
            receiver.connectChannel(channel);
        }
        
        private function killTween():void
        {
            TweenMax.killTweensOf(transition);
        }
        
        private function getGlobalPointInTweenTarget(globalPoint:Point):Point
        {
            var point:Point = canvas.globalToViewPort(globalPoint);
            var matrix:Matrix = canvas.getConversionMatrix(
                transitionTarget, canvas.scale, canvas.rotation, canvas.viewPort);
            matrix.invert();
            return matrix.transformPoint(point);
        }
        
        private function resetTransitionTarget():void
        {
            transitionTarget = canvas.center.clone();
        }
        
        private function onSimulatorScaleAndRotate(event:TwoFingerEvent):void
        {
            if(event.scale == 1 && event.rotation == 0)
                return;
            
            TransformationUtils.rotateScaleTo(canvas, 
                canvas.rotation + minifyRotation(event.rotation), 
                canvas.scale * event.scale, 
                canvas.globalToCanvas(event.lock));
            resetTransitionTarget();
            renderLater();
        }
        
        private function onSimulatorAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onSimulatorAddedToStage);
            
            simulator.buttonsPosition = sk.yoz.touch.simulator.Layer.BUTTONS_POSITION_RIGHT;
            
            point1.x = stage.stageWidth * 1 / 3;
            point1.y = stage.stageHeight * 1 / 2;
            simulator.addPoint(point1);
            
            point2.x = stage.stageWidth * 2 / 3;
            point2.y = stage.stageHeight * 1 / 2;
            simulator.addPoint(point2);
            
            textField.type = TextFieldType.INPUT;
            textField.background = true;
            textField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            textField.width = 50;
            textField.height = 20;
            textField.y = 10;
            textField.x = stage.stageWidth - textField.width - 10;
            simulator.addChild(textField);
        }
        
        private function onSimulatorTouchBegin(event:TouchEvent):void
        {
            killTween();
            resetTransitionTarget();
            last = getGlobalPointInTweenTarget(multitouch.getPoint(event));
        }
        
        private function onSimulatorTouchMove(event:TouchEvent):void
        {
            if(multitouch.countFingers != 1)
                return killTween();
            
            multitouch.killTweens();
            killTween();
            var point:Point = multitouch.getPoint(event);
            var current:Point = getGlobalPointInTweenTarget(point);
            if(!last)
            {
                last = current;
                return;
            }
            
            transitionTarget.x += last.x - current.x;
            transitionTarget.y += last.y - current.y;
            transition.x = canvas.center.x;
            transition.y = canvas.center.y;
            TweenMax.to(transition, transitionDuration, {
                x:transitionTarget.x, y:transitionTarget.y, 
                onUpdate:function():void
                {
                    TransformationUtils.moveTo(canvas, transition);
                    renderLater();
                }});
            
            last = getGlobalPointInTweenTarget(point);
        }
        
        private function onSimulatorTouchEnd(event:TouchEvent):void
        {
            resetTransitionTarget();
            last = null;
        }
        
        private function onTouchRecieved(event:TouchEvent):void
        {
            var clone:TouchEvent = event.clone() as TouchEvent;
            clone.localX = event.localX * stage.stageWidth / remotairWidth;
            clone.localY = event.localY * stage.stageHeight / remotairHeight;
            simulator.dispatchEvent(clone);
            
            if(event.isPrimaryTouchPoint)
            {
                point1.x = clone.localX;
                point1.y = clone.localY;
            }
            else
            {
                point2.x = clone.localX;
                point2.y = clone.localY;
            }
        }
        
        private function onKeyUp(event:KeyboardEvent):void
        {
            if(event.keyCode == Keyboard.ENTER)
            {
                stage.focus = null;
                textField.visible = false;
                connect(textField.text);
            }
        }
        
        private function onPeerConneceted(event:GenericConnectorEvent):void
        {
            trace("connected");
        }
        
        private function onPeerDisconneceted(event:GenericConnectorEvent):void
        {
            textField.visible = true;
            receiver.disconnect();
        }
        
        private function onNetDisconneceted(event:GenericConnectorEvent):void
        {
            textField.visible = true;
        }
        
        private function onRemotairStageSize(event:RemotairEvent):void
        {
            remotairWidth = event.data.width;
            remotairHeight = event.data.height;
        }
    }
}