package sk.yoz.ycanvas.demo.starlingComponent.events
{
    import flash.events.Event;
    
    import sk.yoz.ycanvas.demo.starlingComponent.partitions.Partition;
    
    public class PartitionEvent extends Event
    {
        public static const LOADED:String = "partitionLoaded";
        
        private var _partition:Partition;
        
        public function PartitionEvent(type:String, partition:Partition)
        {
            super(type, false, true);
            
            _partition = partition;
        }
        
        public function get partition():Partition
        {
            return _partition;
        }
        
        override public function clone():Event
        {
            return new PartitionEvent(type, partition);
        }
    }
}