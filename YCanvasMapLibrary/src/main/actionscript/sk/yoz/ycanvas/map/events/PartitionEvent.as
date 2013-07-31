package sk.yoz.ycanvas.map.events
{
    import flash.events.Event;
    
    import sk.yoz.ycanvas.map.partitions.Partition;
    
    /**
    * An event with partition reference.
    */
    public class PartitionEvent extends Event
    {
        /**
        * Partition dispatches this evet type when loaded.
        */
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