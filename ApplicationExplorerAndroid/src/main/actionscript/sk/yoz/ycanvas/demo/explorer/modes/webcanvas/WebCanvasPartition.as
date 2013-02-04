package sk.yoz.ycanvas.demo.explorer.modes.webcanvas
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.Partition;
    
    public class WebCanvasPartition extends Partition
    {
        public function WebCanvasPartition(layer:Layer, x:int, y:int, 
            requestedWidth:uint, requestedHeight:uint, dispatcher:IEventDispatcher)
        {
            super(layer, x, y, requestedWidth, requestedHeight, dispatcher);
        }
        
        override protected function get url():String
        {
            var correction:uint = (25 / layer.level - 1) / 2;
            var x:int = this.x / expectedWidth / layer.level - correction;
            var y:int = this.y / expectedHeight / layer.level - correction;
            var d:Number = new Date().time;
            var url:String = "http://webcanvas.com/php/" 
                + getZ(layer.level) + ".php?t=" 
                + (x < 0 ? "n" + (-x).toString() : x.toString()) + "_" 
                + (y < 0 ? "n" + (-y).toString() : y.toString()) 
                + "&" + d;
            var result:String = "http://ycanvas.yoz.sk/explorer/proxy.php?url=" + escape(url);
            return result;
        }
        
        private function getZ(level:uint):String
        {
            if(level == 1)
                return "t";
            if(level == 5)
                return "z";
            return "x";
        }
    }
}