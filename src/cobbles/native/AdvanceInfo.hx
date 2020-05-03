package cobbles.native;

#if (cpp && !doc_gen)

@:include("cobbletext/cobbletext.h")
@:native("const struct CobbletextAdvanceInfo *")
extern class AdvanceInfo {
    var type:AdvanceType;

    @:native("text_index")
    var textIndex:Int;

    @:native("advance_x")
    var advanceX:Int;

    @:native("advance_y")
    var advanceY:Int;

    @:native("glyph_id")
    var glyphID:Int;

    @:native("glyph_offset_x")
    var glyphOffsetX:Int;

    @:native("glyph_offset_y")
    var glyphOffsetY:Int;

    @:native("inline_object")
    var inlineObject:Int;

    @:native("custom_property")
    var customProperty:Int;
}

#elseif (hl && !doc_gen)

typedef AdvanceInfo = cobbles.core.AdvanceInfo;

#else

extern class AdvanceInfo {
    var type:AdvanceType;
    var textIndex:Int;
    var advanceX:Int;
    var advanceY:Int;
    var glyphID:Int;
    var glyphOffsetX:Int;
    var glyphOffsetY:Int;
    var inlineObject:Int;
    var customProperty:Int;
}

#end
