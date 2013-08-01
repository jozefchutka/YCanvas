package sk.yoz.ycanvas.map.demo
{
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.demo.mock.Maps;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.valueObjects.Transformation;

    /**
    * Provides functionality for the main map overlay (transparent layer over 
    * the main map - city names, countries etc.).
    */
    public class HelperBigOverlayMap
    {
        public var mapController:MapController;
        private var bigMapController:MapController;
        
        public function HelperBigOverlayMap(bigMapController:MapController)
        {
            this.bigMapController = bigMapController;
            
            var transformation:Transformation = new Transformation;
            transformation.centerX = bigMapController.center.x;
            transformation.centerY = bigMapController.center.y;
            transformation.scale = bigMapController.scale;
            transformation.rotation = bigMapController.rotation;
            
            mapController = new MapController(Maps.ARCGIS_REFERENCE, transformation, 0, 1);
            mapController.component.touchable = false;
            
            bigMapController.addEventListener(CanvasEvent.RENDERED, sync);
            bigMapController.addEventListener(CanvasEvent.CENTER_CHANGED, sync);
            bigMapController.addEventListener(CanvasEvent.SCALE_CHANGED, sync);
            bigMapController.addEventListener(CanvasEvent.ROTATION_CHANGED, sync);
        }
        
        public function dispose():void
        {
            bigMapController.removeEventListener(CanvasEvent.RENDERED, sync);
            bigMapController.removeEventListener(CanvasEvent.CENTER_CHANGED, sync);
            bigMapController.removeEventListener(CanvasEvent.SCALE_CHANGED, sync);
            bigMapController.removeEventListener(CanvasEvent.ROTATION_CHANGED, sync);
            
            mapController.dispose();
        }
        
        private function sync(...rest):void
        {
            mapController.center = bigMapController.center;
            mapController.scale = bigMapController.scale;
            mapController.rotation = bigMapController.rotation;
            mapController.render();
        }
        
        private function onBigMapControllerRendered(event:CanvasEvent):void
        {
            mapController.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
        }
    }
}