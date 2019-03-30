package cobbles.render;


import cobbles.ds.Cache;
import cobbles.ds.Int64Map;

class GlyphCache<T> extends GlyphMap<T> {
    var _cache:Cache<GlyphRenderKey,T>;

    public function new(maxSize:Int = 1024) {
        _cache = new Cache(maxSize, new Int64Map());
        super(_cache);
    }
}
