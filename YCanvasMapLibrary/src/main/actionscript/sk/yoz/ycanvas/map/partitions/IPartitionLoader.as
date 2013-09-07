package sk.yoz.ycanvas.map.partitions
{
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    public interface IPartitionLoader
    {
        function load(request:URLRequest, context:LoaderContext):Loader;
        function disposeLoader(loader:Loader):void;
    }
}