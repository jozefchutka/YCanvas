package sk.yoz.ycanvas.demo.explorer.modes.walloffame
{
    import flash.display.BitmapData;
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.Partition;
    
    import starling.textures.Texture;
    
    public class WallOfFamePartition extends Partition
    {
        public function WallOfFamePartition(layer:Layer, x:int, y:int, 
            requestedWidth:uint, requestedHeight:uint, dispatcher:IEventDispatcher)
        {
            super(layer, x, y, requestedWidth, requestedHeight, dispatcher);
        }
        
        override protected function get url():String
        {
            var level:uint = 2;
            if(layer.level == 3)
                level = 1;
            else if(layer.level == 9)
                level = 0;
            var x:int = this.x / expectedWidth / layer.level;
            var y:int = this.y / expectedHeight / layer.level;
            var rand:String = Math.round(new Date().time / 0xffffff).toString();
            var server:uint = Math.abs(x + y) % 10;
            var result:String = "http://img" + server + ".wall-of-fame.com/map/" 
                + level + "/" + x +"_" + y + ".jpg?rand=" + rand;
            return result;
        }
    }
}