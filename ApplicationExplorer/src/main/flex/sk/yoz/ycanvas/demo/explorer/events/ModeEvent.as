package sk.yoz.ycanvas.demo.explorer.events
{
    import flash.events.Event;
    
    import sk.yoz.ycanvas.demo.explorer.modes.Mode;
    
    public class ModeEvent extends Event
    {
        public static const CHANGE:String = "modeChange";
        
        private var _mode:Mode;
        
        public function ModeEvent(type:String, mode:Mode)
        {
            super(type, false, true);
            
            _mode = mode;
        }
        
        public function get mode():Mode
        {
            return _mode;
        }
        
        override public function clone():Event
        {
            return new ModeEvent(type, mode);
        }
    }
}