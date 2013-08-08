package sk.yoz.ycanvas.map.demo.utils
{
    import org.flexunit.asserts.assertEquals;
    
    import sk.yoz.ycanvas.map.demo.valueObjects.BingMapsTileInfo;

    public class BingMapsUtilsTest
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
        public function customQuadKey_quadKeyToTileXY_equalsExpected():void
        {
            var quadKey:String = "0320230133";
            var result:BingMapsTileInfo = BingMapsUtils.quadKeyToTileXY(quadKey);
            assertEquals(279, result.tileX);
            assertEquals(435, result.tileY);
            assertEquals(10, result.levelOfDetail);
        }
        
        [Test]
        public function customTile_tileXYToQuadKey_equalsExpected():void
        {
            var result:String = BingMapsUtils.tileXYToQuadKey(279, 435, 10);
            assertEquals("0320230133", result);
        }
    }
}