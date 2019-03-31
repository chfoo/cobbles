package cobbles.ds;

import haxe.Constraints.IMap;

using Safety;

private class CacheNode<K,V> {
    public var key:K;
    public var value:V;

    public var next:Null<CacheNode<K,V>>;
    public var previous:Null<CacheNode<K,V>>;

    public function new(key:K, value:V) {
        this.key = key;
        this.value = value;
    }
}

/**
 * Least recently used (LRU) cache.
 */
class Cache<K,V> implements IMap<K,V> {
    var maxSize:Int;
    var _map:IMap<K,CacheNode<K,V>>;
    var _head:Null<CacheNode<K,V>>;
    var _tail:Null<CacheNode<K,V>>;
    var _count:Int = 0;

    public function new(maxSize:Int = 1024, mapImpl:IMap<K,CacheNode<K,V>>) {
        this.maxSize = maxSize;

        _map = mapImpl;
    }

    function unshiftNode(node:CacheNode<K,V>) {
        if (_head != null) {
            _head.previous = node;
            _head = node;
        } else {
            _head = _tail = node;
        }
    }

    function unlinkNode(node:CacheNode<K,V>) {
        var previousNode = node.previous;
        var nextNode = node.next;

        if (previousNode != null) {
            previousNode.next = nextNode;
        } else {
            _head = nextNode;
        }

        if (nextNode != null) {
            nextNode.previous = previousNode;
        } else {
            _tail = previousNode;
        }
    }

    public function get(key:K):Null<V> {
        var node = _map.get(key);

        if (node != null) {
            unlinkNode(node);
            unshiftNode(node);
            return node.value;
        } else {
            return null;
        }
    }

    public function set(key:K, value:V) {
        var node = _map.get(key);

        if (node != null) {
            unlinkNode(node);
            unshiftNode(node);
            node.value = value;

        } else {
            var node = new CacheNode(key, value);
            unshiftNode(node);
            _map.set(key, node);

            _count += 1;

            if (_count > maxSize) {
                remove(_tail.sure().key);
            }
        }
    }

    public function exists(key:K):Bool {
        return _map.exists(key);
    }

    public function remove(key:K):Bool {
        var node = _map.get(key);

        if (node != null) {
            unlinkNode(node);
            _count -= 1;
        }

        return _map.remove(key);
    }

    public function keys():Iterator<K> {
        return _map.keys();
    }

    public function iterator():Iterator<V> {
        return new CacheValueIterator(_map);
    }

    public function keyValueIterator():KeyValueIterator<K, V> {
        return new CacheKeyValueIterator(_map);
    }

    public function copy():IMap<K,V> {
        throw "not implemented";
    }

    public function toString():String {
        return _map.toString();
    }
}


private class CacheValueIterator<K,V> {
    var _map:IMap<K,CacheNode<K,V>>;
    var _keyIterator:Iterator<K>;

    public function new(map:IMap<K,CacheNode<K,V>>) {
        this._map = map;
        _keyIterator = map.keys();
    }

    public function hasNext():Bool {
        return _keyIterator.hasNext();
    }

    public function next():V {
        return _map.get(_keyIterator.next()).sure().value;
    }
}

private class CacheKeyValueIterator<K,V> {
    var _map:IMap<K,CacheNode<K,V>>;
    var _keyIterator:Iterator<K>;

    public function new(map:IMap<K,CacheNode<K,V>>) {
        this._map = map;
        _keyIterator = map.keys();
    }

    public function hasNext():Bool {
        return _keyIterator.hasNext();
    }

    public function next():{key:K,value:V} {
        var node = _map.get(_keyIterator.next()).sure();
        return {key: node.key, value: node.value};
    }
}
