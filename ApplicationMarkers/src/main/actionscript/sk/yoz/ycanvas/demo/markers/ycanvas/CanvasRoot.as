package sk.yoz.ycanvas.demo.markers.ycanvas
{
    import sk.yoz.ycanvas.starling.YCanvasRootStarling;
    
    import starling.display.DisplayObject;
    import starling.display.Sprite;
    
    public class CanvasRoot extends YCanvasRootStarling
    {
        private var mapTilesContainer:Sprite = new Sprite;
        private var markersContainer:Sprite = new Sprite;
        
        public function init():void
        {
            addChild(mapTilesContainer);
            addChild(markersContainer);
        }
        
        public function addMarker(marker:Marker):void
        {
            markersContainer.addChild(marker);
        }
        
        public function removeMarker(marker:Marker):void
        {
            markersContainer.removeChild(marker);
        }
        
        override protected function addLayerChild(child:DisplayObject):void
        {
            mapTilesContainer.addChild(child);
        }
        
        override protected function setLayerChildIndex(child:DisplayObject, index:int):void
        {
            mapTilesContainer.setChildIndex(child, index);
        }
        
        override protected function removeLayerChild(child:DisplayObject):void
        {
            mapTilesContainer.removeChild(child);
        }
    }
}