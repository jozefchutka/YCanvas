package sk.yoz.ycanvas.map.demo
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.TransformationManager;
    import sk.yoz.ycanvas.map.display.MapStroke;
    import sk.yoz.ycanvas.map.display.MarkerLayer;
    import sk.yoz.ycanvas.map.display.StrokeLayer;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.utils.GeoUtils;
    import sk.yoz.ycanvas.map.valueObjects.CanvasLimit;
    import sk.yoz.ycanvas.map.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class MyMap
    {
        public var syncCheckBoxSelected:Boolean = true;
        
        public var mapBig:MapController;
        public var mapSmall:MapController;
        
        public var transformationManager:TransformationManager;
        
        private var markerLayer:MarkerLayer;
        private var strokeLayer:StrokeLayer;
        
        public function MyMap(root:Sprite):void
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
            
            var container:starling.display.Sprite = new starling.display.Sprite();
            //container.x = 300;
            //container.y = -200;
            root.addChild(container);
            
            mapBig = new MapController(Maps.MAP_CONFIG_ESRI, init);
            mapBig.addEventListener(CanvasEvent.CENTER_CHANGED, onMapBigCenterChanged);
            mapBig.addEventListener(CanvasEvent.SCALE_CHANGED, onMapBigScaleChanged);
            mapBig.addEventListener(CanvasEvent.ROTATION_CHANGED, onMapBigRotationChanged);
            mapBig.addEventListener(CanvasEvent.RENDERED, onMapBigRendered);
            container.addChild(mapBig.component);
            
            transformationManager = new TransformationManager(mapBig, limit);
            
            strokeLayer = new StrokeLayer;
            strokeLayer.autoUpdateThickness = false;
            strokeLayer.add(new MapStroke(Strokes.EUR_TRIANGLE, 10, 0x00ff00, .5));
            strokeLayer.add(new MapStroke(Strokes.WORLD_TRIANGLE, 10, 0x00ff00, .5));
            strokeLayer.add(new MapStroke(Strokes.RAIL1, 10, 0xff0000, 1));
            strokeLayer.add(new MapStroke(Strokes.RAIL2, 10, 0x0000ff, 1));
            strokeLayer.add(new MapStroke(Strokes.RAIL3, 10, 0xff00ff, 1));
            strokeLayer.add(new MapStroke(Strokes.RAIL4, 10, 0xffff00, 1));
            mapBig.addMapLayer(strokeLayer);
            
            markerLayer = new MarkerLayer;
            mapBig.addMapLayer(markerLayer);
            
            mapSmall = new MapController(Maps.MAP_CONFIG_OSM, init);
            mapSmall.component.addEventListener(TouchEvent.TOUCH, onMapSmallTouch);
            container.addChild(mapSmall.component);
        }
        
        public function set interactive(value:Boolean):void
        {
            transformationManager.allowMove = value;
            transformationManager.allowZoom = value;
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
        
        public function syncSmallMap():void
        {
            var globalPoint:Point = mapSmall.canvasToGlobal(mapSmall.center);
            mapSmall.center = mapBig.globalToCanvas(globalPoint);
            mapSmall.scale = mapBig.scale;
            mapSmall.rotation = mapBig.rotation;
            mapSmall.render();
        }
        
        public function resizeComponents():void
        {
            var width:uint = Starling.current.viewPort.width;
            var height:uint = Starling.current.viewPort.height;
            
            mapBig.component.x = 0;
            mapBig.component.y = 0;
            mapBig.component.width = width;
            mapBig.component.height = height;
            
            mapSmall.component.x = 20;
            mapSmall.component.y = height - 150 - 20;
            mapSmall.component.width = 150;
            mapSmall.component.height = 150;
            
            if(syncCheckBoxSelected)
                syncSmallMap();
        }
        
        private function onMapBigCenterChanged(event:CanvasEvent):void
        {
            if(syncCheckBoxSelected)
                syncSmallMap();
        }
        
        private function onMapBigScaleChanged(event:CanvasEvent):void
        {
            if(syncCheckBoxSelected)
                syncSmallMap();
        }
        
        private function onMapBigRotationChanged(event:CanvasEvent):void
        {
            if(syncCheckBoxSelected)
                syncSmallMap();
        }
        
        private function onMapBigRendered(event:CanvasEvent):void
        {
            if(syncCheckBoxSelected)
                mapSmall.dispatchEvent(new CanvasEvent(CanvasEvent.TRANSFORMATION_FINISHED));
            
            if(!strokeLayer.autoUpdateThickness)
                strokeLayer.updateThickness();
        }
        
        private function onMapSmallTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(mapSmall.component, TouchPhase.BEGAN);
            if(touch)
            {
                var config:MapConfig = mapBig.config;
                mapBig.config = mapSmall.config;
                mapSmall.config = config;
            }
        }
    }
}