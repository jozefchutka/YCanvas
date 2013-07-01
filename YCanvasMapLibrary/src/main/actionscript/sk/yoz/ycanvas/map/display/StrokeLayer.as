package sk.yoz.ycanvas.map.display
{
    public class StrokeLayer extends MapLayer
    {
        private var list:Vector.<MapStroke> = new Vector.<MapStroke>;
        
        public var autoUpdateThickness:Boolean = true;
        
        override public function set scale(value:Number):void
        {
            if(scale == value)
                return;
            
            super.scale = value;
            if(autoUpdateThickness)
                updateThickness();
        }
        
        public function updateThickness():void
        {
            for(var i:uint = list.length; i--;)
            {
                var item:MapStroke = list[i];
                item.thickness = item.originalThickness / scale;
                if(!item.autoUpdate)
                    item.update();
            }
        }
        
        public function add(item:MapStroke):void
        {
            item.thickness = item.originalThickness / scale;
            if(!item.autoUpdate)
                item.update();
            list.push(item);
            addChild(item);
        }
        
        public function remove(item:MapStroke):void
        {
            list.splice(list.indexOf(item), 1);
            removeChild(item);
        }
    }
}