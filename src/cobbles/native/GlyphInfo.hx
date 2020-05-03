package cobbles.native;

#if (cpp && !doc_gen)

import cpp.RawConstPointer;
import cpp.UInt8;

@:include("cobbletext/cobbletext.h")
@:native("const struct CobbletextGlyphInfo *")
extern class GlyphInfo {
    var id:Int;

    var image:RawConstPointer<UInt8>;

    @:native("image_width")
    var imageWidth:Int;

    @:native("image_height")
    var imageHeight:Int;

    @:native("image_offset_x")
    var imageOffsetX:Int;

    @:native("image_offset_y")
    var imageOffsetY:Int;
}

#elseif (hl && !doc_gen)

typedef GlyphInfo = cobbles.GlyphInfo;

#elseif (js && !doc_gen)

extern class GlyphInfo {
    var id:Int;
    var image:EmbindVector<Int>;
    var imageWidth:Int;
    var imageHeight:Int;
    var imageOffsetX:Int;
    var imageOffsetY:Int;
}

#else

extern class GlyphInfo {
    var id:Int;
    var image:Any;
    var imageWidth:Int;
    var imageHeight:Int;
    var imageOffsetX:Int;
    var imageOffsetY:Int;
}

#end
