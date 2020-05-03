package cobbles.core;

interface Engine extends Disposable {
    public var lineLength(get, set):Int;
    public var locale(get, set):String;
    public var textAlignment(get, set):TextAlignment;
    public var language(get, set):String;
    public var script(get, set):String;
    public var scriptDirection(get, set):ScriptDirection;
    public var font(get, set):FontID;
    public var fontSize(get, set):Float;
    public var customProperty(get, set):CustomPropertyID;
    public var outputInfo(get, never):OutputInfo;

    public function tiles():Array<TileInfo>;
    public function advances():Array<AdvanceInfo>;
    public function addText(text:String):Void;
    public function addInlineObject(id:InlineObjectID, size:Int):Void;
    public function clear():Void;
    public function layOut():Void;
    public function tilesValid():Bool;
    public function rasterize():Void;
    public function packTiles(width:Int, height:Int):Bool;
}
