package cobbles.shaping;

import haxe.ds.Vector;
import haxe.io.Bytes;
import cobbles.ds.FNV1aHasher;
import cobbles.font.Font;
import haxe.Int64;
import cobbles.ds.Cache;
import cobbles.ds.Int64Map;
import haxe.ds.Option;

class ShapeCache {
    var _cache:Cache<Int64,Vector<GlyphShape>>;
    var _hasher:FNV1aHasher;

    public function new (maxSize:Int = 128) {
        _cache = new Cache(maxSize, new Int64Map());
        _hasher = new FNV1aHasher();
    }

    public function getShapes(font:Font, text:String, language:String,
    script:String, direction:Direction):Option<Vector<GlyphShape>> {
        var key = getKey(font, text, language, script, direction);
        var result = _cache.get(key);

        if (result != null) {
            return Some(result);
        } else {
            return None;
        }
    }

    public function setShapes(font:Font, text:String, language:String,
    script:String, direction:Direction, glyphShapes:Vector<GlyphShape>) {
        var key = getKey(font, text, language, script, direction);
        _cache.set(key, glyphShapes);
    }

    function getKey(font:Font, text:String, language:String, script:String, direction:Direction):Int64 {
        _hasher.reset();

        _hasher.addInt64(font.hashCode64);
        _hasher.addInt(font.width);
        _hasher.addInt(font.height);
        _hasher.addInt(font.horizontalResolution);
        _hasher.addInt(font.verticalResolution);
        _hasher.addBytes(Bytes.ofString(text));
        _hasher.addBytes(Bytes.ofString(language));
        _hasher.addBytes(Bytes.ofString(script));

        switch direction {
            case LeftToRight:
                _hasher.addByte(1);
            case RightToLeft:
                _hasher.addByte(2);
            case TopToBottom:
                _hasher.addByte(3);
            case BottomToTop:
                _hasher.addByte(4);
        }

        return _hasher.get();
    }
}
