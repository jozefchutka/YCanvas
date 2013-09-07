package sk.yoz.ycanvas.map.demo.partition
{
    import flash.display.Loader;
    
    import sk.yoz.net.LoaderOptimizer;
    import sk.yoz.ycanvas.map.partitions.IPartitionLoader;
    
    public class PartitionLoader extends LoaderOptimizer 
        implements IPartitionLoader
    {
        public function disposeLoader(loader:Loader):void
        {
            release(loader);
        }
    }
}