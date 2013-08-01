package sk.yoz.ycanvas.map.demo
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.display.MapComponent;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.valueObjects.Transformation;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    
    import starling.display.Quad;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import sk.yoz.ycanvas.map.demo.mock.Maps;

    /**
    * Provides functionality for the small map.
    */
    public class HelperSmallMap
    {
        public var mapController:MapController;
        
        private var _autoSync:Boolean = true;
        private var background:Quad;
        private var bigMapController:MapController;
        
        public function HelperSmallMap(bigMapController:MapController)
        {
            this.bigMapController = bigMapController;
            
            var transformation:Transformation = new Transformation;
            transformation.centerX = bigMapController.center.x;
            transformation.centerY = bigMapController.center.y;
            transformation.scale = bigMapController.scale;
            transformation.rotation = bigMapController.rotation;
            
            background = new Quad(1, 1, 0xffffff);
            background.touchable = false;
            
            mapController = new MapController(Maps.OSM, transformation);
            mapController.component.addChildAt(background, 0);
            mapController.component.addEventListener(TouchEvent.TOUCH, onMapTouch);
            mapController.component.addEventListener(MapComponent.VIEWPORT_UPDATED, onViewportUpdated);
            
            bigMapController.addEventListener(CanvasEvent.RENDERED, onBigMapControllerRendered);
            bigMapController.addEventListener(CanvasEvent.CENTER_CHANGED, onBigMapControllerCenterChanged);
            bigMapController.addEventListener(CanvasEvent.SCALE_CHANGED, onBigMapControllerScaleChanged);
            bigMapController.addEventListener(CanvasEvent.ROTATION_CHANGED, onBigMapControllerRotationChanged);
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
            var globalPoint:Point = mapController.canvasToGlobal(mapController.center);
            mapController.center = bigMapController.globalToCanvas(globalPoint);
            mapController.scale = bigMapController.scale;
            mapController.rotation = bigMapController.rotation;
            mapController.render();
        }
        
        private function onMapTouch(event:TouchEvent):void
        {
            if(event.getTouch(mapController.component, TouchPhase.BEGAN))
            {
                var config:MapConfig = bigMapController.config;
                bigMapController.config = mapController.config;
                mapController.config = config;
            }
        }
        
        private function onViewportUpdated():void
        {
            background.width = mapController.component.width;
            background.height = mapController.component.height;
        }
        
        private function onBigMapControllerRendered(event:CanvasEvent):void
        {
            mapController.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
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