package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.map.demo.Main;
    
    import starling.core.Starling;
    
    /**
    * A simple application wrapper inspired by Feathers common wrapper used 
    * in examples.
    */
    [SWF(width="960",height="640",frameRate="60",backgroundColor="#4a4137")]
    public class ApplicationMap extends Sprite
    {
        private var _starling:Starling;
        
        public function ApplicationMap()
        {
            mouseEnabled = mouseChildren = false;
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            Starling.handleLostContext = true;
            Starling.multitouchEnabled = true;
            _starling = new Starling(Main, stage);
            _starling.enableErrorChecking = false;
            _starling.start();
            stage.addEventListener(Event.RESIZE, onStageResize, false, int.MAX_VALUE, true);
            stage.addEventListener(Event.DEACTIVATE, onStageDeactivate, false, 0, true);
        }
        
        private function onStageResize(event:Event):void
        {
            _starling.stage.stageWidth = stage.stageWidth;
            _starling.stage.stageHeight = stage.stageHeight;
            
            const viewPort:Rectangle = _starling.viewPort;
            viewPort.width = stage.stageWidth;
            viewPort.height = stage.stageHeight;
            try
            {
                _starling.viewPort = viewPort;
            }
            catch(error:Error){}
        }
        
        private function onStageDeactivate(event:Event):void
        {
            _starling.stop();
            stage.addEventListener(Event.ACTIVATE, onStageActivate, false, 0, true);
        }
        
        private function onStageActivate(event:Event):void
        {
            stage.removeEventListener(Event.ACTIVATE, onStageActivate);
            _starling.start();
        }
    }
}