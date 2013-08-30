package sk.yoz.touch.simulator
{
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    public class Button extends Sprite
    {
        public var point:TouchPoint;
        
        public function Button(point:TouchPoint)
        {
            this.point = point;
            
            graphics.beginFill(point.color);
            graphics.drawRect(0, 0, 10, 10);
            graphics.endFill();
            
            addEventListener(MouseEvent.CLICK, onClick);
        }
        
        private function onClick(event:MouseEvent):void
        {
            point.active = !point.active;
        }
    }
}