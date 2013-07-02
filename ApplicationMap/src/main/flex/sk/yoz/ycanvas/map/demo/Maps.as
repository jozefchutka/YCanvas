package sk.yoz.ycanvas.map.demo
{
    import sk.yoz.ycanvas.map.valueObjects.MapConfig;

    public class Maps
    {
        private static var _MAP_CONFIG_MAPQUEST:MapConfig;
        private static var _MAP_CONFIG_OSM:MapConfig;
        private static var _MAP_CONFIG_MAPBOX:MapConfig;
        private static var _MAP_CONFIG_CLOUDMADE:MapConfig;
        private static var _MAP_CONFIG_ESRI:MapConfig;
        
        
        public static function get MAP_CONFIG_MAPQUEST():MapConfig
        {
            if(!_MAP_CONFIG_MAPQUEST)
                _MAP_CONFIG_MAPQUEST = createMapConfig([
                    "http://otile1.mqcdn.com/tiles/1.0.0/osm/${level}/${x}/${y}.png",
                    "http://otile2.mqcdn.com/tiles/1.0.0/osm/${level}/${x}/${y}.png",
                    "http://otile3.mqcdn.com/tiles/1.0.0/osm/${level}/${x}/${y}.png",
                    "http://otile4.mqcdn.com/tiles/1.0.0/osm/${level}/${x}/${y}.png"]);
            return _MAP_CONFIG_MAPQUEST;
        }
        
        public static function get MAP_CONFIG_OSM():MapConfig
        {
            if(!_MAP_CONFIG_OSM)
                _MAP_CONFIG_OSM = createMapConfig([
                    "http://a.tile.openstreetmap.org/${level}/${x}/${y}.png",
                    "http://b.tile.openstreetmap.org/${level}/${x}/${y}.png",
                    "http://c.tile.openstreetmap.org/${level}/${x}/${y}.png"]);
            return _MAP_CONFIG_OSM;
        }
        
        public static function get MAP_CONFIG_MAPBOX():MapConfig
        {
            if(!_MAP_CONFIG_MAPBOX)
                _MAP_CONFIG_MAPBOX = createMapConfig([
                    "http://a.tiles.mapbox.com/v3/examples.map-vyofok3q/${level}/${x}/${y}.png",
                    "http://b.tiles.mapbox.com/v3/examples.map-vyofok3q/${level}/${x}/${y}.png",
                    "http://c.tiles.mapbox.com/v3/examples.map-vyofok3q/${level}/${x}/${y}.png",
                    "http://d.tiles.mapbox.com/v3/examples.map-vyofok3q/${level}/${x}/${y}.png"]);
            return _MAP_CONFIG_MAPBOX;
        }
        
        public static function get MAP_CONFIG_CLOUDMADE():MapConfig
        {
            if(!_MAP_CONFIG_CLOUDMADE)
                _MAP_CONFIG_CLOUDMADE = createMapConfig([
                    "http://a.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/998/256/${level}/${x}/${y}.png",
                    "http://b.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/998/256/${level}/${x}/${y}.png",
                    "http://c.tile.cloudmade.com/BC9A493B41014CAABB98F0471D759707/998/256/${level}/${x}/${y}.png"]);
            return _MAP_CONFIG_CLOUDMADE;
        }
        
        public static function get MAP_CONFIG_ESRI():MapConfig
        {
            if(!_MAP_CONFIG_ESRI)
                _MAP_CONFIG_ESRI = createMapConfig([
                    "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/${level}/${y}/${x}.png",
                    "http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/${level}/${y}/${x}.png"]);
            return _MAP_CONFIG_ESRI;
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