package sk.yoz.ycanvas.stage3D
{
    import flash.display.BitmapData;
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.Stage;
    
    /**
    * A Stage3D implementation of canvas based on Starling.
    */
    public class YCanvasStage3D extends AbstractYCanvas
    {
        /**
        * An internal Starling engine reference.
        */
        private var engine:Starling;
        
        /**
        * An internal pointer to a callback method.
        */
        private var initCallback:Function;
        
        /**
        * A constructor. The most of properties are required by Starling.
        * 
        * @param initCallback A function to be called when context is created.
        */
        public function YCanvasStage3D(stage:flash.display.Stage, 
            stage3D:Stage3D, viewPort:Rectangle, initCallback:Function,
            rootClass:Class = null)
        {
            super(viewPort);
            this.initCallback = initCallback;
            
            var root:Class = rootClass || YCanvasRootStage3D;
            engine = new Starling(root, stage, viewPort, stage3D);
            engine.enableErrorChecking = false;
            engine.start();
            
            var type:String = Event.CONTEXT3D_CREATE;
            stage3D.addEventListener(type, onContextCreated, false, -1, true);
        }
        
        /**
        * @inheritDoc
        * 
        * Provides additional functionality required by starling viewPort 
        * implementation.
        */
        override public function set viewPort(value:Rectangle):void
        {
            super.viewPort = value;
            
            var root:YCanvasRootStage3D = this.root as YCanvasRootStage3D;
            if(root)
            {
                root.stage.stageWidth = value.width;
                root.stage.stageHeight = value.height;
            }
            
            if(engine)
                engine.viewPort = value;
        }
        
        /**
         * @inheritDoc
         */
        override public function get bitmapData():BitmapData
        {
            var width:uint = viewPort.width;
            var height:uint = viewPort.height;
            var stage:starling.display.Stage = engine.stage;
            var support:RenderSupport = new RenderSupport();
            RenderSupport.clear(stage.color, 1.0);
            support.setOrthographicProjection(width, height);
            engine.stage.render(support, 1);
            support.finishQuadBatch();
            
            var result:BitmapData = new BitmapData(width, height, true);
            engine.context.drawToBitmapData(result);
            return result;
        }
        
        /**
         * @inheritDoc
         */
        override public function dispose():void
        {
            super.dispose();
            
            var type:String = Event.CONTEXT3D_CREATE;
            var stage3D:Stage3D = engine.stage3D;
            stage3D.removeEventListener(type, onContextCreated, false);
            engine.dispose();
            engine = null;
            initCallback = null;
        }
        
        /**
        * @inheritDoc
        */
        override protected function centerRoot():void
        {
            root && super.centerRoot();
        }
        
        /**
        * A listener executed after Stage3D context has been created. At this 
        * point we are able to instantiate root from Starling. A callback
        * defined from the constructor is executed.
        */
        private function onContextCreated(event:Event):void
        {
            _root = YCanvasRootStage3D(engine.stage.getChildAt(0));
            centerRoot();
            initCallback();
        }
    }
}