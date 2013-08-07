package sk.yoz.ycanvas.map.demo
{
    import flash.geom.Point;
    
    import feathers.controls.Button;
    import feathers.controls.Check;
    import feathers.controls.PickerList;
    import feathers.controls.Slider;
    import feathers.controls.TextInput;
    import feathers.data.ListCollection;
    import feathers.themes.MetalWorksMobileTheme;
    
    import fr.kouma.starling.utils.Stats;
    
    import sk.yoz.utils.GeoUtils;
    import sk.yoz.ycanvas.map.YCanvasMap;
    import sk.yoz.ycanvas.map.demo.mock.AreaCzechRepublic;
    import sk.yoz.ycanvas.map.demo.mock.Maps;
    import sk.yoz.ycanvas.map.demo.mock.RouteNewYorkWashington;
    import sk.yoz.ycanvas.map.demo.mock.RouteRomeParis;
    import sk.yoz.ycanvas.map.display.MapPolygon;
    import sk.yoz.ycanvas.map.display.MapStroke;
    
    import starling.core.Starling;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    /**
    * Main Starling class. Provides demo Feathers UI for map controll.
    */
    public class Main extends Sprite
    {
        private var mapMain:MapHelperMain;
        private var mapOverlay:MapHelperOverlay;
        private var mapSmall:MapHelperSmall;
        
        private var mapPickerList:PickerList;
        private var tilesPickerList:PickerList;
        private var allowRotateCheck:Check;
        private var synchronizeCheck:Check;
        private var showOverlayCheck:Check;
        private var latInput:TextInput;
        private var lonInput:TextInput;
        private var markerOnClickCheck:Check;
        private var routeRomeParisCheck:Check;
        private var routeNewYorkWashingtonCheck:Check;
        private var areaCzechRepublicCheck:Check;
        private var rotationSlider:Slider;
        private var zoomInButton:Button;
        private var zoomOutButton:Button;
        
        private var stats:Stats;
        
        private var routeRomeParisStroke:MapStroke;
        private var routeNewYorkWashingtonStroke:MapStroke;
        private var areaCzechRepublicPolygon:MapPolygon;
        
        public function Main()
        {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            
            Starling.current.nativeStage.addEventListener("resize", resize);
        }
        
        private function syncLatLon():void
        {
            var lat:Number = GeoUtils.y2lat(mapMain.map.center.y);
            var lon:Number = GeoUtils.x2lon(mapMain.map.center.x);
            latInput.text = (Math.round(lat * 1000) / 1000).toString();
            lonInput.text = (Math.round(lon * 1000) / 1000).toString();
        }
        
        private function resize(...rest):void
        {
            mapMain.map.display.x = 200;
            mapMain.map.display.y = 0;
            mapMain.map.display.width = Starling.current.viewPort.width - mapMain.map.display.x;
            mapMain.map.display.height = Starling.current.viewPort.height;
            
            if(mapOverlay)
            {
                mapOverlay.map.display.x = mapMain.map.display.x;
                mapOverlay.map.display.y = mapMain.map.display.y;
                mapOverlay.map.display.width = mapMain.map.display.width;
                mapOverlay.map.display.height = mapMain.map.display.height;
            }
            
            mapSmall.map.display.x = mapMain.map.display.x + 20;
            mapSmall.map.display.y = mapMain.map.display.height - 150 - 20;
            mapSmall.map.display.width = 150;
            mapSmall.map.display.height = 150;
            
            rotationSlider.x = (stage.stageWidth - rotationSlider.width) / 2;
            rotationSlider.y = stage.stageHeight - rotationSlider.height - 20;
            
            zoomOutButton.x = stage.stageWidth - zoomOutButton.width - 20;
            zoomOutButton.y = stage.stageHeight - zoomOutButton.height - 20;
            
            zoomInButton.x = stage.stageWidth - zoomInButton.width - 20;
            zoomInButton.y = stage.stageHeight - zoomInButton.height * 2 - 20;
            
            stats.x = stage.stageWidth - 70;
        }
        
        /**
        * Creates UI (children).
        */
        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            
            new MetalWorksMobileTheme();
            
            mapMain = new MapHelperMain();
            mapMain.map.display.addEventListener(TouchEvent.TOUCH, onBigMapTouch);
            addChild(mapMain.map.display);
            mapMain.map.display.invalidateStarlingViewPort();
            
            mapSmall = new MapHelperSmall(mapMain.map);
            addChild(mapSmall.map.display);
            mapSmall.map.display.invalidateStarlingViewPort();
            
            if(mapSmall.autoSync)
                mapSmall.sync();
            
            mapPickerList = new PickerList;
            mapPickerList.width = 200;
            mapPickerList.dataProvider = new ListCollection([
                {"label": "Main Map", data:mapMain}, 
                {"label": "Small Map", data:mapSmall}]);
            addChild(mapPickerList);
            mapPickerList.validate();
            
            tilesPickerList = new PickerList;
            tilesPickerList.width = 200;
            tilesPickerList.y = mapPickerList.y + mapPickerList.height + 5;
            tilesPickerList.dataProvider = new ListCollection([
                {label: "ArcGIS Imagery", data: Maps.ARCGIS_IMAGERY},
                {label: "ArcGIS National Geographic", data: Maps.ARCGIS_NATIONAL_GEOGRAPHIC},
                {label: "Map Quest", data: Maps.MAPQUEST},
                {label: "OSM", data: Maps.OSM},
                {label: "MapBox", data: Maps.MAPBOX},
                {label: "CloudMade", data: Maps.CLOUDMADE}]);
            addChild(tilesPickerList);
            tilesPickerList.validate();
            
            var button:Button = new Button();
            button.label = "Update Tile Provider";
            button.y = tilesPickerList.y + tilesPickerList.height + 5;
            button.addEventListener(Event.TRIGGERED, onUpdateTileProviderTriggered);
            addChild(button);
            button.validate();
            
            allowRotateCheck = new Check;
            allowRotateCheck.isSelected = true;
            allowRotateCheck.label = "Allow 2 finger rotation";
            allowRotateCheck.isSelected = true;
            allowRotateCheck.y = button.y + button.height + 15;
            allowRotateCheck.addEventListener(Event.CHANGE, onAllowRotateChange);
            addChild(allowRotateCheck);
            allowRotateCheck.validate();
            
            synchronizeCheck = new Check;
            synchronizeCheck.label = "Sync small and big map";
            synchronizeCheck.isSelected = true;
            synchronizeCheck.y = allowRotateCheck.y + allowRotateCheck.height + 5;
            synchronizeCheck.addEventListener(Event.CHANGE, onSyncCheckBoxChange);
            addChild(synchronizeCheck);
            synchronizeCheck.validate();
            
            showOverlayCheck = new Check;
            showOverlayCheck.label = "Show overlay";
            showOverlayCheck.isSelected = false;
            showOverlayCheck.y = synchronizeCheck.y + synchronizeCheck.height + 5;
            showOverlayCheck.addEventListener(Event.CHANGE, onShowOverlayCheckChange);
            addChild(showOverlayCheck);
            showOverlayCheck.validate();
            
            latInput = new TextInput;
            latInput.restrict = "0-9.";
            latInput.width = 95;
            latInput.y = showOverlayCheck.y + showOverlayCheck.height + 15;
            addChild(latInput);
            latInput.validate();
            
            lonInput = new TextInput;
            lonInput.restrict = "0-9.";
            lonInput.width = latInput.width;
            lonInput.x = 100;
            lonInput.y = latInput.y;
            addChild(lonInput);
            lonInput.validate();
            
            syncLatLon();
            
            button = new Button;
            button.label = "Navigate";
            button.width = latInput.width;
            button.y = lonInput.y + lonInput.height + 5;
            button.addEventListener(Event.TRIGGERED, onNavigateClick);
            addChild(button);
            button.validate();
            
            button = new Button;
            button.label = "Add Marker";
            button.width = lonInput.width;
            button.x = lonInput.x;
            button.y = lonInput.y + lonInput.height + 5;
            button.addEventListener(Event.TRIGGERED, onAddMarkerClick);
            addChild(button);
            button.validate();
            
            markerOnClickCheck = new Check;
            markerOnClickCheck.label = "Add Marker on click";
            markerOnClickCheck.y = button.y + button.height + 15;
            addChild(markerOnClickCheck);
            markerOnClickCheck.validate();
            
            routeRomeParisCheck = new Check;
            routeRomeParisCheck.label = "Show route Rome - Paris";
            routeRomeParisCheck.y = markerOnClickCheck.y + markerOnClickCheck.height + 15;
            routeRomeParisCheck.addEventListener(Event.CHANGE, onRouteRomeParisChange);
            addChild(routeRomeParisCheck);
            routeRomeParisCheck.validate();
            
            routeNewYorkWashingtonCheck = new Check;
            routeNewYorkWashingtonCheck.label = "Show route New York - Washington";
            routeNewYorkWashingtonCheck.y = routeRomeParisCheck.y + routeRomeParisCheck.height + 5;
            routeNewYorkWashingtonCheck.addEventListener(Event.CHANGE, onRouteNewYorkWashingtonChange);
            addChild(routeNewYorkWashingtonCheck);
            routeNewYorkWashingtonCheck.validate();
            
            areaCzechRepublicCheck = new Check;
            areaCzechRepublicCheck.label = "Show area Czech Republic";
            areaCzechRepublicCheck.y = routeNewYorkWashingtonCheck.y + routeNewYorkWashingtonCheck.height + 5;
            areaCzechRepublicCheck.addEventListener(Event.CHANGE, onAreachCzechRepublicCheckChange);
            addChild(areaCzechRepublicCheck);
            areaCzechRepublicCheck.validate();
            
            rotationSlider = new Slider;
            rotationSlider.width = 200;
            rotationSlider.minimum = -180;
            rotationSlider.maximum = 180;
            addChild(rotationSlider);
            rotationSlider.validate();
            rotationSlider.addEventListener(Event.CHANGE, onRotationSliderChange);
            
            zoomOutButton = new Button;
            zoomOutButton.label = "-";
            addChild(zoomOutButton);
            zoomOutButton.validate();
            zoomOutButton.addEventListener(Event.TRIGGERED, onZoomOutClick);
            
            zoomInButton = new Button;
            zoomInButton.label = "+";
            addChild(zoomInButton);
            zoomInButton.validate();
            zoomInButton.addEventListener(Event.TRIGGERED, onZoomInClick);
            
            stats = new Stats();
            addChild(stats);
            
            resize();
        }
        
        private function onUpdateTileProviderTriggered(event:Event):void
        {
            var component:YCanvasMap = mapPickerList.selectedItem.data.map;
            component.config = tilesPickerList.selectedItem.data;
        }
        
        private function onAllowRotateChange(event:Event):void
        {
            mapMain.transformationManager.allowRotate = allowRotateCheck.isSelected;
        }
        
        private function onSyncCheckBoxChange(event:Event):void
        {
            mapSmall.autoSync = synchronizeCheck.isSelected;
        }
        
        private function onShowOverlayCheckChange(event:Event):void
        {
            if(showOverlayCheck.isSelected)
            {
                mapOverlay = new MapHelperOverlay(mapMain.map);
                addChildAt(mapOverlay.map.display, getChildIndex(mapMain.map.display) + 1);
                mapMain.map.display.invalidateStarlingViewPort();
                resize();
            }
            else
            {
                removeChild(mapOverlay.map.display);
                mapOverlay.dispose();
                mapOverlay = null;
            }
        }
        
        private function onNavigateClick():void
        {
            var lat:Number = parseFloat(latInput.text);
            var lon:Number = parseFloat(lonInput.text);
            mapMain.transformationManager.moveToTween(GeoUtils.lon2x(lon), GeoUtils.lat2y(lat));
        }
        
        private function onAddMarkerClick():void
        {
            var lat:Number = parseFloat(latInput.text);
            var lon:Number = parseFloat(lonInput.text);
            mapMain.addMarkerAt(GeoUtils.lon2x(lon), GeoUtils.lat2y(lat));
        }
        
        private function onRouteRomeParisChange():void
        {
            if(routeRomeParisCheck.isSelected)
            {
                routeRomeParisStroke = new MapStroke(RouteRomeParis.DATA, 10, 0x0000ff, 1);
                mapMain.strokeLayer.add(routeRomeParisStroke);
                mapMain.transformationManager.showDisplayObjectTween(routeRomeParisStroke);
            }
            else
            {
                mapMain.strokeLayer.remove(routeRomeParisStroke);
            }
        }
        
        private function onRouteNewYorkWashingtonChange():void
        {
            if(routeNewYorkWashingtonCheck.isSelected)
            {
                routeNewYorkWashingtonStroke = new MapStroke(RouteNewYorkWashington.DATA, 10, 0x00ff00, 1);
                mapMain.strokeLayer.add(routeNewYorkWashingtonStroke);
                mapMain.transformationManager.showDisplayObjectTween(routeNewYorkWashingtonStroke);
            }
            else
            {
                mapMain.strokeLayer.remove(routeNewYorkWashingtonStroke);
            }
        }
        
        private function onAreachCzechRepublicCheckChange():void
        {
            
            if(areaCzechRepublicCheck.isSelected)
            {
                areaCzechRepublicPolygon = new MapPolygon(AreaCzechRepublic.DATA, 0xff0000, .5);
                mapMain.polygonLayer.addChild(areaCzechRepublicPolygon);
                mapMain.transformationManager.showDisplayObjectTween(areaCzechRepublicPolygon);
            }
            else
            {
                mapMain.polygonLayer.removeChild(areaCzechRepublicPolygon);
            }
        }
        
        private function onBigMapTouch(event:TouchEvent):void
        {
            if(!markerOnClickCheck.isSelected)
                return;
            
            var touch:Touch = event.getTouch(mapMain.map.display, TouchPhase.BEGAN);
            if(!touch)
                return;
            
            var position:Point = mapMain.map.globalToCanvas(new Point(touch.globalX, touch.globalY));
            mapMain.addMarkerAt(position.x, position.y);
        }
        
        private function onRotationSliderChange(event:Event):void
        {
            var rotation:Number = rotationSlider.value * 0.0174532925;
            mapMain.transformationManager.rotateToTween(rotation);
        }
        
        private function onZoomInClick():void
        {
            mapMain.transformationManager.scaleByTween(1.5);
        }
        
        private function onZoomOutClick():void
        {
            mapMain.transformationManager.scaleByTween(1 / 1.5);
        }
    }
}
