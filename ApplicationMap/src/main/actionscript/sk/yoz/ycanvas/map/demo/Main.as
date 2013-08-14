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
    import sk.yoz.ycanvas.map.demo.mock.AreaCzechRepublic;
    import sk.yoz.ycanvas.map.demo.mock.Maps;
    import sk.yoz.ycanvas.map.demo.mock.RouteNewYorkWashington;
    import sk.yoz.ycanvas.map.demo.mock.RouteRomeParis;
    import sk.yoz.ycanvas.map.display.MapStroke;
    import sk.yoz.ycanvas.map.display.Polygon;
    import sk.yoz.ycanvas.map.utils.OptimizedPointsUtils;
    import sk.yoz.ycanvas.map.valueObjects.OptimizedPoints;
    
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
        
        private var mapContainer:Sprite;
        
        private var showMapsCheck:Check;
        private var showOverlayCheck:Check;
        private var routeRomeParisCheck:Check;
        private var routeNewYorkWashingtonCheck:Check;
        private var areaCzechRepublicCheck:Check;
        private var addMarkerOnClickCheck:Check;
        private var allowRotateCheck:Check;
        private var synchronizeCheck:Check;
        private var tilesPickerList:PickerList;
        private var latInput:TextInput;
        private var lonInput:TextInput;
        private var navigateButton:Button;
        private var addMarkerButton:Button;
        private var rotationSlider:Slider;
        private var zoomInButton:Button;
        private var zoomOutButton:Button;
        
        private var stats:Stats;
        
        private var routeRomeParisStroke:MapStroke;
        private var routeNewYorkWashingtonStroke:MapStroke;
        private var areaCzechRepublicPolygon:Polygon;
        
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
            if(mapMain)
            {
                mapMain.map.display.x = 200;
                mapMain.map.display.y = 0;
                mapMain.map.display.width = Starling.current.viewPort.width - mapMain.map.display.x;
                mapMain.map.display.height = Starling.current.viewPort.height;
            }
            
            if(mapOverlay)
            {
                mapOverlay.map.display.x = mapMain.map.display.x;
                mapOverlay.map.display.y = mapMain.map.display.y;
                mapOverlay.map.display.width = mapMain.map.display.width;
                mapOverlay.map.display.height = mapMain.map.display.height;
            }
            
            if(mapSmall)
            {
                mapSmall.map.display.x = mapMain.map.display.x + 20;
                mapSmall.map.display.y = mapMain.map.display.height - 150 - 20;
                mapSmall.map.display.width = 150;
                mapSmall.map.display.height = 150;
            }
            
            rotationSlider.x = (stage.stageWidth - rotationSlider.width) / 2;
            rotationSlider.y = stage.stageHeight - rotationSlider.height - 20;
            
            zoomOutButton.x = stage.stageWidth - zoomOutButton.width - 20;
            zoomOutButton.y = stage.stageHeight - zoomOutButton.height - 20;
            
            zoomInButton.x = stage.stageWidth - zoomInButton.width - 20;
            zoomInButton.y = stage.stageHeight - zoomInButton.height * 2 - 20;
            
            stats.x = stage.stageWidth - 70;
        }
        
        private function createMaps():void
        {
            mapMain = new MapHelperMain();
            mapMain.map.display.addEventListener(TouchEvent.TOUCH, onMapMainTouch);
            mapContainer.addChild(mapMain.map.display);
            mapMain.map.display.invalidateStarlingViewPort();
            
            mapSmall = new MapHelperSmall(mapMain.map);
            mapContainer.addChild(mapSmall.map.display);
            mapSmall.map.display.invalidateStarlingViewPort();
            
            if(mapSmall.autoSync)
                mapSmall.sync();
        }
        
        private function disposeMaps():void
        {
            disposeRouteRomeParisStroke();
            disposeNewYorkWashingtonStroke();
            disposeAreaCzechRepublicPolygon();
            
            if(mapMain)
            {
                mapMain.map.display.parent.removeChild(mapMain.map.display);
                mapMain.dispose();
                mapMain = null;
            }
            
            if(mapOverlay)
            {
                mapOverlay.map.display.parent.removeChild(mapOverlay.map.display);
                mapOverlay.dispose();
                mapOverlay = null;
            }
            
            if(mapSmall)
            {
                mapSmall.map.display.parent.removeChild(mapSmall.map.display);
                mapSmall.dispose();
                mapSmall = null;
            }
        }
        
        private function disposeRouteRomeParisStroke():void
        {
            if(!routeRomeParisStroke)
                return;
            
            mapMain.strokeLayer.remove(routeRomeParisStroke);
            routeRomeParisStroke.dispose();
            routeRomeParisStroke = null;
        }
        
        private function disposeNewYorkWashingtonStroke():void
        {
            if(!routeNewYorkWashingtonStroke)
                return;
            
            mapMain.strokeLayer.remove(routeNewYorkWashingtonStroke);
            routeNewYorkWashingtonStroke.dispose();
            routeNewYorkWashingtonStroke = null;
        }
        
        private function disposeAreaCzechRepublicPolygon():void
        {
            if(!areaCzechRepublicPolygon)
                return;
            
            mapMain.polygonLayer.removeChild(areaCzechRepublicPolygon);
            areaCzechRepublicPolygon.dispose();
            areaCzechRepublicPolygon = null;
        }
        
        /**
        * Creates UI (children).
        */
        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            
            new MetalWorksMobileTheme();
            
            mapContainer = new Sprite;
            addChild(mapContainer);
            
            createMaps();
            
            showMapsCheck = new Check;
            showMapsCheck.label = "Show maps (dispose)";
            showMapsCheck.isSelected = true;
            addChild(showMapsCheck);
            showMapsCheck.validate();
            showMapsCheck.addEventListener(Event.CHANGE, onShowMapsCheckChange);
            
            showOverlayCheck = new Check;
            showOverlayCheck.label = "Show overlay";
            showOverlayCheck.isSelected = false;
            showOverlayCheck.y = showMapsCheck.y + showMapsCheck.height + 5;
            showOverlayCheck.addEventListener(Event.CHANGE, onShowOverlayCheckChange);
            addChild(showOverlayCheck);
            showOverlayCheck.validate();
            
            routeRomeParisCheck = new Check;
            routeRomeParisCheck.label = "Show route Rome - Paris";
            routeRomeParisCheck.y = showOverlayCheck.y + showOverlayCheck.height + 5;
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
            
            addMarkerOnClickCheck = new Check;
            addMarkerOnClickCheck.label = "Add Marker on click";
            addMarkerOnClickCheck.y = areaCzechRepublicCheck.y + areaCzechRepublicCheck.height + 5;
            addChild(addMarkerOnClickCheck);
            addMarkerOnClickCheck.validate();
            
            allowRotateCheck = new Check;
            allowRotateCheck.label = "Allow 2 finger rotation";
            allowRotateCheck.isSelected = true;
            allowRotateCheck.y = addMarkerOnClickCheck.y + addMarkerOnClickCheck.height + 5;
            allowRotateCheck.addEventListener(Event.CHANGE, onAllowRotateCheckChange);
            addChild(allowRotateCheck);
            allowRotateCheck.validate();
            
            synchronizeCheck = new Check;
            synchronizeCheck.label = "Sync small and big map";
            synchronizeCheck.isSelected = true;
            synchronizeCheck.y = allowRotateCheck.y + allowRotateCheck.height + 5;
            synchronizeCheck.addEventListener(Event.CHANGE, onSynchronizeCheckChange);
            addChild(synchronizeCheck);
            synchronizeCheck.validate();
            
            tilesPickerList = new PickerList;
            tilesPickerList.width = 200;
            tilesPickerList.dataProvider = new ListCollection([
                {label: "ArcGIS Imagery", data: Maps.ARCGIS_IMAGERY},
                {label: "BingMaps Imagery", data: Maps.BINGMAPS_IMAGERY},
                {label: "ArcGIS National Geographic", data: Maps.ARCGIS_NATIONAL_GEOGRAPHIC},
                {label: "Map Quest", data: Maps.MAPQUEST},
                {label: "OSM", data: Maps.OSM},
                {label: "MapBox", data: Maps.MAPBOX},
                {label: "CloudMade", data: Maps.CLOUDMADE}]);
            tilesPickerList.y = synchronizeCheck.y + synchronizeCheck.height + 15;
            addChild(tilesPickerList);
            tilesPickerList.validate();
            tilesPickerList.addEventListener(Event.CHANGE, onTilesPickerListChange);
            
            latInput = new TextInput;
            latInput.restrict = "0-9.";
            latInput.width = 95;
            latInput.y = tilesPickerList.y + tilesPickerList.height + 15;
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
            
            navigateButton = new Button;
            navigateButton.label = "Navigate";
            navigateButton.width = latInput.width;
            navigateButton.y = lonInput.y + lonInput.height + 5;
            navigateButton.addEventListener(Event.TRIGGERED, onNavigateClick);
            addChild(navigateButton);
            navigateButton.validate();
            
            addMarkerButton = new Button;
            addMarkerButton.label = "Add Marker";
            addMarkerButton.width = lonInput.width;
            addMarkerButton.x = lonInput.x;
            addMarkerButton.y = lonInput.y + lonInput.height + 5;
            addMarkerButton.addEventListener(Event.TRIGGERED, onAddMarkerClick);
            addChild(addMarkerButton);
            addMarkerButton.validate();
            
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
            zoomOutButton.addEventListener(Event.TRIGGERED, onZoomOutButtonTriggered);
            
            zoomInButton = new Button;
            zoomInButton.label = "+";
            addChild(zoomInButton);
            zoomInButton.validate();
            zoomInButton.addEventListener(Event.TRIGGERED, onZoomInButtonTriggered);
            
            stats = new Stats();
            addChild(stats);
            
            resize();
        }
        
        private function onTilesPickerListChange(event:Event):void
        {
            mapMain.map.config = tilesPickerList.selectedItem.data;
        }
        
        private function onShowMapsCheckChange():void
        {
            if(showMapsCheck.isSelected)
            {
                createMaps();
                resize();
                
                showOverlayCheck.isEnabled = true;
                routeRomeParisCheck.isEnabled = true;
                routeNewYorkWashingtonCheck.isEnabled = true;
                areaCzechRepublicCheck.isEnabled = true;
                addMarkerOnClickCheck.isEnabled = true;
                allowRotateCheck.isEnabled = true;
                synchronizeCheck.isEnabled = true;
                tilesPickerList.isEnabled = true;
                navigateButton.isEnabled = true;
                addMarkerButton.isEnabled = true;
                rotationSlider.isEnabled = true;
                zoomInButton.isEnabled = true;
                zoomOutButton.isEnabled = true;
            }
            else
            {
                disposeMaps();
                showOverlayCheck.isSelected = false;
                routeRomeParisCheck.isSelected = false;
                routeNewYorkWashingtonCheck.isSelected = false;
                areaCzechRepublicCheck.isSelected = false;
                
                showOverlayCheck.isEnabled = false;
                routeRomeParisCheck.isEnabled = false;
                routeNewYorkWashingtonCheck.isEnabled = false;
                areaCzechRepublicCheck.isEnabled = false;
                addMarkerOnClickCheck.isEnabled = false;
                allowRotateCheck.isEnabled = false;
                synchronizeCheck.isEnabled = false;
                tilesPickerList.isEnabled = false;
                navigateButton.isEnabled = false;
                addMarkerButton.isEnabled = false;
                rotationSlider.isEnabled = false;
                zoomInButton.isEnabled = false;
                zoomOutButton.isEnabled = false;
            }
        }
        
        private function onAllowRotateCheckChange(event:Event):void
        {
            mapMain.transformationManager.allowRotate = allowRotateCheck.isSelected;
        }
        
        private function onSynchronizeCheckChange(event:Event):void
        {
            mapSmall.autoSync = synchronizeCheck.isSelected;
        }
        
        private function onShowOverlayCheckChange(event:Event):void
        {
            if(showOverlayCheck.isSelected)
            {
                mapOverlay = new MapHelperOverlay(mapMain.map);
                mapContainer.addChildAt(mapOverlay.map.display, mapContainer.getChildIndex(mapMain.map.display) + 1);
                mapMain.map.display.invalidateStarlingViewPort();
                resize();
            }
            else if(mapOverlay)
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
                var optimizedPoints:OptimizedPoints = OptimizedPointsUtils.calculate(RouteRomeParis.DATA);
                routeRomeParisStroke = new MapStroke(optimizedPoints.points, 10, 0x0000ff, 1);
                routeRomeParisStroke.pivotX = optimizedPoints.pivotX;
                routeRomeParisStroke.pivotY = optimizedPoints.pivotY;
                mapMain.strokeLayer.add(routeRomeParisStroke);
                mapMain.transformationManager.showDisplayObjectTween(routeRomeParisStroke);
            }
            else disposeRouteRomeParisStroke();
        }
        
        private function onRouteNewYorkWashingtonChange():void
        {
            if(routeNewYorkWashingtonCheck.isSelected)
            {
                var optimizedPoints:OptimizedPoints = OptimizedPointsUtils.calculate(RouteNewYorkWashington.DATA);
                routeNewYorkWashingtonStroke = new MapStroke(optimizedPoints.points, 10, 0x00ff00, 1);
                routeNewYorkWashingtonStroke.pivotX = optimizedPoints.pivotX;
                routeNewYorkWashingtonStroke.pivotY = optimizedPoints.pivotY;
                mapMain.strokeLayer.add(routeNewYorkWashingtonStroke);
                mapMain.transformationManager.showDisplayObjectTween(routeNewYorkWashingtonStroke);
            }
            else disposeNewYorkWashingtonStroke();
        }
        
        private function onAreachCzechRepublicCheckChange():void
        {
            
            if(areaCzechRepublicCheck.isSelected)
            {
                var optimizedPoints:OptimizedPoints = OptimizedPointsUtils.calculate(AreaCzechRepublic.DATA);
                areaCzechRepublicPolygon = new Polygon(optimizedPoints.points, 0xff0000, .5);
                areaCzechRepublicPolygon.pivotX = optimizedPoints.pivotX;
                areaCzechRepublicPolygon.pivotY = optimizedPoints.pivotY;
                mapMain.polygonLayer.addChild(areaCzechRepublicPolygon);
                mapMain.transformationManager.showDisplayObjectTween(areaCzechRepublicPolygon);
            }
            else disposeAreaCzechRepublicPolygon();
        }
        
        private function onMapMainTouch(event:TouchEvent):void
        {
            if(!addMarkerOnClickCheck.isSelected)
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
        
        private function onZoomInButtonTriggered():void
        {
            mapMain.transformationManager.scaleByTween(1.5);
        }
        
        private function onZoomOutButtonTriggered():void
        {
            mapMain.transformationManager.scaleByTween(1 / 1.5);
        }
    }
}
