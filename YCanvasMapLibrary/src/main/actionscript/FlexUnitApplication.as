package
{
    import Array;
    
    import flash.display.Sprite;
    
    import flexunit.flexui.FlexUnitTestRunnerUIAS;
    
    import sk.yoz.utils.PathSimplifyTest;
    import sk.yoz.ycanvas.map.utils.PartialBoundsUtilsTest;
    import sk.yoz.ycanvas.map.utils.PolygonUtilsTest;
    import sk.yoz.ycanvas.map.utils.StrokeUtilsTest;
    import sk.yoz.ycanvas.map.utils.VertexDataUtilsTest;
    
    public class FlexUnitApplication extends Sprite
    {
        public function FlexUnitApplication()
        {
            onCreationComplete();
        }
        
        private function onCreationComplete():void
        {
            var testRunner:FlexUnitTestRunnerUIAS=new FlexUnitTestRunnerUIAS();
            testRunner.portNumber=8765; 
            this.addChild(testRunner); 
            testRunner.runWithFlexUnit4Runner(currentRunTestSuite(), "YCanvasMapLibrary");
        }
        
        public function currentRunTestSuite():Array
        {
            var testsToRun:Array = new Array();
            testsToRun.push(sk.yoz.utils.PathSimplifyTest);
            testsToRun.push(sk.yoz.ycanvas.map.utils.PolygonUtilsTest);
            testsToRun.push(sk.yoz.ycanvas.map.utils.PartialBoundsUtilsTest);
            testsToRun.push(sk.yoz.ycanvas.map.utils.VertexDataUtilsTest);
            testsToRun.push(sk.yoz.ycanvas.map.utils.StrokeUtilsTest);
            return testsToRun;
        }
    }
}