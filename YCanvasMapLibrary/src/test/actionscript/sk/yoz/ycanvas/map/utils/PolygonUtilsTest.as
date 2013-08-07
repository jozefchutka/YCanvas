package sk.yoz.ycanvas.map.utils
{
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.geom.Rectangle;
    
    import flexunit.framework.Assert;

    public class PolygonUtilsTest
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
        public function customPoints_triangulate_equalsExpected():void
        {
            var points:Vector.<Number> = Vector.<Number>([
                100,0, 220,140, 420,140, 420,340, 320,210, 300,150, 220,340, 100,240, 200,200]);
            points = resizePoints(points, 200, 200);
            var indices:Vector.<uint> = PolygonUtils.triangulate(points);
            
            Assert.assertTrue(bitmapDataEquals(points, indices));
        }
        
        [Test]
        public function customPoints2_triangulate_equalsExpected():void
        {
            var points:Vector.<Number> = Vector.<Number>([
                35810163,22673206, 35818551,22723538, 35887757,22771772, 35864689,22830493, 
                35904534,22922767, 35963255,22952127, 36055529,23056985, 36166678,23134580, 
                36179261,23161843, 36229593,23170231, 36292508,23161843, 36313479,23109414, 
                36344936,23107317, 36353325,23038111, 36388977,23056985, 36403657,23044402, 
                36489640,23080054, 36609178,23121997, 36636441,23096831, 36709841,23145065, 
                36758075,23082151, 36808407,23096831, 36879710,23067471, 36896487,23036013, 
                36921653,23033916, 36940528,22962613, 36976179,22950030, 37011831,22899699, 
                37064260,22891310, 37057968,22851464, 37022316,22832590, 37013928,22786452, 
                36911167,22746606, 36883904,22765481, 36833573,22710955, 36862933,22692081, 
                36850350,22660623, 36789533,22679498, 36703549,22627069, 36724521,22683692, 
                36661606,22723538, 36575623,22629166, 36630149,22587223, 36598692,22551571, 
                36537874,22580931, 36500126,22532697, 36422531,22530600, 36397365,22465588, 
                36344936,22450908, 36351228,22503337, 36269439,22505434, 36269439,22450908, 
                36217010,22446714, 36237982,22494948, 36149901,22522211, 36072307,22545280, 
                36059724,22578834, 36040849,22562057, 36011489,22604000, 35982129,22610292, 
                35969546,22633360, 35940186,22627069, 35856300,22698372, 35820648,22654332]);
            points = resizePoints(points, 200, 200);
            var indices:Vector.<uint> = PolygonUtils.triangulate(points);
            
            Assert.assertEquals(true, bitmapDataEquals(points, indices));
        }
        
        public static function resizePoints(points:Vector.<Number>, width:uint, height:uint):Vector.<Number>
        {
            var result:Vector.<Number> = points.concat();
            var rectangle:Rectangle = PolygonUtils.getRectangle(result);
            var scaleX:Number = width / rectangle.width;
            var scaleY:Number = height / rectangle.height;
            var scale:Number = scaleX < scaleY ? scaleX : scaleY;
            for(var i:uint = 0, length:uint = result.length / 2; i <length; i++)
            {
                var xi:uint = i * 2;
                var yi:uint = xi + 1;
                result[xi] = (result[xi] - rectangle.x) * scale;
                result[yi] = (result[yi] - rectangle.y) * scale;
            }
            return result;
        }
        
        public static function bitmapDataEquals(points:Vector.<Number>, indices:Vector.<uint>):Boolean
        {
            var bitmapData1:BitmapData = bitmapDataFromNativePolygon(points);
            var bitmapData2:BitmapData = bitmapDataFromTriangulation(points, indices);
            var compare:Object = bitmapData1.compare(bitmapData2);
            return compare == 0;
        }
        
        public static function bitmapDataFromNativePolygon(points:Vector.<Number>):BitmapData
        {
            var rectangle:Rectangle = PolygonUtils.getRectangle(points);
            
            var shape:Shape = new Shape;
            graphicsFromNativePolygon(points, shape.graphics);
            
            var bitmapData:BitmapData = new BitmapData(rectangle.width, rectangle.height, true, 0);
            bitmapData.draw(shape);
            
            return bitmapData;
        }
        
        public static function graphicsFromNativePolygon(points:Vector.<Number>, graphics:Graphics):void
        {
            var rectangle:Rectangle = PolygonUtils.getRectangle(points);
            graphics.beginFill(0xff0000, .5);
            graphics.moveTo(points[0] - rectangle.x, points[1] - rectangle.y);
            for(var i:uint = 0, length:uint = points.length / 2; i < length; i++)
            {
                graphics.lineTo(points[i * 2] - rectangle.x, points[i * 2 + 1] - rectangle.y); 
            }
        }
        
        public static function bitmapDataFromTriangulation(points:Vector.<Number>, indices:Vector.<uint>):BitmapData
        {
            var rectangle:Rectangle = PolygonUtils.getRectangle(points);
            
            var shape:Shape = new Shape;
            graphicsFromTriangulation(points, indices, shape.graphics);
            
            var bitmapData:BitmapData = new BitmapData(rectangle.width, rectangle.height, true, 0);
            bitmapData.draw(shape);
            
            return bitmapData;
        }
        
        public static function graphicsFromTriangulation(points:Vector.<Number>, indices:Vector.<uint>, graphics:Graphics):void
        {
            var rectangle:Rectangle = PolygonUtils.getRectangle(points);
            for(var i:uint = 0, length:uint = indices.length / 3; i < length; i++)
            {
                graphics.beginFill(0xff0000, .5);
                graphics.moveTo(points[indices[i * 3 + 0] * 2] - rectangle.x, points[indices[i * 3 + 0] * 2 + 1] - rectangle.y);
                graphics.lineTo(points[indices[i * 3 + 1] * 2] - rectangle.x, points[indices[i * 3 + 1] * 2 + 1] - rectangle.y);
                graphics.lineTo(points[indices[i * 3 + 2] * 2] - rectangle.x, points[indices[i * 3 + 2] * 2 + 1] - rectangle.y);
                graphics.endFill();
            }
        }
    }
}