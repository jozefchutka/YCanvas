package sk.yoz.ycanvas.demo.remotair
{
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.TouchEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.ui.Keyboard;
    
    import sk.yoz.remotair.events.GenericConnectorEvent;
    import sk.yoz.remotair.events.RemotairEvent;
    import sk.yoz.remotair.net.GenericConnector;
    import sk.yoz.remotair.net.Receiver;
    import sk.yoz.touch.simulator.Layer;
    import sk.yoz.touch.simulator.TouchPoint;
    
    public class TouchSimulator extends Layer
    {
        private var point1:TouchPoint = new TouchPointOptim(0, 0xff0000);
        private var point2:TouchPoint = new TouchPointOptim(1, 0x00ff00);
        
        private var textField:TextField = new TextField;
        private var receiver:Receiver = new Receiver(
            GenericConnector.HANDSHAKE_URL,
            GenericConnector.DEVELOPER_KEY,
            GenericConnector.CHANNEL_SERVICE);
        
        private var remotairWidth:uint = 800;
        private var remotairHeight:uint = 600;
        
        public function TouchSimulator()
        {
            addTarget(this);
            
            receiver.addEventListener(GenericConnectorEvent.PEER_CONNECTED, onPeerConneceted);
            receiver.addEventListener(GenericConnectorEvent.PEER_DISCONNECTED, onPeerDisconneceted);
            receiver.addEventListener(GenericConnectorEvent.NET_DISCONNECTED, onNetDisconneceted);
            receiver.touchEvents.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchRecieved);
            receiver.touchEvents.addEventListener(TouchEvent.TOUCH_END, onTouchRecieved);
            receiver.touchEvents.addEventListener(TouchEvent.TOUCH_MOVE, onTouchRecieved);
            receiver.remotairEvents.addEventListener(RemotairEvent.STAGE_SIZE, onRemotairStageSize);
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        private function connect(channel:String):void
        {
            receiver.connectChannel(channel);
        }
        
        private function onTouchRecieved(event:TouchEvent):void
        {
            var clone:TouchEvent = event.clone() as TouchEvent;
            clone.localX = event.localX * stage.stageWidth / remotairWidth;
            clone.localY = event.localY * stage.stageHeight / remotairHeight;
            dispatchEvent(clone);
            
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
        
        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            
            buttonsPosition = BUTTONS_POSITION_RIGHT;
            
            point1.x = stage.stageWidth * 1 / 3;
            point1.y = stage.stageHeight * 1 / 2;
            addPoint(point1);
            
            point2.x = stage.stageWidth * 2 / 3;
            point2.y = stage.stageHeight * 1 / 2;
            addPoint(point2);
            
            textField.type = TextFieldType.INPUT;
            textField.background = true;
            textField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            textField.width = 50;
            textField.height = 20;
            textField.y = 10;
            textField.x = stage.stageWidth - textField.width - 10;
            addChild(textField);
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