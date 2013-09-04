package sk.yoz.ycanvas.map.demo
{
    import sk.yoz.net.LoaderOptimizer;
    import sk.yoz.ycanvas.map.YCanvasMap;
    import sk.yoz.ycanvas.map.demo.mock.Maps;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    import sk.yoz.ycanvas.map.valueObjects.Transformation;

    /**
    * Provides functionality for the main map overlay (transparent layer over 
    * the main map - city names, countries etc.).
    */
    public class MapHelperOverlay
    {
        public var map:YCanvasMap;
        
        private var mapMain:YCanvasMap;
        
        public function MapHelperOverlay(loaderOptimizer:LoaderOptimizer, mapMain:YCanvasMap)
        {
            this.mapMain = mapMain;
            
            var transformation:Transformation = new Transformation;
            transformation.centerX = mapMain.center.x;
            transformation.centerY = mapMain.center.y;
            transformation.scale = mapMain.scale;
            transformation.rotation = mapMain.rotation;
            
            var config:MapConfig = Maps.ARCGIS_REFERENCE;
            
            map = new YCanvasMap(config, transformation, 0, 1);
            map.loaderOptimizer = loaderOptimizer;
            map.display.touchable = false;
            
            mapMain.addEventListener(CanvasEvent.RENDERED, sync);
            mapMain.addEventListener(CanvasEvent.CENTER_CHANGED, sync);
            mapMain.addEventListener(CanvasEvent.SCALE_CHANGED, sync);
            mapMain.addEventListener(CanvasEvent.ROTATION_CHANGED, sync);
        }
        
        public function dispose():void
        {
            mapMain.removeEventListener(CanvasEvent.RENDERED, sync);
            mapMain.removeEventListener(CanvasEvent.CENTER_CHANGED, sync);
            mapMain.removeEventListener(CanvasEvent.SCALE_CHANGED, sync);
            mapMain.removeEventListener(CanvasEvent.ROTATION_CHANGED, sync);
            
            map.dispose();
            map = null;
            
            mapMain = null;
        }
        
        private function sync(...rest):void
        {
            map.center = mapMain.center;
            map.scale = mapMain.scale;
            map.rotation = mapMain.rotation;
            map.render();
        }
        
        private function onBigMapControllerRendered(event:CanvasEvent):void
        {
            map.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
        }
    }
}