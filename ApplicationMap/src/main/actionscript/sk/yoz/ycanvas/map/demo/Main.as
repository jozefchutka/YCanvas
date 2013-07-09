package sk.yoz.ycanvas.map.demo
{
    import feathers.controls.Button;
    import feathers.controls.Callout;
    import feathers.controls.Label;
    import feathers.controls.PickerList;
    import feathers.data.ListCollection;
    import feathers.themes.MetalWorksMobileTheme;
    
    
    import starling.core.Starling;
    import starling.display.Sprite;
    import starling.events.Event;

    public class Main extends Sprite
    {
        private var button:Button;
        private var componentSelector:PickerList;
        private var bigMap:HelperBigMap;
        
        
        public function Main()
        {
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }
        
        private function addedToStageHandler(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

            new MetalWorksMobileTheme();

            bigMap = new HelperBigMap();
            bigMap.map.component.x = 200;
            bigMap.map.component.y = 0;
            bigMap.map.component.width = Starling.current.viewPort.width - bigMap.map.component.x;
            bigMap.map.component.height = Starling.current.viewPort.height;
            
            addChild(bigMap.map.component);
            
            button = new Button();
            button.label = "Click Me";
            button.addEventListener(Event.TRIGGERED, button_triggeredHandler);
            addChild(button);
            button.validate();
            button.x = (stage.stageWidth - button.width) / 2;
            button.y = (stage.stageHeight - button.height) / 2;
            
            componentSelector = new PickerList;
            componentSelector.dataProvider = new ListCollection([
                {"label": "Big Map"}, 
                {"label": "Small Map"}]);
            addChild(componentSelector);
        }
        
        private function button_triggeredHandler(event:Event):void
        {
            const label:Label = new Label();
            label.text = "Hi, I'm Feathers!\nHave a nice day.";
            Callout.show(label, this.button);
        }
    }
}
