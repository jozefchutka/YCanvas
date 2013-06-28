package sk.yoz.ycanvas.stage3D.elements
{
    import flash.geom.Point;
    
    import flexunit.framework.Assert;
    
    import starling.utils.VertexData;

    public class StrokeTest
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
        public function twoPoints_pointsToVertexData_equalsExpected():void
        {
            var result:VertexData = Stroke.pointsToVertexData(Vector.<Number>([0, 0, 10, 0]), 10);
            
            Assert.assertEquals(4, result.numVertices);
            
            var point:Point = new Point;
            
            result.getPosition(0, point);
            Assert.assertEquals(0, point.x);
            Assert.assertEquals(-5, point.y);
            
            result.getPosition(1, point);
            Assert.assertEquals(0, point.x);
            Assert.assertEquals(5, point.y);
            
            result.getPosition(2, point);
            Assert.assertEquals(10, point.x);
            Assert.assertEquals(-5, point.y);
            
            result.getPosition(3, point);
            Assert.assertEquals(10, point.x);
            Assert.assertEquals(5, point.y);
        }
        
        [Test]
        public function fourPoints_pointsToVertexData_equalsExpected():void
        {
            var result:VertexData = Stroke.pointsToVertexData(Vector.<Number>([0, 0, 10, 0, 10, 10, 0, 10]), 10);
            
            Assert.assertEquals(12, result.numVertices);
            
            var point:Point = new Point;
            
            result.getPosition(0, point);
            Assert.assertEquals(0, point.x);
            Assert.assertEquals(-5, point.y);
            
            result.getPosition(1, point);
            Assert.assertEquals(0, point.x);
            Assert.assertEquals(5, point.y);
            
            result.getPosition(2, point);
            Assert.assertEquals(10, point.x);
            Assert.assertEquals(-5, point.y);
            
            result.getPosition(3, point);
            Assert.assertEquals(10, point.x);
            Assert.assertEquals(5, point.y);
            
            result.getPosition(4, point);
            Assert.assertEquals(15, point.x);
            Assert.assertEquals(0, Math.round(point.y));
            
            result.getPosition(5, point);
            Assert.assertEquals(5, point.x);
            Assert.assertEquals(0, Math.round(point.y));
            
            result.getPosition(10, point);
            Assert.assertEquals(0, Math.round(point.x));
            Assert.assertEquals(15, point.y);
            
            result.getPosition(11, point);
            Assert.assertEquals(0, Math.round(point.x));
            Assert.assertEquals(5, point.y);
        }
        
        [Test]
        public function inlinePoints_pointsToVertexData_equalsExpected():void
        {
            var result:VertexData = Stroke.pointsToVertexData(Vector.<Number>([0, 0, 5, 0, 10, 0]), 10);
            
            Assert.assertEquals(4, result.numVertices);
            
            var point:Point = new Point;
            
            result.getPosition(0, point);
            Assert.assertEquals(0, point.x);
            Assert.assertEquals(-5, point.y);
            
            result.getPosition(1, point);
            Assert.assertEquals(0, point.x);
            Assert.assertEquals(5, point.y);
            
            result.getPosition(2, point);
            Assert.assertEquals(10, point.x);
            Assert.assertEquals(-5, point.y);
            
            result.getPosition(3, point);
            Assert.assertEquals(10, point.x);
            Assert.assertEquals(5, point.y);
        }
        
        [Test]
        public function customVertexData_vertexDataToIndexData_equalsExpected():void
        {
            var vertexData:VertexData = Stroke.pointsToVertexData(Vector.<Number>([0, 0, 10, 0, 10, 10, 0, 10]), 10);
            var indexData:Vector.<uint> = Stroke.vertexDataToIndexData(vertexData, true);
            
            Assert.assertEquals(30, indexData.length);
            
            Assert.assertEquals(indexData[0], 0);
            Assert.assertEquals(indexData[1], 1);
            Assert.assertEquals(indexData[2], 2);
            
            Assert.assertEquals("0,1,2,1,2,3,2,3,4,3,4,5,4,5,6,5,6,7,6,7,8,7,8,9,8,9,10,9,10,11", indexData.join());
        }
    }
}