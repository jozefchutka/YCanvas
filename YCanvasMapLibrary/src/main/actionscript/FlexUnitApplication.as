package
{
    import Array;
    
    import flash.display.Sprite;
    
    import flexunit.flexui.FlexUnitTestRunnerUIAS;
    
    import sk.yoz.ycanvas.map.utils.PathSimplifyTest;
    import sk.yoz.ycanvas.utils.PartialBoundsUtilsTest;
    import sk.yoz.ycanvas.utils.StrokeUtilsTest;
    import sk.yoz.ycanvas.utils.VertexDataUtilsTest;
    
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
            testsToRun.push(sk.yoz.ycanvas.map.utils.PathSimplifyTest);
            testsToRun.push(sk.yoz.ycanvas.utils.PartialBoundsUtilsTest);
            testsToRun.push(sk.yoz.ycanvas.utils.VertexDataUtilsTest);
            testsToRun.push(sk.yoz.ycanvas.utils.StrokeUtilsTest);
            return testsToRun;
        }
    }
}