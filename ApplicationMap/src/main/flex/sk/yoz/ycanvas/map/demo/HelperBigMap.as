package sk.yoz.ycanvas.map.demo
{
    import flash.ui.Multitouch;
    
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.display.MapStroke;
    import sk.yoz.ycanvas.map.display.MarkerLayer;
    import sk.yoz.ycanvas.map.display.StrokeLayer;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.managers.AbstractTransformationManager;
    import sk.yoz.ycanvas.map.managers.MouseTransformationManager;
    import sk.yoz.ycanvas.map.managers.TouchTransformationManager;
    import sk.yoz.ycanvas.map.utils.GeoUtils;
    import sk.yoz.ycanvas.map.valueObjects.CanvasLimit;
    import sk.yoz.ycanvas.map.valueObjects.CanvasTransformation;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class HelperBigMap
    {
        public var map:MapController;
        
        public var strokeLayer:StrokeLayer;
        public var transformationManager:AbstractTransformationManager;
        public var markerLayer:MarkerLayer;
        
        public function HelperBigMap()
        {
            var init:CanvasTransformation = new CanvasTransformation;
            init.centerX = GeoUtils.lon2x(7.75);
            init.centerY = GeoUtils.lat2y(45.53);
            init.rotation = 0;
            init.scale = 1 / 4096;
            
            var limit:CanvasLimit = new CanvasLimit;
            limit.minScale = 1;
            limit.maxScale = 1 / 65536;
            limit.minCenterX = 0;
            limit.maxCenterX = GeoUtils.lon2x(180);
            limit.minCenterY = GeoUtils.lat2y(85);
            limit.maxCenterY = GeoUtils.lat2y(-85);
            
            map = new MapController(Maps.MAP_CONFIG_ESRI, init);
            map.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onMapTransformationFinished);
            
            transformationManager = Multitouch.supportsTouchEvents
                ? new TouchTransformationManager(map, limit)
                : new MouseTransformationManager(map, limit);
            
            strokeLayer = new StrokeLayer;
            strokeLayer.autoUpdateThickness = false;
            strokeLayer.addEventListener(TouchEvent.TOUCH, onStrokeLayerTouch);
            map.addMapLayer(strokeLayer);
            
            strokeLayer.add(new MapStroke(Strokes.ROUTE_ROME_PARIS, 10, 0x0000ff, 1));
            strokeLayer.add(new MapStroke(Strokes.EUR_TRIANGLE, 10, 0x00ff00, .5));
            strokeLayer.add(new MapStroke(Strokes.WORLD_TRIANGLE, 10, 0x00ff00, .5));
            strokeLayer.add(new MapStroke(Strokes.RAIL1, 10, 0xff0000, 1));
            strokeLayer.add(new MapStroke(Strokes.RAIL2, 10, 0x0000ff, 1));
            strokeLayer.add(new MapStroke(Strokes.RAIL3, 10, 0xff00ff, 1));
            strokeLayer.add(new MapStroke(Strokes.RAIL4, 10, 0xffff00, 1));
            
            markerLayer = new MarkerLayer;
            markerLayer.addEventListener(TouchEvent.TOUCH, onMarkerLayerTouch);
            map.addMapLayer(markerLayer);
        }
        
        public function resize():void
        {
            map.component.x = 0;
            map.component.y = 0;
            map.component.width = Starling.current.viewPort.width;
            map.component.height = Starling.current.viewPort.height;
        }
        
        public function addMarkerAt(x:Number, y:Number):void
        {
            var marker:Image = new Image(Assets.MARKER_GREEN_TEXTURE);
            marker.x = x;
            marker.y = y;
            marker.pivotX = Assets.MARKER_GREEN_TEXTURE.width / 2;
            marker.pivotY = Assets.MARKER_GREEN_TEXTURE.height;
            markerLayer.add(marker);
        }
        
        private function onMapTransformationFinished(event:CanvasEvent):void
        {
            if(!strokeLayer.autoUpdateThickness)
                strokeLayer.updateThickness();
        }
        
        private function onStrokeLayerTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(map.component, TouchPhase.BEGAN);
            if(touch)
                trace("Stroke selected.");
        }
        
        private function onMarkerLayerTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(map.component, TouchPhase.BEGAN);
            if(touch)
                trace("Marker selected.");
        }
    }
}