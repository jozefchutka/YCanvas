package sk.yoz.ycanvas.demo.explorer.view
{
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    
    public class ViewPortSprite extends Sprite
    {
        public static const ALIGN_TOP_LEFT:uint = 0;
        public static const ALIGN_TOP_CENTER:uint = 1;
        public static const ALIGN_TOP_RIGHT:uint = 2;
        public static const ALIGN_MIDDLE_LEFT:uint = 3;
        public static const ALIGN_MIDDLE_CENTER:uint = 4;
        public static const ALIGN_MIDDLE_RIGHT:uint = 5;
        public static const ALIGN_BOTTOM_LEFT:uint = 6;
        public static const ALIGN_BOTTOM_CENTER:uint = 7;
        public static const ALIGN_BOTTOM_RIGHT:uint = 8;
        
        private var align:uint = 0;
        
        public function ViewPortSprite(align:uint):void
        {
            this.align = align;
        }
        
        private function get isTop():Boolean
        {
            return align == ALIGN_TOP_CENTER
                || align == ALIGN_TOP_LEFT
                || align == ALIGN_TOP_RIGHT;
        }
        
        private function get isMiddle():Boolean
        {
            return align == ALIGN_MIDDLE_CENTER
                || align == ALIGN_MIDDLE_LEFT
                || align == ALIGN_MIDDLE_RIGHT;
        }
        
        private function get isBottom():Boolean
        {
            return align == ALIGN_BOTTOM_CENTER
                || align == ALIGN_BOTTOM_LEFT
                || align == ALIGN_BOTTOM_RIGHT;
        }
        
        private function get isLeft():Boolean
        {
            return align == ALIGN_TOP_LEFT
                || align == ALIGN_MIDDLE_LEFT
                || align == ALIGN_BOTTOM_LEFT;
        }
        
        private function get isCenter():Boolean
        {
            return align == ALIGN_TOP_CENTER
                || align == ALIGN_MIDDLE_CENTER
                || align == ALIGN_BOTTOM_CENTER;
        }
        
        private function get isRight():Boolean
        {
            return align == ALIGN_TOP_RIGHT
                || align == ALIGN_MIDDLE_RIGHT
                || align == ALIGN_BOTTOM_RIGHT;
        }
        
        private function get positionXFactor():Number
        {
            if(isLeft)
                return 0;
            if(isCenter)
                return .5;
            return 1;
        }
        
        private function get positionYFactor():Number
        {
            if(isTop)
                return 0;
            if(isMiddle)
                return .5;
            return 1;
        }
        
        public function set viewPort(value:Rectangle):void
        {
            x = value.left + positionXFactor * value.width;
            y = value.top + positionYFactor * value.height;
        }
    }
}
