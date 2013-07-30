package sk.yoz.ycanvas.valueObjects
{
    import flash.geom.Rectangle;

    /**
    * A helper object for hitTest() optimization.
    */
    public class PartialBounds
    {
        public var rectangle:Rectangle;
        public var vertexIndexMin:uint;
        public var vertexIndexMax:uint;
        public var indiceIndexMin:uint;
        public var indiceIndexMax:uint;
    }
}