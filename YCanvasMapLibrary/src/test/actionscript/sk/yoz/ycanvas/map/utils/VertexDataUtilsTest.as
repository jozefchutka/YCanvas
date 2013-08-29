package sk.yoz.ycanvas.map.utils
{
    import flexunit.framework.Assert;
    
    import sk.yoz.ycanvas.map.valueObjects.PartialBounds;
    
    import starling.utils.VertexData;

    public class VertexDataUtilsTest
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
        public function customVertexData_getBoundsList_equalsExpected():void
        {
            var vertexData:VertexData = StrokeUtils.pointsToVertexData(Vector.<Number>([0, 0, 10, 0, 10, 10, 0, 10]), 10);
            var indexData:Vector.<uint> = StrokeUtils.vertexDataToIndexData(vertexData);
            var result:Vector.<PartialBounds> = VertexDataUtils.getPartialBoundsList(vertexData, 4);
            
            Assert.assertEquals(6, result.length);
            Assert.assertEquals("(x=0, y=-5, w=10, h=10)", result[0].rectangle.toString());
            Assert.assertEquals("(x=5, y=-5, w=10, h=10)", result[1].rectangle.toString());
            Assert.assertEquals("(x=5, y=-3.061616997868383e-16, w=10, h=10)", result[2].rectangle.toString());
            Assert.assertEquals("(x=5, y=5, w=10, h=10)", result[3].rectangle.toString());
            Assert.assertEquals("(x=-6.123233995736766e-16, y=5, w=10, h=10)", result[4].rectangle.toString());
            Assert.assertEquals("(x=-6.123233995736766e-16, y=5, w=1.2246467991473533e-15, h=10)", result[5].rectangle.toString());
            Assert.assertEquals(
                vertexData.getBounds().toString(),
                PartialBoundsUtils.mergeListToRectangle(result).toString());
            
            Assert.assertEquals(0, result[0].vertexIndexMin);
            Assert.assertEquals(2, result[1].vertexIndexMin);
            Assert.assertEquals(4, result[2].vertexIndexMin);
            Assert.assertEquals(6, result[3].vertexIndexMin);
            Assert.assertEquals(8, result[4].vertexIndexMin);
            Assert.assertEquals(10, result[5].vertexIndexMin);
            
            Assert.assertEquals(0, result[0].indiceIndexMin);
            Assert.assertEquals(0, result[1].indiceIndexMin);
            Assert.assertEquals(6, result[2].indiceIndexMin);
            Assert.assertEquals(12, result[3].indiceIndexMin);
            Assert.assertEquals(18, result[4].indiceIndexMin);
            Assert.assertEquals(24, result[5].indiceIndexMin);
            
            Assert.assertEquals(3, result[0].vertexIndexMax);
            Assert.assertEquals(5, result[1].vertexIndexMax);
            Assert.assertEquals(7, result[2].vertexIndexMax);
            Assert.assertEquals(9, result[3].vertexIndexMax);
            Assert.assertEquals(11, result[4].vertexIndexMax);
            Assert.assertEquals(11, result[5].vertexIndexMax);
            
            Assert.assertEquals(9, result[0].indiceIndexMax);
            Assert.assertEquals(15, result[1].indiceIndexMax);
            Assert.assertEquals(21, result[2].indiceIndexMax);
            Assert.assertEquals(27, result[3].indiceIndexMax);
            Assert.assertEquals(27, result[4].indiceIndexMax);
            Assert.assertEquals(27, result[5].indiceIndexMax);
            
            //0      3      6      9      12     15     18     21     24      27
            //0,1,2, 1,2,3, 2,3,4, 3,4,5, 4,5,6, 5,6,7, 6,7,8, 7,8,9, 8,9,10, 9,10,11
            
            
            result = VertexDataUtils.getPartialBoundsList(vertexData, 6);
            Assert.assertEquals(3, result.length);
            Assert.assertEquals("(x=0, y=-5, w=15, h=10)", result[0].rectangle.toString());
            Assert.assertEquals("(x=5, y=-3.061616997868383e-16, w=10, h=15)", result[1].rectangle.toString());
            Assert.assertEquals("(x=-6.123233995736766e-16, y=5, w=10, h=10)", result[2].rectangle.toString());
            
            Assert.assertEquals(
                vertexData.getBounds().toString(),
                PartialBoundsUtils.mergeListToRectangle(result).toString());
            
            Assert.assertEquals(0, result[0].vertexIndexMin);
            Assert.assertEquals(4, result[1].vertexIndexMin);
            Assert.assertEquals(8, result[2].vertexIndexMin);
            
            Assert.assertEquals(0, result[0].indiceIndexMin);
            Assert.assertEquals(6, result[1].indiceIndexMin);
            Assert.assertEquals(18, result[2].indiceIndexMin);
            
            Assert.assertEquals(5, result[0].vertexIndexMax);
            Assert.assertEquals(9, result[1].vertexIndexMax);
            Assert.assertEquals(11, result[2].vertexIndexMax);
            
            Assert.assertEquals(15, result[0].indiceIndexMax);
            Assert.assertEquals(27, result[1].indiceIndexMax);
            Assert.assertEquals(27, result[2].indiceIndexMax);
            
            result = VertexDataUtils.getPartialBoundsList(vertexData, 8);
            Assert.assertEquals(2, result.length);
            Assert.assertEquals("(x=0, y=-5, w=15, h=15)", result[0].rectangle.toString());
            Assert.assertEquals("(x=-6.123233995736766e-16, y=5, w=15, h=10)", result[1].rectangle.toString());
            
            Assert.assertEquals(
                vertexData.getBounds().toString(),
                PartialBoundsUtils.mergeListToRectangle(result).toString());
            
            Assert.assertEquals(0, result[0].vertexIndexMin);
            Assert.assertEquals(6, result[1].vertexIndexMin);
            
            Assert.assertEquals(0, result[0].indiceIndexMin);
            Assert.assertEquals(12, result[1].indiceIndexMin);
            
            Assert.assertEquals(7, result[0].vertexIndexMax);
            Assert.assertEquals(11, result[1].vertexIndexMax);
            
            Assert.assertEquals(21, result[0].indiceIndexMax);
            Assert.assertEquals(27, result[1].indiceIndexMax);
        }
    }
}