package cobbles.native;

#if (cpp && !doc_gen)

@:include("cobbletext/cobbletext.h")
@:native("const struct CobbletextTileInfo *")
extern class TileInfo {
    @:native("glyph_id")
    var glyphID:Int;

    @:native("atlas_x")
    var atlasX:Int;

    @:native("atlas_y")
    var atlasY:Int;
}


#elseif (hl && !doc_gen)

typedef TileInfo = cobbles.TileInfo;

#else

extern class TileInfo {
    var glyphID:Int;
    var atlasX:Int;
    var atlasY:Int;
}

#end
