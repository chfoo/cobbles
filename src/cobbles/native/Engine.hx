package cobbles.native;

#if (cpp && !doc_gen)

import cpp.ConstCharStar;
import cpp.RawPointer;
import cobbles.native.EngineProperties.ConstEngineProperties;
import cobbles.native.TextProperties.ConstTextProperties;

@:include("cobbletext/cobbletext.h")
@:native("CobbletextEngine *")
extern class Engine {
    @:native("cobbletext_engine_new")
    static public function new_(library:Library):Engine;

    @:native("cobbletext_engine_delete")
    static public function delete_(engine:Engine):Void;

    @:native("cobbletext_engine_get_properties")
    static public function getProperties(engine:Engine):ConstEngineProperties;

    @:native("cobbletext_engine_set_properties")
    static public function setProperties(engine:Engine, properties:EngineProperties):Void;

    @:native("cobbletext_engine_get_text_properties")
    static public function getTextProperties(engine:Engine):ConstTextProperties;

    @:native("cobbletext_engine_set_text_properties")
    static public function setTextProperties(engine:Engine, textProperties:TextProperties):Void;

    @:native("cobbletext_engine_add_text_utf8")
    static public function addText(engine:Engine, text:ConstCharStar, length:Int):Void;

    @:native("cobbletext_engine_add_inline_object")
    static public function addInlineObject(engine:Engine, id:Int, width:Int, height:Int):Void;

    @:native("cobbletext_engine_clear")
    static public function clear(engine:Engine):Void;

    @:native("cobbletext_engine_clear_tiles")
    static public function clearTiles(engine:Engine):Void;

    @:native("cobbletext_engine_lay_out")
    static public function layOut(engine:Engine):Void;

    @:native("cobbletext_engine_tiles_valid")
    static public function tilesValid(engine:Engine):Bool;

    @:native("cobbletext_engine_rasterize")
    static public function rasterize(engine:Engine):Void;

    @:native("cobbletext_engine_pack_tiles")
    static public function packTiles(engine:Engine, width:Int, height:Int):Bool;

    @:native("cobbletext_engine_prepare_tiles")
    static public function prepareTiles(engine:Engine):Void;

    @:native("cobbletext_engine_get_tile_count")
    static public function getTileCount(engine:Engine):Int;

    @:native("cobbletext_engine_get_tiles")
    static public function getTiles(engine:Engine):RawPointer<TileInfo>;

    @:native("cobbletext_engine_prepare_advances")
    static public function prepareAdvances(engine:Engine):Void;

    @:native("cobbletext_engine_get_advance_count")
    static public function getAdvanceCount(engine:Engine):Int;

    @:native("cobbletext_engine_get_advances")
    static public function getAdvances(engine:Engine):RawPointer<AdvanceInfo>;

    @:native("cobbletext_engine_get_output_info")
    static public function getOutputInfo(engine:Engine):OutputInfo;
}

#elseif (hl && !doc_gen)

extern class Engine {
    @:hlNative("cobbles", "engine_new")
    static public function new_(library:LibraryHandle):EngineHandle;

    @:hlNative("cobbles", "engine_delete")
    static public function delete_(engine:EngineHandle):Void;

    @:hlNative("cobbles", "engine_get_properties")
    static public function getProperties(engine:EngineHandle, out_properties:EngineProperties):Void;

    @:hlNative("cobbles", "engine_set_properties")
    static public function setProperties(engine:EngineHandle, properties:EngineProperties):Void;

    @:hlNative("cobbles", "engine_get_text_properties")
    static public function getTextProperties(engine:EngineHandle, out_textProperties:TextProperties):Void;

    @:hlNative("cobbles", "engine_set_text_properties")
    static public function setTextProperties(engine:EngineHandle, textProperties:TextProperties):Void;

    @:hlNative("cobbles", "engine_add_text")
    static public function addText(engine:EngineHandle, text:String):Void;

    @:hlNative("cobbles", "engine_add_inline_object")
    static public function addInlineObject(engine:EngineHandle, id:Int, width:Int, height:Int):Void;

    @:hlNative("cobbles", "engine_clear")
    static public function clear(engine:EngineHandle):Void;

    @:hlNative("cobbles", "engine_clear_tiles")
    static public function clearTiles(engine:EngineHandle):Void;

    @:hlNative("cobbles", "engine_lay_out")
    static public function layOut(engine:EngineHandle):Void;

    @:hlNative("cobbles", "engine_tiles_valid")
    static public function tilesValid(engine:EngineHandle):Bool;

    @:hlNative("cobbles", "engine_rasterize")
    static public function rasterize(engine:EngineHandle):Void;

    @:hlNative("cobbles", "engine_pack_tiles")
    static public function packTiles(engine:EngineHandle, width:Int, height:Int):Bool;

    @:hlNative("cobbles", "engine_prepare_tiles")
    static public function prepareTiles(engine:EngineHandle):Void;

    @:hlNative("cobbles", "engine_get_tile_count")
    static public function getTileCount(engine:EngineHandle):Int;

    @:hlNative("cobbles", "engine_get_tiles")
    static public function getTiles(engine:EngineHandle, out_tiles:hl.types.ArrayObj<TileInfo>):Void;

    @:hlNative("cobbles", "engine_prepare_advances")
    static public function prepareAdvances(engine:EngineHandle):Void;

    @:hlNative("cobbles", "engine_get_advance_count")
    static public function getAdvanceCount(engine:EngineHandle):Int;

    @:hlNative("cobbles", "engine_get_advances")
    static public function getAdvances(engine:EngineHandle, out_advances:hl.types.ArrayObj<AdvanceInfo>):Void;

    @:hlNative("cobbles", "engine_get_output_info")
    static public function getOutputInfo(engine:EngineHandle, out_outputInfo:OutputInfo):Void;
}

#elseif (js && !doc_gen)

import js.lib.ArrayBuffer;

extern class Engine {
    public var lineLength:Int;
    public var locale:String;
    public var textAlignment:TextAlignment;
    public var language:String;
    public var script:String;
    public var scriptDirection:ScriptDirection;
    public var font:Int;
    public var fontSize:Float;
    public var customProperty:Int;
    public var outputInfo:OutputInfo;

    public function tiles():EmbindVector<TileInfo>;
    public function advances():EmbindVector<AdvanceInfo>;

    public function delete():Void;

    public function addText(data:ArrayBuffer, encoding:Int):Void;
    public function addTextUTF8(text:String):Void;
    public function addTextUTF16(text:String):Void;
    public function addTextUTF32(text:EmbindVector<Int>):Void;

    public function addInlineObject(id:Int, width:Int, height:Int):Void;

    public function clear():Void;
    public function clearTiles():Void;
    public function layOut():Void;

    public function tilesValid():Bool;
    public function rasterize():Void;
    public function packTiles(width:Int, height:Int):Bool;
}

#else

extern class Engine {
}

#end
