package sk.yoz.ycanvas.demo.explorer.modes.onboard
{
    import flash.display.BitmapData;
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.Partition;
    
    public class OnBoardPartition extends Partition
    {
        private static var BACKGROUND:BitmapData;
        
        public function OnBoardPartition(layer:Layer, x:int, y:int, 
            requestedWidth:uint, requestedHeight:uint, dispatcher:IEventDispatcher)
        {
            if(!BACKGROUND)
                BACKGROUND = new BitmapData(requestedWidth, requestedHeight, false, 0xffffff);
            
            super(layer, x, y, requestedWidth, requestedHeight, dispatcher);
        }
        
        override protected function get url():String
        {
            return "http://onboard.yoz.sk/board/_default_/" 
                + layer.level + "/" + x + "." + y + "." 
                + (layer.level == 1 ? "png" : "jpeg");
        }
        
        override protected function updateTexture():void
        {
            var bitmapData:BitmapData = BACKGROUND.clone();
            this.bitmapData && bitmapData.draw(this.bitmapData);
            texture = bitmapData;
        }
    }
}