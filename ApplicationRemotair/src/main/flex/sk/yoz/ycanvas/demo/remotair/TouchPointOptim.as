package sk.yoz.ycanvas.demo.remotair
{
    import sk.yoz.touch.simulator.TouchPoint;
    
    public class TouchPointOptim extends TouchPoint
    {
        private var dispatchedX:Number = NaN;
        private var dispatchedY:Number = NaN;
        
        public function TouchPointOptim(touchPointID:uint=0, color:uint=0xff0000)
        {
            super(touchPointID, color);
        }
        
        override public function dispatch(type:String):void
        {
            if(dispatchedX != x || dispatchedY != y)
                super.dispatch(type);
            
            dispatchedX = x;
            dispatchedY = y;
        }
    }
}