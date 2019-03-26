package cobbles.ds;

import haxe.Constraints.IMap;

/**
 * Least recently used (LRU) cache.
 */
class Cache<K,V> implements IMap<K,V> {
    var maxSize:Int;
    var _map:IMap<K,V>;
    @:allow(cobbles.Cache) var _list:Array<K>;

    public function new(maxSize:Int = 1024, mapImpl:IMap<K,V>) {
        this.maxSize = maxSize;

        _map = mapImpl;
        _list = new Array();
    }

    function moveToFront(key:K) {
        _list.remove(key);
        _list.unshift(key);
    }

    function prune() {
        _list.splice(maxSize, 1);
    }

    public function get(key:K):Null<V> {
        moveToFront(key);
        return _map.get(key);
    }

    public function set(key:K, value:V) {
        moveToFront(key);
        prune();
        _map.set(key, value);
    }

    public function exists(key:K):Bool {
        return _map.exists(key);
    }

    public function remove(key:K):Bool {
        _map.remove(key);
        return _list.remove(key);
    }

    public function keys():Iterator<K> {
        return _list.iterator();
    }

    public function iterator():Iterator<V> {
        return _map.iterator();
    }

    public function keyValueIterator():KeyValueIterator<K, V> {
        return _map.keyValueIterator();
    }

    public function copy():IMap<K,V> {
        var newCache = new Cache(maxSize, _map.copy());
        newCache._list = _list.copy();
        return newCache;
    }

    public function toString():String {
        return _map.toString();
    }
}
