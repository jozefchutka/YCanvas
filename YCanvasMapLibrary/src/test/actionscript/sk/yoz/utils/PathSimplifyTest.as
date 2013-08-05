package sk.yoz.utils
{
    import flash.geom.Point;
    
    import flexunit.framework.Assert;
    
    import simplify.Simplify;
    

    public class PathSimplifyTest
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
        public function customPoint_getSquareSegmentDistance_equalsExpected():void
        {
            var p:Point = new Point(0, 0);
            var p1:Point = new Point(1, 1);
            var p2:Point = new Point(2, 2);
            Assert.assertEquals(
                Simplify.getSquareSegmentDistance(p, p1, p2),
                PathSimplify.getSquareSegmentDistance(p.x, p.y, p1.x, p1.y, p2.x, p2.y));
            
            p = new Point(800.12, 20);
            p1 = new Point(10, 55.3);
            p2 = new Point(47.22, 87.21);
            Assert.assertEquals(
                Simplify.getSquareSegmentDistance(p, p1, p2),
                PathSimplify.getSquareSegmentDistance(p.x, p.y, p1.x, p1.y, p2.x, p2.y));
        }
        
        [Test]
        public function customPoints_simplifyDouglasPeucker_equalsExpected():void
        {
            var p0:Point, p1:Point, p2:Point, p3:Point, p4:Point, p5:Point;
            var points:Vector.<Point>;
            
            p0 = new Point(0, 0);
            p1 = new Point(1, 1);
            p2 = new Point(2, 2);
            points = Vector.<Point>([p0, p1, p2]);
            Assert.assertTrue(compareSimplifyDouglasPeucker(points));
            
            p0 = new Point(0, 0);
            p1 = new Point(1, 1);
            p2 = new Point(2, 2);
            p3 = new Point(3, 3);
            p4 = new Point(4, 4);
            p5 = new Point(5, 5);
            points = Vector.<Point>([p0, p1, p2, p3, p4, p5]);
            Assert.assertTrue(compareSimplifyDouglasPeucker(points));
            
            p0 = new Point(0, 0);
            p1 = new Point(1.1, 1);
            p2 = new Point(2, 2.1);
            p3 = new Point(3, 3);
            p4 = new Point(4.1, 4);
            p5 = new Point(5, 5.1);
            points = Vector.<Point>([p0, p1, p2, p3, p4, p5]);
            Assert.assertTrue(compareSimplifyDouglasPeucker(points));
        }
        
        [Test]
        public function customPoints_simplifyRadialDistance_equalsExpected():void
        {
            var p0:Point, p1:Point, p2:Point, p3:Point, p4:Point, p5:Point;
            var points:Vector.<Point>;
            
            p0 = new Point(0, 0);
            p1 = new Point(1, 1);
            p2 = new Point(2, 2);
            points = Vector.<Point>([p0, p1, p2]);
            Assert.assertTrue(compareSimplifyRadialDistance(points));
            
            p0 = new Point(0, 0);
            p1 = new Point(1, 1);
            p2 = new Point(2, 2);
            p3 = new Point(3, 3);
            p4 = new Point(4, 4);
            p5 = new Point(5, 5);
            points = Vector.<Point>([p0, p1, p2, p3, p4, p5]);
            Assert.assertTrue(compareSimplifyRadialDistance(points));
            
            p0 = new Point(0, 0);
            p1 = new Point(1.1, 1);
            p2 = new Point(2, 2.1);
            p3 = new Point(3, 3);
            p4 = new Point(4.1, 4);
            p5 = new Point(5, 5.1);
            points = Vector.<Point>([p0, p1, p2, p3, p4, p5]);
            Assert.assertTrue(compareSimplifyRadialDistance(points));
        }
        
        private function compareSimplifyRadialDistance(vectorPoints:Vector.<Point>):Boolean
        {
            var sqTolerance:Number = 0.01;
            for(var i:uint = 1; i < 16; i++)
            {
                var resultPoints:Vector.<Point> = Simplify.simplifyRadialDistance(vectorPoints, sqTolerance);
                var vectorNumbers:Vector.<Number> = pointsToNumbers(vectorPoints);
                var resultNumbers:Vector.<Number> = PathSimplify.simplifyRadialDistance(vectorNumbers, sqTolerance);
                if(!pointsEqualsNumbers(resultPoints, resultNumbers))
                    return false;
                sqTolerance *= 2;
            }
            return true;
        }
        
        private function compareSimplifyDouglasPeucker(vectorPoints:Vector.<Point>):Boolean
        {
            var sqTolerance:Number = 0.01;
            for(var i:uint = 1; i < 16; i++)
            {
                var resultPoints:Vector.<Point> = Simplify.simplifyDouglasPeucker(vectorPoints, sqTolerance);
                var vectorNumbers:Vector.<Number> = pointsToNumbers(vectorPoints);
                var resultNumbers:Vector.<Number> = PathSimplify.simplifyDouglasPeucker(vectorNumbers, sqTolerance);
                if(!pointsEqualsNumbers(resultPoints, resultNumbers))
                    return false;
                sqTolerance *= 2;
            }
            return true;
        }
        
        private function pointsEqualsNumbers(points:Vector.<Point>, numbers:Vector.<Number>):Boolean
        {
            var pointsNumbers:Vector.<Number> = pointsToNumbers(points);
            if(pointsNumbers.length != numbers.length)
                return false;
            for(var i:uint = 0, lenght:uint = pointsNumbers.length; i < lenght; i++)
                if(pointsNumbers[i] != numbers[i])
                    return false;
            return true;
        }
        
        private function pointsToNumbers(source:Vector.<Point>):Vector.<Number>
        {
            var result:Vector.<Number> = new Vector.<Number>;
            for(var i:uint = 0, lenght:uint = source.length; i < lenght; i++)
                result.push(source[i].x, source[i].y);
            return result;
        }
    }
}