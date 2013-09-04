package sk.yoz.ycanvas.map.demo
{
    import flash.geom.Point;
    
    import sk.yoz.net.LoaderOptimizer;
    import sk.yoz.ycanvas.map.YCanvasMap;
    import sk.yoz.ycanvas.map.demo.mock.Maps;
    import sk.yoz.ycanvas.map.demo.partition.CustomPartitionFactory;
    import sk.yoz.ycanvas.map.display.MapDisplay;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.layers.LayerFactory;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    import sk.yoz.ycanvas.map.valueObjects.Transformation;
    
    import starling.display.Quad;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    /**
    * Provides functionality for the small map.
    */
    public class MapHelperSmall
    {
        public var map:YCanvasMap;
        
        private var _autoSync:Boolean = true;
        private var background:Quad;
        private var mapMain:YCanvasMap;
        
        public function MapHelperSmall(loaderOptimizer:LoaderOptimizer, mapMain:YCanvasMap)
        {
            this.mapMain = mapMain;
            
            var transformation:Transformation = new Transformation;
            transformation.centerX = mapMain.center.x;
            transformation.centerY = mapMain.center.y;
            transformation.scale = mapMain.scale;
            transformation.rotation = mapMain.rotation;
            
            background = new Quad(1, 1, 0xffffff);
            background.touchable = false;
            
            var config:MapConfig = Maps.OSM;
            
            map = new YCanvasMap(config, transformation);
            map.loaderOptimizer = loaderOptimizer;
            
            //Lets customize partition factory so it creates CustomPartition
            // capable of handling bing maps
            map.partitionFactory = new CustomPartitionFactory(config, map, map.loaderOptimizer);
            map.layerFactory = new LayerFactory(config, map.partitionFactory);
            
            map.display.addChildAt(background, 0);
            map.display.addEventListener(TouchEvent.TOUCH, onMapTouch);
            map.display.addEventListener(MapDisplay.VIEWPORT_UPDATED, onViewportUpdated);
            
            mapMain.addEventListener(CanvasEvent.RENDERED, onBigMapControllerRendered);
            mapMain.addEventListener(CanvasEvent.CENTER_CHANGED, onBigMapControllerCenterChanged);
            mapMain.addEventListener(CanvasEvent.SCALE_CHANGED, onBigMapControllerScaleChanged);
            mapMain.addEventListener(CanvasEvent.ROTATION_CHANGED, onBigMapControllerRotationChanged);
        }
        
        public function set autoSync(value:Boolean):void
        {
            if(autoSync == value)
                return;
            
            _autoSync = value;
            if(autoSync)
                sync();
        }
        
        public function get autoSync():Boolean
        {
            return _autoSync;
        }
        
        public function sync():void
        {
            var globalPoint:Point = map.canvasToGlobal(map.center);
            map.center = mapMain.globalToCanvas(globalPoint);
            map.scale = mapMain.scale;
            map.rotation = mapMain.rotation;
            map.render();
        }
        
        public function dispose():void
        {
            map.dispose();
            map = null;
            
            mapMain = null;
        }
        
        private function onMapTouch(event:TouchEvent):void
        {
            if(event.getTouch(map.display, TouchPhase.BEGAN))
            {
                var config:MapConfig = mapMain.config;
                mapMain.config = map.config;
                map.config = config;
            }
        }
        
        private function onViewportUpdated():void
        {
            background.width = map.display.width;
            background.height = map.display.height;
            
            if(autoSync)
                sync();
        }
        
        private function onBigMapControllerRendered(event:CanvasEvent):void
        {
            map.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
        }
        
        private function onBigMapControllerCenterChanged(event:CanvasEvent):void
        {
            if(autoSync)
                sync();
        }
        
        private function onBigMapControllerScaleChanged(event:CanvasEvent):void
        {
            if(autoSync)
                sync();
        }
        
        private function onBigMapControllerRotationChanged(event:CanvasEvent):void
        {
            if(autoSync)
                sync();
        }
    }
}