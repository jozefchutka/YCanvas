package sk.yoz.ycanvas.demo.markers.view
{
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
    import sk.yoz.ycanvas.demo.markers.Assets;
    import sk.yoz.ycanvas.demo.markers.events.ModeEvent;
    import sk.yoz.ycanvas.demo.markers.modes.Mode;
    
    public class Buttons extends Sprite
    {
        public function Buttons()
        {
            add(Assets.BUTTON_MAPQUEST_CLASS, Mode.MAPQUEST);
            add(Assets.BUTTON_ARCGIS_CLASS, Mode.ARCGIS);
            add(Assets.BUTTON_OPENSTREETMAPS_CLASS, Mode.OPENSTREETMAPS);
        }
        
        private function add(buttonClass:Class, mode:Mode):void
        {
            var sprite:Sprite = new Sprite;
            var bitmap:Bitmap = new buttonClass;
            if(numChildren)
                sprite.x = getChildAt(numChildren - 1).x 
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