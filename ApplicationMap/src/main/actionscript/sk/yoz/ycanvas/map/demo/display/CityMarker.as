package sk.yoz.ycanvas.map.demo.display
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    
    import feathers.controls.Label;
    
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.textures.Texture;
    
    public class CityMarker extends Sprite
    {
        private static const POINT_SIZE:uint = 10;
        
        private var _texture:Texture;
        private var name:String
        private var label:Label;
        private var image:Image;
        
        public function CityMarker(name:String)
        {
            this.name = name;
            
            super();
            
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        private function get texture():Texture
        {
            if(!_texture)
            {
                var shape:Shape = new Shape;
                shape.graphics.beginFill(0xff0000);
                shape.graphics.drawCircle(POINT_SIZE / 2, POINT_SIZE / 2, POINT_SIZE / 2 - 1);
                shape.graphics.endFill();
                
                var bitmapData:BitmapData = new BitmapData(POINT_SIZE, POINT_SIZE, true, 0);
                bitmapData.draw(shape);
                
                _texture = Texture.fromBitmapData(bitmapData, true);
            }
            
            return _texture;
        }
        
        override public function dispose():void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            super.dispose();
        }
        
        private function onAddedToStage():void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            
            label = new Label;
            label.text = name;
            addChild(label);
            label.validate();
            label.x = -label.width / 2;
            label.y = POINT_SIZE / 2;
            label.flatten();
            
            image = new Image(texture);
            image.x = -texture.width / 2;
            image.y = -texture.height / 2;
            addChild(image);
        }
    }
}