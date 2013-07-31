package sk.yoz.ycanvas.map.display
{
    import starling.display.DisplayObject;

    /**
    * A map layer extension to be used as a marker container. Marker real/global
    * size remains the same no matter the YCanvas transformation is. Marker 
    * global rotation is 0.
    */
    public class MarkerLayer extends MapLayer
    {
        private var list:Vector.<DisplayObject> = new Vector.<DisplayObject>;
        
        /**
        * @inheritDoc
        */
        override public function set rotation(value:Number):void
        {
            if(rotation == value)
                return;
            
            super.rotation = value;
            for(var i:uint = list.length; i--;)
                list[i].rotation = -rotation;
        }
        
        /**
        * @inheritDoc
        */
        override public function set scale(value:Number):void
        {
            if(scale == value)
                return;
            
            super.scale = value;
            for(var i:uint = list.length; i--;)
                list[i].scaleX = list[i].scaleY = 1 / scale;
        }
        
        /**
        * Adds any Starling DisplayObject as a marker.
        */
        public function add(item:DisplayObject):void
        {
            item.scaleX = item.scaleY = 1 / scale;
            item.rotation = -rotation;
            list.push(item);
            addChild(item);
        }
        
        /**
        * Removes previously added marker.
        */
        public function remove(item:DisplayObject):void
        {
            list.splice(list.indexOf(item), 1);
            removeChild(item);
        }
    }
}