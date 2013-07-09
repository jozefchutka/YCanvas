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
    
    import sk.yoz.ycanvas.map.MapController;
    import sk.yoz.ycanvas.map.utils.GeoUtils;
    
    import starling.core.Starling;
    import starling.display.Sprite;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class Main extends Sprite
    {
        private var componentSelector:PickerList;
        private var mapsSelector:PickerList;
        private var bigMap:HelperBigMap;
        private var smallMap:HelperSmallMap;
        private var syncCheckBox:Check;
        private var latInput:TextInput;
        private var lonInput:TextInput;
        private var addMarkerOnClick:Check;
        private var rotationInput:Slider;
        
        public function Main()
        {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        private function syncLatLon():void
        {
            latInput.text = GeoUtils.y2lat(bigMap.map.center.y).toString();
            lonInput.text = GeoUtils.x2lon(bigMap.map.center.x).toString();
        }
        
        private function onAddedToStage(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            new MetalWorksMobileTheme();

            bigMap = new HelperBigMap();
            bigMap.map.component.x = 200;
            bigMap.map.component.y = 0;
            bigMap.map.component.width = Starling.current.viewPort.width - bigMap.map.component.x;
            bigMap.map.component.height = Starling.current.viewPort.height;
            bigMap.map.component.addEventListener(TouchEvent.TOUCH, onBigMapTouch);
            addChild(bigMap.map.component);
            bigMap.map.component.validateViewPort();
            
            smallMap = new HelperSmallMap(bigMap.map);
            smallMap.map.component.x = bigMap.map.component.x + 20;
            smallMap.map.component.y = bigMap.map.component.height - 150 - 20;
            smallMap.map.component.width = 150;
            smallMap.map.component.height = 150;
            addChild(smallMap.map.component);
            smallMap.map.component.validateViewPort();
            
            if(smallMap.autoSync)
                smallMap.sync();
            
            componentSelector = new PickerList;
            componentSelector.width = 200;
            componentSelector.dataProvider = new ListCollection([
                {"label": "Big Map", data:bigMap}, 
                {"label": "Small Map", data:smallMap}]);
            addChild(componentSelector);
            componentSelector.validate();
            
            mapsSelector = new PickerList;
            mapsSelector.width = 200;
            mapsSelector.y = componentSelector.y + componentSelector.height + 5;
            mapsSelector.dataProvider = new ListCollection([
                {label: "Map Quest", data: Maps.MAP_CONFIG_MAPQUEST},
                {label: "OSM", data: Maps.MAP_CONFIG_OSM},
                {label: "MapBox", data: Maps.MAP_CONFIG_MAPBOX},
                {label: "CloudMade", data: Maps.MAP_CONFIG_CLOUDMADE},
                {label: "ESRI", data: Maps.MAP_CONFIG_ESRI}]);
            addChild(mapsSelector);
            mapsSelector.validate();
            
            var button:Button = new Button();
            button.label = "Update Tile Provider";
            button.y = mapsSelector.y + mapsSelector.height + 5;
            button.addEventListener(Event.TRIGGERED, onUpdateTileProviderTriggered);
            addChild(button);
            button.validate();
            
            syncCheckBox = new Check;
            syncCheckBox.label = "Sync small and big map";
            syncCheckBox.isSelected = true;
            syncCheckBox.y = button.y + button.height + 15;
            syncCheckBox.addEventListener(Event.CHANGE, onSyncCheckBoxChange);
            addChild(syncCheckBox);
            syncCheckBox.validate();
            
            latInput = new TextInput;
            latInput.restrict = "0-9.";
            latInput.width = 95;
            latInput.y = syncCheckBox.y + syncCheckBox.height + 15;
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
            
            addMarkerOnClick = new Check;
            addMarkerOnClick.label = "Add Marker on click";
            addMarkerOnClick.y = button.y + button.height + 15;
            addChild(addMarkerOnClick);
            addMarkerOnClick.validate();
            
            rotationInput = new Slider;
            rotationInput.width = 200;
            rotationInput.minimum = -180;
            rotationInput.maximum = 180;
            addChild(rotationInput);
            rotationInput.validate();
            rotationInput.x = (stage.stageWidth - rotationInput.width) / 2;
            rotationInput.y = stage.stageHeight - rotationInput.height - 20;
            rotationInput.addEventListener(Event.CHANGE, onRotationSliderChange);
            
            button = new Button;
            button.label = "-";
            addChild(button);
            button.validate();
            button.x = stage.stageWidth - button.width - 20;
            button.y = stage.stageHeight - button.height - 20;
            button.addEventListener(Event.TRIGGERED, onZoomOutClick);
            
            button = new Button;
            button.label = "+";
            addChild(button);
            button.validate();
            button.x = stage.stageWidth - button.width - 20;
            button.y = stage.stageHeight - button.height * 2 - 20;
            button.addEventListener(Event.TRIGGERED, onZoomInClick);
        }
        
        private function onUpdateTileProviderTriggered(event:Event):void
        {
            var component:MapController = componentSelector.selectedItem.data.map;
            component.config = mapsSelector.selectedItem.data;
        }
        
        private function onSyncCheckBoxChange(event:Event):void
        {
            smallMap.autoSync = syncCheckBox.isSelected;
        }
        
        private function onNavigateClick():void
        {
            var lat:Number = parseFloat(latInput.text);
            var lon:Number = parseFloat(lonInput.text);
            bigMap.transformationManager.moveToTween(GeoUtils.lon2x(lon), GeoUtils.lat2y(lat));
        }
        
        private function onAddMarkerClick():void
        {
            var lat:Number = parseFloat(latInput.text);
            var lon:Number = parseFloat(lonInput.text);
            bigMap.addMarkerAt(GeoUtils.lon2x(lon), GeoUtils.lat2y(lat));
        }
        
        private function onBigMapTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(bigMap.map.component, TouchPhase.BEGAN);
            if(touch && addMarkerOnClick.isSelected)
            {
                var position:Point = bigMap.map.globalToCanvas(new Point(touch.globalX, touch.globalY));
                bigMap.addMarkerAt(position.x, position.y);
            }
        }
        
        private function onRotationSliderChange(event:Event):void
        {
            var rotation:Number = rotationInput.value * 0.0174532925;
            bigMap.transformationManager.rotateToTween(rotation);
        }
        
        private function onZoomInClick():void
        {
            bigMap.transformationManager.scaleByTween(1.5);
        }
        
        private function onZoomOutClick():void
        {
            bigMap.transformationManager.scaleByTween(1 / 1.5);
        }
    }
}
