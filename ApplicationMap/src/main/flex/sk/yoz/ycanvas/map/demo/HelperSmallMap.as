package sk.yoz.ycanvas.map.demo
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    
    import starling.core.Starling;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class HelperSmallMap
    {
        public var map:MapController;
        
        private var _autoSync:Boolean = true;
        
        private var original:MapController;
        
        public function HelperSmallMap(original:MapController)
        {
            this.original = original;
            
            var init:CanvasTransformation = new CanvasTransformation;
            init.centerX = original.center.x;
            init.centerY = original.center.y;
            init.scale = original.scale;
            init.rotation = original.rotation;
            
            map = new MapController(Maps.MAP_CONFIG_OSM, init);
            map.component.addEventListener(TouchEvent.TOUCH, onMapTouch);
            
            original.addEventListener(CanvasEvent.RENDERED, onOriginalRendered);
            original.addEventListener(CanvasEvent.CENTER_CHANGED, onOriginalCenterChanged);
            original.addEventListener(CanvasEvent.SCALE_CHANGED, onOriginalScaleChanged);
            original.addEventListener(CanvasEvent.ROTATION_CHANGED, onOriginalRotationChanged);
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
            map.center = original.globalToCanvas(globalPoint);
            map.scale = original.scale;
            map.rotation = original.rotation;
            map.render();
        }
        
        public function resize():void
        {
            map.component.x = 20;
            map.component.y = Starling.current.viewPort.height - 150 - 20;
            map.component.width = 150;
            map.component.height = 150;
            
            if(autoSync)
                sync();
        }
        
        private function onMapTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(map.component, TouchPhase.BEGAN);
            if(touch)
            {
                var config:MapConfig = original.config;
                original.config = map.config;
                map.config = config;
            }
        }
        
        private function onOriginalRendered(event:CanvasEvent):void
        {
            map.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
        }
        
        private function onOriginalCenterChanged(event:CanvasEvent):void
        {
            if(autoSync)
                sync();
        }
        
        private function onOriginalScaleChanged(event:CanvasEvent):void
        {
            if(autoSync)
                sync();
        }
        
        private function onOriginalRotationChanged(event:CanvasEvent):void
        {
            if(autoSync)
                sync();
        }
    }
}