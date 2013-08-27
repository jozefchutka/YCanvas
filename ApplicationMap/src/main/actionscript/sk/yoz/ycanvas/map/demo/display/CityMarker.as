package sk.yoz.ycanvas.map.demo.display
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.textures.Texture;
    
    public class CityMarker extends Image
    {
        private static const POINT_SIZE:uint = 10;
        
        private static var _shape:Shape;
        private static var _textField:TextField;
        
        public function CityMarker(name:String)
        {
            textField.text = name;
            var width:uint = textField.width;
            var height:uint = textField.height + POINT_SIZE;
            
            var bitmapData:BitmapData = new BitmapData(width, height, true, 0);
            bitmapData.draw(shape, new Matrix(1, 0, 0, 1, width / 2 - POINT_SIZE / 2, 0));
            bitmapData.draw(textField, new Matrix(1, 0, 0, 1, 0, POINT_SIZE));
            
            super(Texture.fromBitmapData(bitmapData, false, true));
            pivotX = bitmapData.width / 2;
            pivotY = POINT_SIZE / 2;
        }
        
        private function get shape():Shape
        {
            if(!_shape)
            {
                _shape = new Shape;
                _shape.graphics.beginFill(0xff0000);
                _shape.graphics.drawCircle(POINT_SIZE / 2, POINT_SIZE / 2, POINT_SIZE / 2 - 1);
                _shape.graphics.endFill();
            }
            
            return _shape;
        }
        
        private function get textField():TextField
        {
            if(!_textField)
            {
                _textField = new TextField;
                _textField.autoSize = TextFieldAutoSize.LEFT;
                _textField.textColor = 0xffffff;
            }
            
            return _textField;
        }
        
        override public function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
        {
            if (forTouch && (!visible || !touchable))
                return null;
            
            var x:Number = localPoint.x - pivotX;
            var y:Number = localPoint.y - pivotY;
            return x * x + y * y  < (POINT_SIZE * POINT_SIZE / 4) ? this : null;
        }
    }
}