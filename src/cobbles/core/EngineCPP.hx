package cobbles.core;

#if (cpp && !doc_gen)
import cpp.Pointer;
import cobbles.native.EngineProperties;
import cpp.Native;
import cpp.NativeGc;
import cobbles.native.Engine as NativeEngine;
import cobbles.native.TextProperties;
import cobbles.native.CPPUtil;

class EngineCPP implements Engine {
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

    final library:LibraryCPP;
    @:unreflective final handle:NativeEngine;

    @:unreflective final engineProperties:EngineProperties;
    @:unreflective final textProperties:TextProperties;

    var enginePropertiesDirty = false;
    var textPropertiesDirty = false;

    var _disposed = false;

    public function new(library:LibraryCPP) {
        this.library = library;
        handle = NativeEngine.new_(library.handle);
        library.checkError();

        final enginePropertiesSize =
            CPPUtil.sizeof(Native.star(@:nullSafety(Off) engineProperties));
        final textPropertiesSize =
            CPPUtil.sizeof(Native.star(@:nullSafety(Off) textProperties));

        engineProperties = cast NativeGc.allocGcBytesRaw(
            enginePropertiesSize, false);
        textProperties = cast NativeGc.allocGcBytesRaw(
            textPropertiesSize, false);

        final currentEngineProperties = NativeEngine.getProperties(handle);
        final currentTextProperties = NativeEngine.getTextProperties(handle);
        Native.nativeMemcpy(
            cast engineProperties, cast currentEngineProperties,
            enginePropertiesSize);
        Native.nativeMemcpy(
            cast textProperties, cast currentTextProperties,
            textPropertiesSize);
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
        final rawPointer = NativeEngine.getTiles(handle);
        final pointer = Pointer.fromRaw(rawPointer);

        final tiles_ = new Array<TileInfo>();

        for (index in 0...length) {
            final info = pointer.at(index);

            tiles_.push({
                glyphID: info.glyphID,
                atlasX: info.atlasX,
                atlasY: info.atlasY,
            });
        }

        return tiles_;
    }

    public function advances():Array<AdvanceInfo> {
        NativeEngine.prepareAdvances(handle);
        library.checkError();

        final length = NativeEngine.getAdvanceCount(handle);
        final rawPointer = NativeEngine.getAdvances(handle);
        final pointer = Pointer.fromRaw(rawPointer);

        final advances_ = new Array<AdvanceInfo>();

        for (index in 0...length) {
            final info = pointer.at(index);

            advances_.push({
                type: info.type,
                textIndex: info.textIndex,
                advanceX: info.advanceX,
                advanceY: info.advanceY,
                glyphID: info.glyphID,
                glyphOffsetX: info.glyphOffsetX,
                glyphOffsetY: info.glyphOffsetY,
                inlineObject: info.inlineObject,
                customProperty: info.customProperty,
            });
        }

        return advances_;
    }

    public function addText(text:String):Void {
        applyProperties();
        NativeEngine.addText(handle, text, -1);
    }

    public function addInlineObject(id:InlineObjectID, size:Int):Void {
        applyProperties();
        NativeEngine.addInlineObject(handle, id, size);
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

    public function layOut():Void {
        applyProperties();
        NativeEngine.layOut(handle);
        library.checkError();

        final nativeOutputInfo = NativeEngine.getOutputInfo(handle);

        outputInfo.textWidth = nativeOutputInfo.textWidth;
        outputInfo.textHeight = nativeOutputInfo.textHeight;
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
