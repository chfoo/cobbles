package cobbles.ds;

import haxe.Constraints.IMap;
import haxe.Int64;

using Safety;

/**
 * Map implementation supporting Int64 keys.
 */
#if (cobbles_int64map_impl == "balanced_tree")
class Int64Map<V> extends haxe.ds.BalancedTree<Int64,V> {
    override function compare(k1:Int64, k2:Int64):Int {
        return Int64.compare(k1, k2);
    }
}
#else
class Int64Map<V> implements IMap<Int64,V> {
    var data:Map<Int,Map<Int,V>>;

    public function new() {
        data = new Map();
    }

    public function get(k:Int64):Null<V> {
        var subMap = data.get(k.high);

        if (subMap != null) {
            return subMap.get(k.low);
        } else {
            return null;
        }
    }

	public function set(k:Int64, v:V) {
        var subMap = data.get(k.high);

        if (subMap == null) {
            subMap = new Map();
            data.set(k.high, subMap);
        }

        subMap.set(k.low, v);
    }

	public function exists(k:Int64):Bool {
        var subMap = data.get(k.high);

        if (subMap != null) {
            return subMap.exists(k.low);
        } else {
            return false;
        }
    }

	public function remove(k:Int64):Bool {
        var subMap = data.get(k.high);

        if (subMap != null) {
            return subMap.remove(k.low);
        } else {
            return false;
        }
    }

	public function keys():Iterator<Int64> {
        var keyList = [];

        for (highKey in data.keys()) {
            for (lowKey in data.get(highKey).sure().keys()) {
                keyList.push(Int64.make(highKey, lowKey));
            }
        }

        return keyList.iterator();
    }

	public function iterator():Iterator<V> {
        var valueList = [];

        for (highKey in data.keys()) {
            for (value in data.get(highKey).sure()) {
                valueList.push(value);
            }
        }

        return valueList.iterator();
    }

    #if haxe4
	public function keyValueIterator():KeyValueIterator<Int64, V> {
        var itemList = [];

        for (item in data.keyValueIterator()) {
            for (subItem in item.value.keyValueIterator()) {
                itemList.push({
                    key: Int64.make(item.key, subItem.key),
                    value: subItem.value
                });
            }
        }

        return itemList.iterator();
    }
    #end

	public function copy():IMap<Int64,V> {
        var newMap = new Map();

        for (key in keys()) {
            newMap.set(key, get(key).sure());
        }

        return newMap;
    }

	public function toString():String {
        return data.toString();
    }
}
#end
