package cobbles.render;

import haxe.Int64;
import haxe.ds.Option;
import cobbles.font.GlyphInfo;
import cobbles.font.FontTable;
import cobbles.ds.Cache;
import cobbles.ds.Int64Map;


class GlyphCache {
    static inline var GLYPH_ID_BITS = 24;
    static inline var GLYPH_ID_MASK = 0x00ffffff;
    static inline var FONT_KEY_BITS = 8;
    static inline var FONT_KEY_MASK = 0xff000000;

    var _cache:Cache<Int64,GlyphInfo>;

    public function new(maxSize:Int = 1024) {
        _cache = new Cache(maxSize, new Int64Map());
    }

    public function get(fontKey:FontKey, glyphID:Int, height:Int, resolution:Int):Option<GlyphInfo> {
        var key = toKey(fontKey, height, glyphID, resolution);
        var result = _cache.get(key);

        if (result != null) {
            return Some(result);
        } else {
            return None;
        }
    }

    public function set(fontKey:FontKey, glyphID:Int, height:Int, resolution:Int, glyphInfo:GlyphInfo) {
        var key = toKey(fontKey, height, glyphID, resolution);
        _cache.set(key, glyphInfo);
    }

    function toKey(fontKey:FontKey, glyphID:Int, height:Int, resolution:Int):Int64 {
        // Assumes max 2048 fonts, 21 bit Unicode code points
        var lowHash = (fontKey.toIndex() << 21) | glyphID;
        // Assumes max 16384 point size, max 4096 dpi
        var highHash = (height << 20) | resolution;

        return Int64.make(highHash, lowHash);
    }
}
