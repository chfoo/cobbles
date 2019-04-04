package cobbles.shaping;

import unifill.CodePoint;
import haxe.ds.Vector;
import haxe.io.Bytes;
import cobbles.ds.FNV1aHasher;
import cobbles.font.Font;
import haxe.Int64;
import cobbles.ds.Cache;
import cobbles.ds.Int64Map;
import haxe.ds.Option;

using Safety;

/**
 * Helper for ShapeCache to cache shaped text.
 */
class ShapeCache {
    var _cache:Cache<Int64,Vector<GlyphShape>>;

    public function new (maxSize:Int = 128) {
        var impl = new Int64Map();
        _cache = new Cache(maxSize, #if !haxe4 cast #end impl);
    }

    public function getShapes(cacheKey:ShapeCacheKey):Option<Vector<GlyphShape>> {
        var result = _cache.get(cacheKey.getHash());

        if (result != null) {
            return Some(result);
        } else {
            return None;
        }
    }

    public function setShapes(cacheKey:ShapeCacheKey, glyphShapes:Vector<GlyphShape>) {
        _cache.set(cacheKey.getHash(), glyphShapes);
    }
}


/**
 * Represents a key for the cache
 */
class ShapeCacheKey {
    var hasher:FNV1aHasher;
    var dirty:Bool = true;
    var font:Null<Font>;
    var text:Null<String>;
    var codePoints:Null<Array<CodePoint>>;
    var language:String = "";
    var script:String = "";
    var direction:Direction = Direction.LeftToRight;

    public function new() {
        hasher = new FNV1aHasher();
    }

    public function setFont(font:Font) {
        this.font = font;
        dirty = true;
    }

    public function setText(text:String) {
        this.text = text;
        this.codePoints = null;
        dirty = true;
    }

    public function setCodePoints(codePoints:Array<CodePoint>) {
        this.codePoints = codePoints;
        this.text = null;
        dirty = true;
    }

    public function setLanguage(language:String) {
        this.language = language;
        dirty = true;
    }

    public function setScript(script:String) {
        this.script = script;
        dirty = true;
    }

    public function setDirection(direction:Direction) {
        this.direction = direction;
        dirty = true;
    }

    public function getHash():Int64 {
        if (!dirty) {
            return hasher.get();
        }

        hasher.reset();

        var font = font.sure();

        hasher.addInt64(font.hashCode64);
        hasher.addInt(font.width);
        hasher.addInt(font.height);
        hasher.addInt(font.horizontalResolution);
        hasher.addInt(font.verticalResolution);

        if (text != null) {
            hasher.addBytes(Bytes.ofString(text));
        }

        if (codePoints != null) {
            for (codePoint in codePoints) {
                hasher.addInt(codePoint);
            }
        }

        hasher.addBytes(Bytes.ofString(language));
        hasher.addBytes(Bytes.ofString(script));

        switch direction {
            case LeftToRight:
                hasher.addByte(1);
            case RightToLeft:
                hasher.addByte(2);
            case TopToBottom:
                hasher.addByte(3);
            case BottomToTop:
                hasher.addByte(4);
        }

        dirty = false;

        return hasher.get();
    }
}
