package sk.yoz.ycanvas.map.demo.mock
{
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;

    public class Maps
    {
        private static var _MAPQUEST:MapConfig;
        private static var _OSM:MapConfig;
        private static var _MAPBOX:MapConfig;
        private static var _CLOUDMADE:MapConfig;
        private static var _ARCGIS_IMAGERY:MapConfig;
        private static var _ARCGIS_NATIONAL_GEOGRAPHIC:MapConfig;
        private static var _ARCGIS_REFERENCE:MapConfig;
        
        public static function get MAPQUEST():MapConfig
        {
            if(!_MAPQUEST)
                _MAPQUEST = createMapConfig([
                    "http://otile1.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png",
                    "http://otile2.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png",
                    "http://otile3.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png",
                    "http://otile4.mqcdn.com/tiles/1.0.0/osm/${z}/${x}/${y}.png"]);
            return _MAPQUEST;
        }
        
        public static function get OSM():MapConfig
        {
            if(!_OSM)
                _OSM = createMapConfig([
                    "http://a.tile.openstreetmap.org/${z}/${x}/${y}.png",
                    "http://b.tile.openstreetmap.org/${z}/${x}/${y}.png",
                    "http://c.tile.openstreetmap.org/${z}/${x}/${y}.png"]);
            return _OSM;
        }
        
        public static function get MAPBOX():MapConfig
        {
            if(!_MAPBOX)
                _MAPBOX = createMapConfig([
                    "http://a.tiles.mapbox.com/v3/examples.map-vyofok3q/${z}/${x}/${y}.png",
                    "http://b.tiles.mapbox.com/v3/examples.map-vyofok3q/${z}/${x}/${y}.png",
                    "http://c.tiles.mapbox.com/v3/examples.map-vyofok3q/${z}/${x}/${y}.png",
                    "http://d.tiles.mapbox.com/v3/examples.map-vyofok3q/${z}/${x}/${y}.png"]);
            return _MAPBOX;
        }
        
        public static function get CLOUDMADE():MapConfig
        {
            if(!_CLOUDMADE)
                _CLOUDMADE = createMapConfig([
                    "http://a.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/998/256/${z}/${x}/${y}.png",
                    "http://b.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/998/256/${z}/${x}/${y}.png",
                    "http://c.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/998/256/${z}/${x}/${y}.png"]);
            return _CLOUDMADE;
        }
        
        public static function get ARCGIS_IMAGERY():MapConfig
        {
            if(!_ARCGIS_IMAGERY)
                _ARCGIS_IMAGERY = createMapConfig([
                    "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/${z}/${y}/${x}.png",
                    "http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/${z}/${y}/${x}.png"]);
            return _ARCGIS_IMAGERY;
        }
        
        public static function get ARCGIS_NATIONAL_GEOGRAPHIC():MapConfig
        {
            if(!_ARCGIS_NATIONAL_GEOGRAPHIC)
                _ARCGIS_NATIONAL_GEOGRAPHIC = createMapConfig([
                    "http://server.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer/tile/${z}/${y}/${x}.png",
                    "http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer/tile/${z}/${y}/${x}.png"]);
            return _ARCGIS_NATIONAL_GEOGRAPHIC;
        }
        
        public static function get ARCGIS_REFERENCE():MapConfig
        {
            if(!_ARCGIS_REFERENCE)
                _ARCGIS_REFERENCE = createMapConfig([
                    "http://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/${z}/${y}/${x}.png",
                    "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/${z}/${y}/${x}.png"]);
            return _ARCGIS_REFERENCE;
        }
        
        private static function createMapConfig(templates:Array):MapConfig
        {
            var result:MapConfig = new MapConfig;
            result.urlTemplates = Vector.<String>(templates);
            result.tileWidth = 256;
            result.tileHeight = 256;
            return result;
        }
    }
}