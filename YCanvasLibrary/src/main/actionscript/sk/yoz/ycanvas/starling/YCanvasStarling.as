package sk.yoz.ycanvas.starling
{
    import flash.display.BitmapData;
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.AbstractYCanvas;
    
    import starling.core.RenderSupport;
    import starling.core.Starling;
    import starling.display.Stage;
    import starling.events.Event;
    
    /**
    * A Starling implementation of canvas based on Starling.
    */
    public class YCanvasStarling extends AbstractYCanvas
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
        public function YCanvasStarling(stage:flash.display.Stage, 
            stage3D:Stage3D, viewPort:Rectangle, initCallback:Function,
            rootClass:Class = null)
        {
            super(viewPort);
            this.initCallback = initCallback;
            
            var root:Class = rootClass || YCanvasRootStarling;
            engine = new Starling(root, stage, viewPort, stage3D);
            engine.enableErrorChecking = false;
            engine.shareContext = false;
            engine.start();
            engine.addEventListener(Event.ROOT_CREATED, onRootCreated);
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
            
            var root:YCanvasRootStarling = this.root as YCanvasRootStarling;
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
            support.setOrthographicProjection(0, 0, width, height);
            engine.stage.render(support, 1);
            support.finishQuadBatch();
            
            var result:BitmapData = new BitmapData(width, height, true);
            engine.context.drawToBitmapData(result);
            return result;
        }
        
        /**
        * @inheritDoc
        */
        override public function set showStats(value:Boolean):void
        {
            engine.showStats = true;
        }
        
        /**
        * @inheritDoc
        */
        override public function dispose():void
        {
            super.dispose();
            
            engine.removeEventListener(Event.ROOT_CREATED, onRootCreated);
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
        * A listener executed after Root object has been created. At this 
        * point we are able to instantiate root from Starling. A callback
        * defined from the constructor is executed.
        */
        private function onRootCreated(event:Event, 
            root:YCanvasRootStarling):void
        {
            _root = root;
            centerRoot();
            initCallback();
        }
    }
}