package sk.yoz.ycanvas.map.display
{
    import starling.display.DisplayObject;

    public class MarkerLayer extends MapLayer
    {
        private var list:Vector.<DisplayObject> = new Vector.<DisplayObject>;
        
        override public function set rotation(value:Number):void
        {
            if(rotation == value)
                return;
            
            super.rotation = value;
            for(var i:uint = list.length; i--;)
                list[i].rotation = -rotation;
        }
        
        override public function set scale(value:Number):void
        {
            if(scale == value)
                return;
            
            super.scale = value;
            for(var i:uint = list.length; i--;)
                list[i].scaleX = list[i].scaleY = 1 / scale;
        }
        
        public function add(item:DisplayObject):void
        {
            item.scaleX = item.scaleY = 1 / scale;
            item.rotation = -rotation;
            list.push(item);
            addChild(item);
        }
        
        public function remove(item:DisplayObject):void
        {
            list.splice(list.indexOf(item), 1);
            removeChild(item);
        }
    }
}