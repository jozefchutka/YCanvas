package sk.yoz.ycanvas.demo.explorer.modes
{
    import sk.yoz.ycanvas.demo.explorer.modes.arcgis.ArcGisPartition;
    import sk.yoz.ycanvas.demo.explorer.modes.flickr.FlickrPartition;
    import sk.yoz.ycanvas.demo.explorer.modes.mapquest.MapQuestPartition;
    import sk.yoz.ycanvas.demo.explorer.modes.onboard.OnBoardPartition;
    import sk.yoz.ycanvas.demo.explorer.modes.openstreetmaps.OpenStreetMapsPartition;
    import sk.yoz.ycanvas.demo.explorer.modes.walloffame.WallOfFameLayerFactory;
    import sk.yoz.ycanvas.demo.explorer.modes.walloffame.WallOfFamePartition;
    import sk.yoz.ycanvas.demo.explorer.modes.webcanvas.WebCanvasLayerFactory;
    import sk.yoz.ycanvas.demo.explorer.modes.webcanvas.WebCanvasPartition;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.CanvasLimits;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.FactoryData;

    public class Mode
    {
        public static const ONBOARD:Mode = 
            new Mode(LayerFactory, PartitionFactory, 
                32, 2, OnBoardPartition, 256, 256, 1, 1 / 32, 0, 0, 1 / 8, 0);
        
        public static const WALLOFFAME:Mode = 
            new Mode(WallOfFameLayerFactory, PartitionFactory, 
                9, 3, WallOfFamePartition, 512, 512, 1, 1 / 12, 100000, 10000, 1 / 4, 0);
        
        public static const WEBCANVAS:Mode = 
            new Mode(WebCanvasLayerFactory, PartitionFactory, 
                25, 5, WebCanvasPartition, 380, 300, 1, 1 / 35, 0, 0, 1 / 5, 0);
        
        public static const MAPQUEST:Mode = 
            new Mode(LayerFactory, PartitionFactory,
                2 << 15, 2, MapQuestPartition, 256, 256, 1, 1 / (2 << 15), 35e6, 25e6, 1 / 16384, 0);
        
        public static const ARCGIS:Mode = 
            new Mode(LayerFactory, PartitionFactory,
                2 << 15, 2, ArcGisPartition, 256, 256, 1, 1 / (2 << 15), 35e6, 25e6, 1 / 16384, 0);
        
        public static const OPENSTREETMAPS:Mode = 
            new Mode(LayerFactory, PartitionFactory,
                2 << 15, 2, OpenStreetMapsPartition, 256, 256, 1, 1 / (2 << 15), 35e6, 25e6, 1 / 16384, 0);
        
        public static const FLICKR:Mode = 
            new Mode(LayerFactory, PartitionFactory,
                1, 2, FlickrPartition, 256, 256, 1, 1 / 2, 0, 0, 1 / 1.5, 0);
        
        public var layerFactory:Class;
        public var partitionFactory:Class;
        public var transformation:CanvasTransformation;
        public var limits:CanvasLimits;
        public var factoryData:FactoryData;
        
        public function Mode(layerFactory:Class, partitionFactory:Class, 
            layerMaxLevel:uint, layerStep:uint, partitionClass:Class, partitionWidth:uint, partitionHeight:uint,
            scaleMin:Number, scaleMax:Number,
            x:Number, y:Number, scale:Number, rotation:Number)
        {
            this.layerFactory = layerFactory;
            this.partitionFactory = partitionFactory;
            
            factoryData = new FactoryData;
            factoryData.layerMaxLevel = layerMaxLevel;
            factoryData.layerStep = layerStep;
            factoryData.partitionClass = partitionClass;
            factoryData.partitionWidth = partitionWidth;
            factoryData.partitionHeight = partitionHeight;
            
            transformation = new CanvasTransformation;
            transformation.centerX = x;
            transformation.centerY = y;
            transformation.scale = scale;
            transformation.rotation = rotation;
            
            limits = new CanvasLimits;
            limits.scaleMin = scaleMin;
            limits.scaleMax = scaleMax;
        }
    }
}