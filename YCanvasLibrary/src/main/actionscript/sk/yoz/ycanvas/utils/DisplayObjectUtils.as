package sk.yoz.ycanvas.utils
{
    import flash.display.DisplayObject;
    import flash.geom.Matrix;

    public class DisplayObjectUtils
    {
        /**
        * Workaround for buggy DisplayObject.transform.concatednatedMatrix 
        * (related to cacheAsBitmap within parent scope). Read more and vote 
        * for a fix on https://bugbase.adobe.com/index.cfm?event=bug&id=2927826
        */
        public static function getConcatenatedMatrix(source:DisplayObject):
            Matrix
        {
            var result:Matrix = new Matrix;
            var scope:DisplayObject = source;
            while(scope)
            {
                result.concat(scope.transform.matrix);
                scope = scope.parent;
            }
            return result;
        }
    }
}