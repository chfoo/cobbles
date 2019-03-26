package cobbles.ds;

import haxe.Int64;
import haxe.ds.BalancedTree;

/**
 * Map implementation supporting Int64 keys.
 */
class Int64Map<V> extends BalancedTree<Int64,V> {
    override function compare(k1:Int64, k2:Int64):Int {
        return Int64.compare(k1, k2);
    }
}
