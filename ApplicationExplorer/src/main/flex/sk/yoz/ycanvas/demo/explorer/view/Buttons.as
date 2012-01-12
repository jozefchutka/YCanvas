package sk.yoz.ycanvas.demo.explorer.view
{
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    import sk.yoz.ycanvas.demo.explorer.Assets;
    import sk.yoz.ycanvas.demo.explorer.events.ModeEvent;
    import sk.yoz.ycanvas.demo.explorer.modes.Mode;
    
    public class Buttons extends Sprite
    {
        public function Buttons()
        {
            add(Assets.BUTTON_ONBOARD_CLASS, Mode.ONBOARD);
            add(Assets.BUTTON_WALLOFFAME_CLASS, Mode.WALLOFFAME);
        }
        
        private function add(buttonClass:Class, mode:Mode):void
        {
            var sprite:Sprite = new Sprite;
            var bitmap:Bitmap = new buttonClass;
            if(numChildren)
                bitmap.x = getChildAt(numChildren - 1).x 
                    + getChildAt(numChildren - 1).width + 5;
            
            sprite.addChild(bitmap);
            sprite.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
            {
                dispatchEvent(new ModeEvent(ModeEvent.CHANGE, mode));
            });
            addChild(sprite);
        }
    }
}