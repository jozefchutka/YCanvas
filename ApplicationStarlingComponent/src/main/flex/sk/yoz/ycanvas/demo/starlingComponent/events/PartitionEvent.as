package sk.yoz.ycanvas.demo.starlingComponent.events
{
    import flash.events.Event;
    
    import sk.yoz.ycanvas.demo.starlingComponent.partitions.AbstractPartition;
    
    public class PartitionEvent extends Event
    {
        public static const LOADED:String = "partitionLoaded";
        
        private var _partition:AbstractPartition;
        
        public function PartitionEvent(type:String, partition:AbstractPartition)
        {
            super(type, false, true);
            
            _partition = partition;
        }
        
        public function get partition():AbstractPartition
        {
            return _partition;
        }
        
        override public function clone():Event
        {
            return new PartitionEvent(type, partition);
        }
    }
}