package sk.yoz.ycanvas.demo.markers
{
    public class Utils
    {
        public static function getPow(value:uint):uint
        {
            var i:uint = 0;
            while(value > 1)
            {
                value /= 2;
                i++;
            }
            return i;
        }
    }
}