package sk.yoz.ycanvas.utils
{
    import flash.geom.Rectangle;
    
    import flexunit.framework.Assert;
    
    import sk.yoz.ycanvas.valueObjects.PartialBounds;

    public class PartialBoundsUtilsTest
    {
        [Before]
        public function setUp():void
        {
        }
        
        [After]
        public function tearDown():void
        {
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        [Test]
        public function customList_merge_equalsExpected():void
        {
            var list:Vector.<PartialBounds> = Vector.<PartialBounds>([
                create(0, 0, 10, 10),        // 0, 0, 10, 10
                create(0, 10, 10, 10),       // 0, 0, 10, 20
                create(-1, -2, 5, 5)         // -1, -2, 11, 22
            ]);
            
            var result:Rectangle = PartialBoundsUtils.mergeListToRectangle(list);
            Assert.assertEquals("(x=-1, y=-2, w=11, h=22)", result.toString());
        }
        
        private function create(x:Number, y:Number, width:Number, height:Number):PartialBounds
        {
            var result:PartialBounds = new PartialBounds;
            result.rectangle = new Rectangle(x, y, width, height);
            return result;
        }
    }
}