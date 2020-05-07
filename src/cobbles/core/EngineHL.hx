package cobbles.core;

#if (hl && !doc_gen)
import cobbles.native.TextProperties;
import cobbles.native.EngineProperties;
import cobbles.native.Engine as NativeEngine;
import cobbles.native.EngineHandle;

class EngineHL implements Engine {
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

    final _outputInfo:OutputInfo = new OutputInfo();

    final engineProperties:EngineProperties;
    final textProperties:TextProperties;

    final library:LibraryHL;
    final handle:EngineHandle;

    var enginePropertiesDirty = false;
    var textPropertiesDirty = false;

    var _disposed = false;

    public function new(library:LibraryHL) {
        this.library = library;
        handle = NativeEngine.new_(library.handle);
        library.checkError();

        engineProperties = new EngineProperties();
        textProperties = new TextProperties();

        NativeEngine.getProperties(handle, engineProperties);
        NativeEngine.getTextProperties(handle, textProperties);
    }

    public function dispose() {
        NativeEngine.delete_(handle);
        _disposed = true;
    }

    public function isDisposed() {
        return _disposed;
    }

    function get_lineLength():Int {
        return engineProperties.lineLength;
    }

    function set_lineLength(value:Int):Int {
        enginePropertiesDirty = true;
        return engineProperties.lineLength = value;
    }

    function get_locale():String {
        return engineProperties.locale;
    }

    function set_locale(value:String):String {
        enginePropertiesDirty = true;
        return engineProperties.locale = value;
    }

    function get_textAlignment():TextAlignment {
        return engineProperties.textAlignment;
    }

    function set_textAlignment(value:TextAlignment):TextAlignment {
        enginePropertiesDirty = true;
        return engineProperties.textAlignment = value;
    }

    function get_language():String {
        return textProperties.language;
    }

    function set_language(value:String):String {
        textPropertiesDirty = true;
        return textProperties.language = value;
    }

    function get_script():String {
        return textProperties.script;
    }

    function set_script(value:String):String {
        textPropertiesDirty = true;
        return textProperties.script = value;
    }

    function get_scriptDirection():ScriptDirection {
        return textProperties.scriptDirection;
    }

    function set_scriptDirection(value:ScriptDirection):ScriptDirection {
        textPropertiesDirty = true;
        return textProperties.scriptDirection = value;
    }

    function get_font():FontID {
        return textProperties.font;
    }

    function set_font(value:FontID):FontID {
        textPropertiesDirty = true;
        return textProperties.font = value;
    }

    function get_fontSize():Float {
        return textProperties.fontSize;
    }

    function set_fontSize(value:Float):Float {
        textPropertiesDirty = true;
        return textProperties.fontSize = value;
    }

    function get_customProperty():CustomPropertyID {
        return textProperties.customProperty;
    }

    function set_customProperty(value:CustomPropertyID):CustomPropertyID {
        textPropertiesDirty = true;
        return textProperties.customProperty = value;
    }

    function get_outputInfo():OutputInfo {
        return _outputInfo;
    }

    public function tiles():Array<TileInfo> {
        NativeEngine.prepareTiles(handle);
        library.checkError();

        final length = NativeEngine.getTileCount(handle);
        final tiles = new hl.types.ArrayObj<TileInfo>();

        for (index in 0...length) {
            tiles.push({
                glyphID: 0,
                atlasX: 0,
                atlasY: 0,
            });
        }

        NativeEngine.getTiles(handle, tiles);

        return cast tiles;
    }

    public function advances():Array<AdvanceInfo> {
        NativeEngine.prepareAdvances(handle);
        library.checkError();

        final length = NativeEngine.getAdvanceCount(handle);
        final advances = new hl.types.ArrayObj<AdvanceInfo>();

        for (index in 0...length) {
            advances.push({
                type: Invalid,
                textIndex: 0,
                advanceX: 0,
                advanceY: 0,
                glyphID: 0,
                glyphOffsetX: 0,
                glyphOffsetY: 0,
                inlineObject: 0,
                customProperty: 0,
            });
        }

        NativeEngine.getAdvances(handle, advances);

        return cast advances;
    }

    public function addText(text:String):Void {
        applyProperties();
        NativeEngine.addText(handle, text);
    }

    public function addInlineObject(id:InlineObjectID, width:Int, height:Int):Void {
        applyProperties();
        NativeEngine.addInlineObject(handle, id, width, height);
    }

    function applyProperties() {
        if (enginePropertiesDirty) {
            enginePropertiesDirty = false;
            NativeEngine.setProperties(handle, engineProperties);
        }

        if (textPropertiesDirty) {
            textPropertiesDirty = false;
            NativeEngine.setTextProperties(handle, textProperties);
        }
    }

    public function clear():Void {
        NativeEngine.clear(handle);
    }

    public function clearTiles():Void {
        NativeEngine.clearTiles(handle);
    }

    public function layOut():Void {
        NativeEngine.layOut(handle);
        library.checkError();
        NativeEngine.getOutputInfo(handle, outputInfo);
    }

    public function tilesValid():Bool {
        return NativeEngine.tilesValid(handle);
    }

    public function rasterize():Void {
        NativeEngine.rasterize(handle);
        library.checkError();
    }

    public function packTiles(width:Int, height:Int):Bool {
        return NativeEngine.packTiles(handle, width, height);
    }

}
#end
