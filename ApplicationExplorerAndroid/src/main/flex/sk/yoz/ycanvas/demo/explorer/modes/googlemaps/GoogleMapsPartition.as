package sk.yoz.ycanvas.demo.explorer.modes.googlemaps
{
    import flash.events.IEventDispatcher;
    
    import sk.yoz.ycanvas.demo.explorer.modes.Layer;
    import sk.yoz.ycanvas.demo.explorer.modes.Partition;
    
    public class GoogleMapsPartition extends Partition
    {
        //ABQIAAAAywdNoEbnfO1cvDEjsXD7JRSp2vYytnKUG70oF2HClx6io7ZA8xQbb0GxvLOXlcPFIeYGxl88KyPZrg
        //http://maps.googleapis.com/maps/api/staticmap?parameters
        
        //http://maps.googleapis.com/mapsapi/crossdomain.xml
        
        // http://mt1.google.com/vt/lyrs=m@169000000&hl=cs&src=api&x=15076&y=9833&zoom=3&s=Galil
        // http://khm1.google.com/kh/v=101&cookie=fzwq1PzzL9d09_SW7CfkNin7rIHh1OyK8nNcUg&t=trtqtqrttqqsqrtt
        
        //http://gmaps-samples-flash.googlecode.com/svn/trunk/demos/PrintableMap/PrintableMap.html
        
        public function GoogleMapsPartition(layer:Layer, x:int, y:int, 
            requestedWidth:uint, requestedHeight:uint, dispatcher:IEventDispatcher)
        {
            super(layer, x, y, requestedWidth, requestedHeight, dispatcher);
        }
    }
}