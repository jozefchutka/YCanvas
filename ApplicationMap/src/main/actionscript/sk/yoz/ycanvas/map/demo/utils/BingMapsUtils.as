/* Inspired by: 
http://msdn.microsoft.com/en-us/library/bb259689.aspx
*/
package sk.yoz.ycanvas.map.demo.utils
{
    import sk.yoz.ycanvas.map.demo.valueObjects.BingMapsTileInfo;

    public class BingMapsUtils
    {
        public static function tileXYToQuadKey(tileX:uint, tileY:uint, levelOfDetail:uint):String
        {
            var quadKey:String = "";
            for(var i:uint = levelOfDetail; i > 0; i--)
            {
                var digit:uint = 0;
                var mask:uint = 1 << (i - 1);
                if((tileX & mask) != 0)
                {
                    digit++;
                }
                if((tileY & mask) != 0)
                {
                    digit++;
                    digit++;
                }
                quadKey += digit;
            }
            return quadKey;
        }
        
        public static function quadKeyToTileXY(quadKey:String):BingMapsTileInfo
        {
            var result:BingMapsTileInfo = new BingMapsTileInfo;
            result.tileX = 0;
            result.tileY = 0;
            result.levelOfDetail = quadKey.length;
            for(var i:uint = result.levelOfDetail; i > 0; i--)
            {
                var mask:uint = 1 << (i - 1);
                switch(quadKey.charAt(result.levelOfDetail - i))
                {
                    case '0':
                        break;
                    
                    case '1':
                        result.tileX |= mask;
                        break;
                    
                    case '2':
                        result.tileY |= mask;
                        break;
                    
                    case '3':
                        result.tileX |= mask;
                        result.tileY |= mask;
                        break;
                    
                    default:
                        throw new Error("Invalid QuadKey digit sequence.");
                }
            }
            return result;
        }
    }
}