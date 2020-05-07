package cobbles.core;

#if (js && !doc_gen)
import cobbles.native.AdvanceType;
import cobbles.native.ScriptDirection.ScriptDirectionHelper;
import cobbles.native.TextAlignment.TextAlignmentHelper;

class EngineJS implements Engine {
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

    final _outputInfo:OutputInfo;

    final library:LibraryJS;
    final jsEngine:cobbles.native.Engine;

    var _disposed = false;

    public function new(library:LibraryJS) {
        this.library = library;
        jsEngine = js.Syntax.code("new {0}.Engine({1})", library.module,
            library.jsLibrary);

        _outputInfo = new OutputInfo();
    }

    public function dispose() {
        jsEngine.delete();
        _disposed = true;
    }

    public function isDisposed() {
        return _disposed;
    }

    function get_lineLength():Int {
        return jsEngine.lineLength;
    }

    function set_lineLength(value:Int):Int {
        return jsEngine.lineLength = value;
    }

    function get_locale():String {
        return jsEngine.locale;
    }

    function set_locale(value:String):String {
        return jsEngine.locale = value;
    }

    function get_textAlignment():TextAlignment {
        return TextAlignmentHelper.fromNative(jsEngine.textAlignment);
    }

    function set_textAlignment(value:TextAlignment):TextAlignment {
        jsEngine.textAlignment = TextAlignmentHelper.toNative(
            library.module, value);
        return value;
    }

    function get_language():String {
        return jsEngine.language;
    }

    function set_language(value:String):String {
        return jsEngine.language = value;
    }

    function get_script():String {
        return jsEngine.script;
    }

    function set_script(value:String):String {
        return jsEngine.script = value;
    }

    function get_scriptDirection():ScriptDirection {
        return ScriptDirectionHelper.fromNative(jsEngine.scriptDirection);
    }

    function set_scriptDirection(value:ScriptDirection):ScriptDirection {
        jsEngine.scriptDirection = ScriptDirectionHelper.toNative(
            library.module, value);
        return value;
    }

    function get_font():FontID {
        return jsEngine.font;
    }

    function set_font(value:FontID):FontID {
        return jsEngine.font = value;
    }

    function get_fontSize():Float {
        return jsEngine.fontSize;
    }

    function set_fontSize(value:Float):Float {
        return jsEngine.fontSize = value;
    }

    function get_customProperty():CustomPropertyID {
        return jsEngine.customProperty;
    }

    function set_customProperty(value:CustomPropertyID):CustomPropertyID {
        return jsEngine.customProperty = value;
    }

    function get_outputInfo():OutputInfo {
        return _outputInfo;
    }

    public function tiles():Array<TileInfo> {
        final jsTiles = jsEngine.tiles();
        final tiles_ = new Array<TileInfo>();

        for (index in 0...jsTiles.size()) {
            final jsInfo = jsTiles.get(index);

            tiles_.push({
                glyphID: jsInfo.glyphID,
                atlasX: jsInfo.atlasX,
                atlasY: jsInfo.atlasY,
            });
        }

        jsTiles.delete();

        return tiles_;
    }

    public function advances():Array<AdvanceInfo> {
        final jsAdvances = jsEngine.advances();
        final advances_ = new Array<AdvanceInfo>();

        for (index in 0...jsAdvances.size()) {
            final jsInfo = jsAdvances.get(index);

            advances_.push({
                type: AdvanceTypeHelper.fromNative(jsInfo.type),
                textIndex: jsInfo.textIndex,
                advanceX: jsInfo.advanceX,
                advanceY: jsInfo.advanceY,
                glyphID: jsInfo.glyphID,
                glyphOffsetX: jsInfo.glyphOffsetX,
                glyphOffsetY: jsInfo.glyphOffsetY,
                inlineObject: jsInfo.inlineObject,
                customProperty: jsInfo.customProperty,
            });
        }

        jsAdvances.delete();

        return advances_;
    }

    public function addText(text:String) {
        jsEngine.addTextUTF8(text);
    }

    public function addInlineObject(id:InlineObjectID, width:Int, height:Int) {
        jsEngine.addInlineObject(id, width, height);
    }

    public function clear() {
        jsEngine.clear();
    }

    public function clearTiles() {
        jsEngine.clearTiles();
    }

    public function layOut() {
        jsEngine.layOut();

        final jsInfo = jsEngine.outputInfo;
        outputInfo.textWidth = jsInfo.textWidth;
        outputInfo.textHeight = jsInfo.textHeight;
    }

    public function tilesValid():Bool {
        return jsEngine.tilesValid();
    }

    public function rasterize() {
        jsEngine.rasterize();
    }

    public function packTiles(width:Int, height:Int):Bool {
        return jsEngine.packTiles(width, height);
    }
}
#end
