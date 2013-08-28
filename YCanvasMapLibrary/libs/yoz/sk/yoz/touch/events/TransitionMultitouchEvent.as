package sk.yoz.touch.events
{
    import flash.events.Event;
    
    public class TransitionMultitouchEvent extends Event
    {
        public static const TRANSITION_COMPLETE:String = "transitionMultitouchTransitionComplete";
        
        public function TransitionMultitouchEvent(type:String)
        {
            super(type, false, true);
        }
        
        override public function clone():Event
        {
            return new TransitionMultitouchEvent(type);
        }
    }
}