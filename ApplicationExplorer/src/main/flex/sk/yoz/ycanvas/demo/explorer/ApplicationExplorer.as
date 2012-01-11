package sk.yoz.ycanvas.demo.explorer
{
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import net.hires.debug.Stats;
    
    import sk.yoz.ycanvas.demo.explorer.managers.CanvasManager;
    import sk.yoz.ycanvas.demo.explorer.managers.TransformationManager;
    import sk.yoz.ycanvas.demo.explorer.modes.onboard.OnBoardLayerFactory;
    import sk.yoz.ycanvas.demo.explorer.modes.onboard.OnBoardPartitionFactory;
    import sk.yoz.ycanvas.demo.explorer.modes.walloffame.WallOfFameLayerFactory;
    import sk.yoz.ycanvas.demo.explorer.modes.walloffame.WallOfFamePartitionFactory;
    import sk.yoz.ycanvas.demo.explorer.view.Board;
    import sk.yoz.ycanvas.interfaces.ILayerFactory;
    import sk.yoz.ycanvas.interfaces.IPartitionFactory;
    
    [SWF(frameRate="60", backgroundColor="#ffffff")]
    public class ApplicationExplorer extends Sprite
    {
        private var board:Board = new Board;
        
        private var canvasManager:CanvasManager;
        private var transformationManager:TransformationManager;
        
        public function ApplicationExplorer()
        {
            stage ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(... rest):void
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            addChild(new Stats);
            
            board.doubleClickEnabled = true;
            
            var partitionFactory:IPartitionFactory = new WallOfFamePartitionFactory(this);
            var layerFactory:ILayerFactory = new WallOfFameLayerFactory(partitionFactory);
            
            canvasManager = new CanvasManager(stage, stage.stage3Ds[0], viewPort, 
                canvasInit, this, partitionFactory, layerFactory);
            
            stage.addEventListener(Event.RESIZE, onStageResize);
            updateViewPort();
        }
        
        private function canvasInit():void
        {
            canvasManager.canvas.center = new Point(0, 0);
            canvasManager.canvas.rotation = 0;
            canvasManager.canvas.scale = 1;
            
            transformationManager = new TransformationManager(canvasManager.canvas, board, this, stage);
            
            addChild(board);
        }
        
        private function get viewPort():Rectangle
        {
            var left:uint = 0;
            var right:uint = 0;
            var top:uint = 0;
            var bottom:uint = 0;
            var width:uint = stage.stageWidth;
            var height:uint = stage.stageHeight;
            return new Rectangle(left, top, width - left - right, height - top - bottom);
        }
        
        private function updateViewPort():void
        {
            canvasManager.viewPort = viewPort;
            board.viewPort = viewPort;
            transformationManager && transformationManager.resize();
        }
        
        private function onStageResize(event:Event):void
        {
            updateViewPort();
        }
    }
}