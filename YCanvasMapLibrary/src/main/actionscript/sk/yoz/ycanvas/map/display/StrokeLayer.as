package sk.yoz.ycanvas.map.display
{
    /**
    * A map layer extension to be used as a stroke container. Stroke 
    * real/global thickness remains the same no matter the YCanvas 
    * transformation is.
    */
    public class StrokeLayer extends MapLayer
    {
        private var list:Vector.<MapStroke> = new Vector.<MapStroke>;
        
        /**
        * If true, all strokes thickness get recalculated immediatly with 
        * YCanvas transformation. If false updateThickness() method must be 
        * called manualy. While thickness update executes a lot of calculation
        * and may decsrease performance when long strokes are rendered, the 
        * manual update after transformation is finished is a recommended
        * approach.
        */
        public var autoUpdateThickness:Boolean = true;
        
        /**
        * @inheritDoc
        */
        override public function set scale(value:Number):void
        {
            if(scale == value)
                return;
            
            super.scale = value;
            if(autoUpdateThickness)
                updateThickness();
        }
        
        /**
        * Recalculates the thickness of all strokes.
        */
        public function updateThickness():void
        {
            for(var i:uint = list.length; i--;)
            {
                var item:MapStroke = list[i];
                item.layerScale = scale;
                if(!item.autoUpdate)
                    item.update();
            }
        }
        
        /**
        * Adds a map stroke.
        */
        public function add(item:MapStroke):void
        {
            item.layerScale = scale;
            if(!item.autoUpdate)
                item.update();
            list.push(item);
            addChild(item);
        }
        
        /**
        * Removes prviously added map stroke.
        */
        public function remove(item:MapStroke):void
        {
            list.splice(list.indexOf(item), 1);
            removeChild(item);
        }
    }
}