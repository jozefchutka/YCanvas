package sk.yoz.ycanvas.map.partitions
{
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    /**
    * Reasons for using partition loader:
    * - Performance: There might be dozens or even more than a hundred load()
    * calls during one frame execution. On some systems (IE) using Loader.load()
    * method might have big performance impact (100 load()s can take 2 seconds
    * to evaluate) causing app to lag.
    * - Memory leaks: Using profiler, you may find there are some instances of
    * Loader class that could not have been GCed event though there is no 
    * listener attached to it. A lot of those can be released using 
    * unloadAndStop() method, but even this is not 100%. 
    * You may also optimize the performance and memory consumption by pooling
    * the instances of Loader. 
    * - Traffic: The reason for this is that Loader.close() method might not
    * work as expected and the data will be transfered through the network 
    * anyway. You might want to optimize load process by using a buffer, that 
    * would not execute more than a specified amount of requests simultaneously.
    */
    public interface IPartitionLoader
    {
        /**
        * Is called when partition is ready to be loaded.
        */
        function load(request:URLRequest, context:LoaderContext):Loader;
        
        /**
        * Is called when partition has been loaded and the loader can be
        * disposed or just to cancel the loading process.
        */
        function disposeLoader(loader:Loader):void;
    }
}