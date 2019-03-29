package cobbles.render;

import haxe.ds.Option;
import cobbles.font.FontTable.FontKey;
import haxe.Int64;
import haxe.Constraints.IMap;

class GlyphMap<T> implements IMap<Int64,T> {
    static inline var GLYPH_ID_BITS = 24;
    static inline var GLYPH_ID_MASK = 0x00ffffff;
    static inline var FONT_KEY_BITS = 8;
    static inline var FONT_KEY_MASK = 0xff000000;

    var _map:IMap<Int64,T>;

    public function new(mapImpl:IMap<Int64,T>) {
        _map = mapImpl;
    }

    public function getGlyph(fontKey:FontKey, glyphID:Int, height:Int, resolution:Int):Option<T> {
        var key = toKey(fontKey, glyphID, height, resolution);
        var result = _map.get(key);

        if (result != null) {
            return Some(result);
        } else {
            return None;
        }
    }

    public function setGlyph(fontKey:FontKey, glyphID:Int, height:Int, resolution:Int, value:T) {
        var key = toKey(fontKey, glyphID, height, resolution);
        _map.set(key, value);
    }

    public function existsGlyph(fontKey:FontKey, glyphID:Int, height:Int, resolution:Int) {
        var key = toKey(fontKey, glyphID, height, resolution);
        return _map.exists(key);
    }

    function toKey(fontKey:FontKey, glyphID:Int, height:Int, resolution:Int):Int64 {
        // Assumes max 2048 fonts, 21 bit Unicode code points
        var lowHash = (fontKey.toIndex() << 21) | glyphID;
        // Assumes max 16384 point size, max 4096 dpi
        var highHash = (height << 20) | resolution;

        return Int64.make(highHash, lowHash);
    }

    public function get(k:Int64):Null<T> {
        return _map.get(k);
    }

    public function set(k:Int64, v:T) {
        return _map.set(k, v);
    }

    public function exists(k:Int64):Bool {
        return _map.exists(k);
    }

    public function remove(k:Int64):Bool {
        return _map.remove(k);
    }

    public function keys():Iterator<Int64> {
        return _map.keys();
    }

    public function iterator():Iterator<T> {
        return _map.iterator();
    }

    public function keyValueIterator():KeyValueIterator<Int64,T> {
        return _map.keyValueIterator();
    }

    public function copy():IMap<Int64,T> {
        return _map.copy();
    }

    public function toString():String {
        return _map.toString();
    }
}
