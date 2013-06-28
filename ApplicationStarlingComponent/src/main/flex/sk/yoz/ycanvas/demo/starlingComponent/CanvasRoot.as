package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.geom.Point;
    
    import sk.yoz.ycanvas.stage3D.YCanvasRootStage3D;
    
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    
    public class CanvasRoot extends YCanvasRootStage3D
    {
        private var layerContainer:Sprite = new Sprite;
        private var graphicsContainer:Sprite = new Sprite;
        private var markersContainer:Sprite = new Sprite;
        
        private var markers:Vector.<DisplayObject> = new Vector.<DisplayObject>;
        private var strokes:Vector.<YStroke> = new Vector.<YStroke>;
        
        public function CanvasRoot()
        {
            super();
            
            addChild(layerContainer);
            addChild(graphicsContainer);
            addChild(markersContainer);
        }
        
        override public function set scale(value:Number):void
        {
            super.scale = value;
            
            var markersScale:Number = 1 / value
            for(var i:uint = markers.length; i--;)
                markers[i].scaleX = markers[i].scaleY = markersScale;
            
            for(i = strokes.length; i--;)
            {
                var stroke:YStroke = strokes[i];
                stroke.thickness = stroke.originalThickness / value;
                stroke.update();
            }
        }
        
        override public function set rotation(value:Number):void
        {
            super.rotation = value;
            
            var markersRotation:Number = -value;
            for(var i:uint = markers.length; i--;)
                markers[i].rotation = markersRotation;
        }
        
        public function setCanvasCenter(center:Point):void
        {
            graphicsContainer.x = -center.x;
            graphicsContainer.y = -center.y;
            
            markersContainer.x = -center.x;
            markersContainer.y = -center.y;
        }
        
        public function addStroke(stroke:YStroke):void
        {
            stroke.thickness = stroke.originalThickness / scaleX;
            stroke.update();
            strokes.push(stroke);
            graphicsContainer.addChild(stroke);
        }
        
        public function addMarker(marker:DisplayObject):void
        {
            marker.scaleX = marker.scaleY = 1 / scaleX;
            marker.rotation = -rotation;
            markers.push(marker);
            markersContainer.addChild(marker);
        }
        
        public function removeMarker(marker:DisplayObject):void
        {
            markers.splice(markers.indexOf(marker), 1);
            markersContainer.removeChild(marker);
        }
        
        override protected function addLayerChild(child:DisplayObject):void
        {
            layerContainer.addChild(child);
        }
        
        override protected function setLayerChildIndex(child:DisplayObject, index:int):void
        {
            layerContainer.setChildIndex(child, index);
        }
        
        override protected function removeLayerChild(child:DisplayObject):void
        {
            layerContainer.removeChild(child);
        }
    }
}