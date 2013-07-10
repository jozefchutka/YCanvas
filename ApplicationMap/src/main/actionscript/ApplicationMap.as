package
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.map.demo.Main;
    
    import starling.core.Starling;
    
    [SWF(width="960",height="640",frameRate="60",backgroundColor="#4a4137")]
    public class ApplicationMap extends Sprite
    {
        private var _starling:Starling;
        
        public function ApplicationMap()
        {
            this.mouseEnabled = this.mouseChildren = false;
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            Starling.handleLostContext = true;
            Starling.multitouchEnabled = true;
            this._starling = new Starling(Main, this.stage);
            this._starling.enableErrorChecking = false;
            this._starling.start();
            this.stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true);
            this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
        }
        
        private function stage_resizeHandler(event:Event):void
        {
            this._starling.stage.stageWidth = this.stage.stageWidth;
            this._starling.stage.stageHeight = this.stage.stageHeight;
            
            const viewPort:Rectangle = this._starling.viewPort;
            viewPort.width = this.stage.stageWidth;
            viewPort.height = this.stage.stageHeight;
            try
            {
                this._starling.viewPort = viewPort;
            }
            catch(error:Error) {}
        }
        
        private function stage_deactivateHandler(event:Event):void
        {
            this._starling.stop();
            this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
        }
        
        private function stage_activateHandler(event:Event):void
        {
            this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
            this._starling.start();
        }
    }
}