package cobbles.render;

import haxe.Int64;
import haxe.Constraints.IMap;

class GlyphMap<T> implements IMap<GlyphRenderKey,T> {
    var _map:IMap<Int64,T>;

    public function new(mapImpl:IMap<Int64,T>) {
        _map = mapImpl;
    }

    public function get(k:GlyphRenderKey):Null<T> {
        return _map.get(k);
    }

    public function set(k:GlyphRenderKey, v:T) {
        return _map.set(k, v);
    }

    public function exists(k:GlyphRenderKey):Bool {
        return _map.exists(k);
    }

    public function remove(k:GlyphRenderKey):Bool {
        return _map.remove(k);
    }

    public function keys():Iterator<GlyphRenderKey> {
        return _map.keys();
    }

    public function iterator():Iterator<T> {
        return _map.iterator();
    }

    public function keyValueIterator():KeyValueIterator<GlyphRenderKey,T> {
        return _map.keyValueIterator();
    }

    public function copy():IMap<GlyphRenderKey,T> {
        return _map.copy();
    }

    public function toString():String {
        return _map.toString();
    }
}

