package sk.yoz.ycanvas.demo.remotair
{
    import flash.events.Event;
    
    import sk.yoz.touch.simulator.Layer;
    import sk.yoz.touch.simulator.TouchPoint;
    
    public class TouchSimulator extends Layer
    {
        private var point1:TouchPoint = new TouchPoint(0, 0xff0000);
        private var point2:TouchPoint = new TouchPoint(1, 0x00ff00);
        
        public function TouchSimulator()
        {
            addTarget(this);
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
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
        }
    }
}