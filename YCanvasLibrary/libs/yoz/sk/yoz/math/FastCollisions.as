package sk.yoz.math
{
    public class FastCollisions
    {
        public static function rectangles(
            r1p1x:Number, r1p1y:Number, r1p2x:Number, r1p2y:Number,
            r1p3x:Number, r1p3y:Number, r1p4x:Number, r1p4y:Number,
            r2p1x:Number, r2p1y:Number, r2p2x:Number, r2p2y:Number,
            r2p3x:Number, r2p3y:Number, r2p4x:Number, r2p4y:Number):Boolean
        {
            if(!isProjectedAxisCollision(r1p1x, r1p1y, r1p2x, r1p2y, 
                r2p1x, r2p1y, r2p2x, r2p2y, r2p3x, r2p3y, r2p4x, r2p4y))
                return false;
            
            if(!isProjectedAxisCollision(r1p2x, r1p2y, r1p3x, r1p3y, 
                r2p1x, r2p1y, r2p2x, r2p2y, r2p3x, r2p3y, r2p4x, r2p4y))
                return false;
            
            if(!isProjectedAxisCollision(r2p1x, r2p1y, r2p2x, r2p2y, 
                r1p1x, r1p1y, r1p2x, r1p2y, r1p3x, r1p3y, r1p4x, r1p4y))
                return false;
            
            if(!isProjectedAxisCollision(r2p2x, r2p2y, r2p3x, r2p3y, 
                r1p1x, r1p1y, r1p2x, r1p2y, r1p3x, r1p3y, r1p4x, r1p4y))
                return false;
            
            return true;
        }
        
        public static function isProjectedAxisCollision(
            b1x:Number, b1y:Number, b2x:Number, b2y:Number,
            p1x:Number, p1y:Number, p2x:Number, p2y:Number,
            p3x:Number, p3y:Number, p4x:Number, p4y:Number):Boolean
        {
            var x1:Number, x2:Number, x3:Number, x4:Number;
            var y1:Number, y2:Number, y3:Number, y4:Number;
            if(b1x == b2x)
            {
                x1 = x2 = x3 = x4 = b1x;
                y1 = p1y;
                y2 = p2y;
                y3 = p3y;
                y4 = p4y;
                
                if(b1y > b2y)
                {
                    if((y1 > b1y && y2 > b1y && y3 > b1y && y4 > b1y) || 
                       (y1 < b2y && y2 < b2y && y3 < b2y && y4 < b2y))
                        return false;
                }
                else
                {
                    if((y1 > b2y && y2 > b2y && y3 > b2y && y4 > b2y) ||
                       (y1 < b1y && y2 < b1y && y3 < b1y && y4 < b1y))
                        return false;
                }
                return true;
            }
            else if(b1y == b2y)
            {
                x1 = p1x;
                x2 = p2x;
                x3 = p3x;
                x4 = p4x;
                y1 = y2 = y3 = y4 = b1y;
            }
            else
            {
                var a:Number = (b1y - b2y) / (b1x - b2x);
                var ia:Number = 1 / a;
                var t1:Number = b2x * a - b2y;
                var t2:Number = 1 / (a + ia);
                
                x1 = (p1y + t1 + p1x * ia) * t2;
                x2 = (p2y + t1 + p2x * ia) * t2;
                x3 = (p3y + t1 + p3x * ia) * t2;
                x4 = (p4y + t1 + p4x * ia) * t2;
                
                y1 = p1y + (p1x - x1) * ia;
                y2 = p2y + (p2x - x2) * ia;
                y3 = p3y + (p3x - x3) * ia;
                y4 = p4y + (p4x - x4) * ia;
            }
            
            if(b1x > b2x)
            {
                if((x1 > b1x && x2 > b1x && x3 > b1x && x4 > b1x) ||
                   (x1 < b2x && x2 < b2x && x3 < b2x && x4 < b2x))
                    return false;
            }
            else
            {
                if((x1 > b2x && x2 > b2x && x3 > b2x && x4 > b2x) ||
                   (x1 < b1x && x2 < b1x && x3 < b1x && x4 < b1x))
                    return false;
            }
            return true;
        }
        
        public static function pointInRectangle(px:Number, py:Number,
            r1x:Number, r1y:Number, r2x:Number, r2y:Number,
            r3x:Number, r3y:Number, r4x:Number, r4y:Number):Boolean
        {
            var a:Number, x:Number, y:Number;
            if(r1x == r2x)
            {
                x = r1x, y = py;
                if(y > (r1y > r2y ? r1y : r2y)) return false;
                if(y < (r1y < r2y ? r1y : r2y)) return false;
            }
            else if(r1y == r2y)
            {
                x = px, y = r1y;
            }
            else
            {
                a = (r1y - r2y) / (r1x - r2x);
                x = (py - r2y + r2x * a + px / a) / (a + 1 / a);
                y = py + (px - x) / a;
            }
            
            if(x > (r1x > r2x ? r1x : r2x)) return false;
            if(x < (r1x < r2x ? r1x : r2x)) return false;
            
            if(r2x == r3x)
            {
                x = r2x, y = py;
                if(y > (r2y > r3y ? r2y : r3y)) return false;
                if(y < (r2y < r3y ? r2y : r3y)) return false;
            }
            else if(r2y == r3y)
            {
                x = px, y = r2y;
            }
            else
            {
                a = (r2y - r3y) / (r2x - r3x);
                x = (py - r3y + r3x * a + px / a) / (a + 1 / a);
                y = py + (px - x) / a;
            }
            
            if(x > (r2x > r3x ? r2x : r3x)) return false;
            if(x < (r2x < r3x ? r2x : r3x)) return false;
            return true;
        }
        
        public static function pointInTriangle(px:Number, py:Number, 
            r1x:Number, r1y:Number, r2x:Number, r2y:Number, 
            r3x:Number, r3y:Number):Boolean
        {
            var dx:Number = px - r1x;
            var dy:Number = py - r1y;
            var b:Boolean = (r2x - r1x) * dy - (r2y - r1y) * dx > 0;
            
            if((r3x - r1x) * dy - (r3y - r1y) * dx > 0 == b)
                return false;
            
            if((r3x - r2x) * (py - r2y) - (r3y - r2y) * (px - r2x) > 0 != b)
                return false;
            
            return true;
        }
    }
}