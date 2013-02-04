package sk.yoz.ycanvas.demo.explorer.view
{
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    
    public class Board extends ViewPortSprite
    {
        public function Board()
        {
            super(ViewPortSprite.ALIGN_TOP_LEFT);
        }
        
        override public function set viewPort(value:Rectangle):void
        {
            super.viewPort = value;
            graphics.clear();
            graphics.beginFill(0x0, 0);
            graphics.drawRect(0, 0, value.width, value.height);
            graphics.endFill();
        }
    }
}