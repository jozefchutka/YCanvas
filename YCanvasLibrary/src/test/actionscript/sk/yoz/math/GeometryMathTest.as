package sk.yoz.math
{
    import flexunit.framework.Assert;

    public class GeometryMathTest
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
        public function customPoints_angleOf3Points_equalsExpected():void
        {
            equals(0, GeometryMath.angleOf3Points(0, 0, 1, 1, 1, 1));
            equals(Math.PI / 2, GeometryMath.angleOf3Points(0, 0, 1, 0, 0, 1));
            equals(Math.PI / 2, GeometryMath.angleOf3Points(0, 0, 0, 1, 1, 0));
            equals(Math.PI / 4, GeometryMath.angleOf3Points(0, 0, 1, 1, 0, 1));
            equals(Math.PI / 4, GeometryMath.angleOf3Points(0, 0, 0, 1, 1, 1));
            equals(Math.PI / 2, GeometryMath.angleOf3Points(0, 0, -1, 0, 0, -1));
            equals(Math.PI / 4, GeometryMath.angleOf3Points(0, 0, -1, -1, 0, -1));
            equals(Math.PI / 2, GeometryMath.angleOf3Points(10, 10, 11, 10, 10, 11));
            equals(Math.PI / 4, GeometryMath.angleOf3Points(10, 10, 11, 11, 10, 11));
            equals(Math.PI, GeometryMath.angleOf3Points(10, 10, 0, 0, 20, 20));
        }
        
        private function equals(expected:Number, result:Number):void
        {
            Assert.assertEquals(floor(expected), floor(result));
        }
        
        private function floor(source:Number):Number
        {
            return Math.floor(source * 100000) / 100000;
        }
    }
}