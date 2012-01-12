package sk.yoz.ycanvas.demo.explorer.modes
{
    import sk.yoz.ycanvas.demo.explorer.modes.onboard.OnBoardLayerFactory;
    import sk.yoz.ycanvas.demo.explorer.modes.onboard.OnBoardPartitionFactory;
    import sk.yoz.ycanvas.demo.explorer.modes.walloffame.WallOfFameLayerFactory;
    import sk.yoz.ycanvas.demo.explorer.modes.walloffame.WallOfFamePartitionFactory;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.CanvasLimits;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.CanvasTransformation;
    import sk.yoz.ycanvas.demo.explorer.valueObjects.FactoryData;

    public class Mode
    {
        public static const ONBOARD:Mode = 
            new Mode(OnBoardLayerFactory, OnBoardPartitionFactory, 
                32, 2, 256, 256, 1, 1 / 32, 0, 0, 1 / 8, 0);
        
        public static const WALLOFFAME:Mode = 
            new Mode(WallOfFameLayerFactory, WallOfFamePartitionFactory, 
                9, 3, 512, 512, 1, 1 / 12, 100000, 10000, 1 / 4, 0);
        
        public var layerFactory:Class;
        public var partitionFactory:Class;
        public var transformation:CanvasTransformation;
        public var limits:CanvasLimits;
        public var factoryData:FactoryData;
        
        public function Mode(layerFactory:Class, partitionFactory:Class, 
            layerMaxLevel:uint, layerStep:uint, partitionWidth:uint, partitionHeight:uint,
            scaleMin:Number, scaleMax:Number,
            x:Number, y:Number, scale:Number, rotation:Number)
        {
            this.layerFactory = layerFactory;
            this.partitionFactory = partitionFactory;
            
            factoryData = new FactoryData;
            factoryData.layerMaxLevel = layerMaxLevel;
            factoryData.layerStep = layerStep;
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