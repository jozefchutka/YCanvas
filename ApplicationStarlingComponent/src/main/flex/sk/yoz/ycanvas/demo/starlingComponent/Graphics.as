package sk.yoz.ycanvas.demo.starlingComponent
{
    import flash.display.GraphicsPath;
    import flash.display.GraphicsPathCommand;
    import flash.display.GraphicsSolidFill;
    import flash.display.GraphicsStroke;
    import flash.display.IGraphicsData;
    import flash.geom.Point;
    
    import starling.display.DisplayObjectContainer;
    
    public class Graphics extends DisplayObjectContainer
    {
        public var canvasToViewPort:Function;
        
        private var data:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
        
        public function clear():void
        {
            data.length = 0;
        }
        
        public function lineStyle(thickness:Number, color:uint, alpha:Number=1):void
        {
            var stroke:GraphicsStroke = new GraphicsStroke(thickness);
            stroke.fill = new GraphicsSolidFill(color, alpha);
            data.push(stroke)
        }
        
        public function moveTo(x:Number, y:Number):void
        {
            data.push(new GraphicsPath(
                Vector.<int>([GraphicsPathCommand.MOVE_TO]),
                Vector.<Number>([x, y])));
        }
        
        public function lineTo(x:Number, y:Number):void
        {
            data.push(new GraphicsPath(
                Vector.<int>([GraphicsPathCommand.LINE_TO]),
                Vector.<Number>([x, y])));
        }
        
        public function draw():void
        {
            if(canvasToViewPort == null)
                return;
            
            if(!data.length)
                return;
            
            removeChildren(0, numChildren);
            
            var thickness:Number = 1;
            var color:uint = 0;
            var alpha:Number = 1;
            var pointer:Point = new Point(0, 0);
            var chIndex:int = 0;
            var createCircle:Boolean = true;
            
            for(var i:uint = 0, length:uint = data.length; i < length; i++)
            {
                var item:IGraphicsData = data[i];
                if(item is GraphicsStroke)
                {
                    var stroke:GraphicsStroke = item as GraphicsStroke;
                    var fill:GraphicsSolidFill = stroke.fill ? stroke.fill as GraphicsSolidFill : null;
                    thickness = stroke.thickness;
                    color = fill ? fill.color : 0x0;
                    alpha = fill ? fill.alpha : 1;
                    createCircle = true;
                }
                else if(item is GraphicsPath)
                {
                    var path:GraphicsPath = item as GraphicsPath;
                    for(var j:uint = 0, lengthj:uint = path.commands.length; j < lengthj; j++)
                    {
                        var command:int = path.commands[j];
                        var dataPointer:Point = new Point(path.data[j * 2], path.data[j * 2 + 1]);
                        
                        if(command == GraphicsPathCommand.LINE_TO)
                        {
                            var p0:Point = canvasToViewPort(pointer);
                            var p1:Point = canvasToViewPort(dataPointer);
                            var delta:Point = new Point(p1.x - p0.x, p1.y - p0.y);
                            var rotation:Number = Math.atan2(delta.y, delta.x);
                            
                            var p1x:Number = p0.x + Math.sin(rotation) * thickness / 2;
                            var p1y:Number = p0.y - Math.cos(rotation) * thickness / 2;
                            
                            var p2x:Number = p0.x - Math.sin(rotation) * thickness / 2;
                            var p2y:Number = p0.y + Math.cos(rotation) * thickness / 2;
                            
                            var p3x:Number = p1.x + Math.sin(rotation) * thickness / 2;
                            var p3y:Number = p1.y - Math.cos(rotation) * thickness / 2;
                            
                            var p4x:Number = p1.x - Math.sin(rotation) * thickness / 2;
                            var p4y:Number = p1.y + Math.cos(rotation) * thickness / 2;
                            
                            if(createCircle)
                                handleCircle(p0.x, p0.y, thickness / 2, color, alpha);
                            
                            handlePolygon(p1x, p1y, p2x, p2y, p3x, p3y, color, alpha);
                            handlePolygon(p2x, p2y, p3x, p3y, p4x, p4y, color, alpha);
                            handleCircle(p1.x, p1.y, thickness / 2, color, alpha);
                            
                            createCircle = false;
                        }
                        else
                        {
                            createCircle = true;
                        }
                        
                        pointer = dataPointer;
                    }
                }
            }
        }
        
        private function handlePolygon(p1x:Number, p1y:Number, p2x:Number, p2y:Number, p3x:Number, p3y:Number, color:uint, alpha:Number):void
        {
            var polygon:Triangle = new Triangle(p1x, p1y, p2x, p2y, p3x, p3y, color);
            polygon.alpha = alpha;
            addChild(polygon);
        }
        
        private function handleCircle(x:Number, y:Number, radius:Number, color:uint, alpha:Number):void
        {
            var circle:Circle = new Circle(radius, 10, color);
            circle.x = x;
            circle.y = y;
            circle.alpha = alpha;
            addChild(circle);
        }
        
        
            
        
        /*
        public function draw():void
        {
            if(canvasToViewPort == null)
                return;
            
            if(!data.length)
                return;
            
            var thickness:Number = 1;
            var color:uint = 0;
            var alpha:Number = 1;
            var pointer:Point = new Point(0, 0);
            var quad:Quad;
            var chIndex:int = 0;
            
            for(var i:uint = 0, length:uint = data.length; i < length; i++)
            {
                var item:IGraphicsData = data[i];
                if(item is GraphicsStroke)
                {
                    var stroke:GraphicsStroke = item as GraphicsStroke;
                    var fill:GraphicsSolidFill = stroke.fill ? stroke.fill as GraphicsSolidFill : null;
                    thickness = stroke.thickness;
                    color = fill ? fill.color : 0x0;
                    alpha = fill ? fill.alpha : 1;
                }
                else if(item is GraphicsPath)
                {
                    var path:GraphicsPath = item as GraphicsPath;
                    for(var j:uint = 0, lengthj:uint = path.commands.length; j < lengthj; j++)
                    {
                        var command:int = path.commands[j];
                        var dataPointer:Point = new Point(path.data[j * 2], path.data[j * 2 + 1]);
                        
                        if(command == GraphicsPathCommand.LINE_TO)
                        {
                            var p0:Point = canvasToViewPort(pointer);
                            var p1:Point = canvasToViewPort(dataPointer);
                            
                            quad = chIndex < numChildren ? getChildAt(chIndex) as Quad : new Quad(1, 1);
                            handleQuad(quad, p0, p1, thickness, color, alpha);
                            if(!quad.parent)
                                addChild(quad);
                            
                            chIndex++;
                        }
                        
                        pointer = dataPointer;
                    }
                }
            }
            
            removeChildren(chIndex, numChildren);
        }
        
        private function handleQuad(quad:Quad, p0:Point, p1:Point, thickness:Number, color:uint, alpha:Number):void
        {
            var delta:Point = new Point(p1.x - p0.x, p1.y - p0.y);
            var rotation:Number = Math.atan2(delta.y, delta.x);
            
            quad.rotation = 0;
            quad.width = Math.sqrt(delta.x * delta.x + delta.y * delta.y);
            quad.height = thickness;
            quad.color = color;
            quad.alpha = alpha;
            quad.x = p0.x + Math.sin(rotation) * thickness / 2;
            quad.y = p0.y - Math.cos(rotation) * thickness / 2;
            quad.rotation = rotation;
        }//*/
    }
}