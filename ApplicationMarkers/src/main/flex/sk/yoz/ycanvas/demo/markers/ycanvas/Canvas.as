package sk.yoz.ycanvas.demo.markers.ycanvas
{
    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    import sk.yoz.ycanvas.stage3D.YCanvasStage3D;
    
    public class Canvas extends YCanvasStage3D
    {
        private var _markers:Vector.<Marker> = new Vector.<Marker>;
        
        public function Canvas(stage:Stage, stage3D:Stage3D, viewPort:Rectangle,
            initCallback:Function, rootClass:Class=null)
        {
            super(stage, stage3D, viewPort, initCallback, rootClass);
            
            marginOffset = 256;
        }
        
        public function get markers():Vector.<Marker>
        {
            return _markers;
        }
        
        public function disposeLayers():void
        {
            while(layers.length)
                disposeLayer(layers[0]);
            
            var root:CanvasRoot = this.root as CanvasRoot;
            while(markers.length)
                removeMarker(markers[0]);
        }
        
        public function addMarker(marker:Marker):void
        {
            (root as CanvasRoot).addMarker(marker);
            marker.canvasCenter = center;
            marker.canvasScale = scale;
            marker.canvasRotation = rotation;
            markers.push(marker);
        }
        
        public function removeMarker(marker:Marker):void
        {
            (root as CanvasRoot).removeMarker(marker);
            markers.splice(markers.indexOf(marker), 1);
        }
        
        override public function set center(value:Point):void
        {
            for(var i:uint = markers.length; i--;)
                markers[i].canvasCenter = value;
            super.center = value;
        }
        
        override public function set scale(value:Number):void
        {
            for(var i:uint = markers.length; i--;)
                markers[i].canvasScale = value;
            super.scale = value;
        }
        
        override public function set rotation(value:Number):void
        {
            for(var i:uint = markers.length; i--;)
                markers[i].canvasRotation = value;
            super.rotation = value;
        }
    }
}