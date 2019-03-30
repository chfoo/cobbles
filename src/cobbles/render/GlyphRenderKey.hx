package cobbles.render;

import cobbles.font.FontTable.FontKey;
import haxe.Int64;

/**
 * Represents a glyph in a rendering context.
 */
@:forward
@:forwardStatics
abstract GlyphRenderKey(Int64) to Int64 from Int64 {
    static inline var GLYPH_ID_BITS = 24;
    static inline var GLYPH_ID_MASK = 0x00ffffff;
    static inline var FONT_KEY_BITS = 8;
    static inline var FONT_KEY_MASK = 0xff000000;

    inline public function new(fontKey:FontKey, glyphID:Int, height:Int, resolution:Int):Int64 {
        // Assumes max 2048 fonts, 21 bit Unicode code points
        var lowHash = (fontKey.toIndex() << 21) | glyphID;
        // Assumes max 16384 point size, max 4096 dpi
        var highHash = (height << 20) | resolution;

        this = Int64.make(highHash, lowHash);
    }
}
