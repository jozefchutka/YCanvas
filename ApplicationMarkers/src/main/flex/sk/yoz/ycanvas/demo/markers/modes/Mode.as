package sk.yoz.ycanvas.demo.markers.modes
{
    import sk.yoz.ycanvas.demo.markers.modes.arcgis.ArcGisPartition;
    import sk.yoz.ycanvas.demo.markers.modes.mapquest.MapQuestPartition;
    import sk.yoz.ycanvas.demo.markers.modes.openstreetmaps.OpenStreetMapsPartition;
    import sk.yoz.ycanvas.demo.markers.valueObjects.CanvasLimits;
    import sk.yoz.ycanvas.demo.markers.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.demo.markers.valueObjects.FactoryData;
    import sk.yoz.ycanvas.demo.markers.ycanvas.LayerFactory;
    import sk.yoz.ycanvas.demo.markers.ycanvas.PartitionFactory;

    public class Mode
    {
        public static const MAPQUEST:Mode = 
            new Mode(LayerFactory, PartitionFactory,
                2 << 15, 2, MapQuestPartition, 256, 256, 1, 1 / (2 << 15), 35e6, 25e6, 1 / 16384, 0);
        
        public static const ARCGIS:Mode = 
            new Mode(LayerFactory, PartitionFactory,
                2 << 15, 2, ArcGisPartition, 256, 256, 1, 1 / (2 << 15), 35e6, 25e6, 1 / 16384, 0);
        
        public static const OPENSTREETMAPS:Mode = 
            new Mode(LayerFactory, PartitionFactory,
                2 << 15, 2, OpenStreetMapsPartition, 256, 256, 1, 1 / (2 << 15), 35e6, 25e6, 1 / 16384, 0);
        
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