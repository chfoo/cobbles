package cobbles.ds;

class MapTools {
    #if (haxe_ver < 4.0)
    public static function copy<K,V>(map:IMap<K,V>):IMap<K,V> {
        var newMap = new Map<K,V>();

        for (key in map.keys()) {
            newMap.set(key, map.get(key));
        }

        return newMap;
    }
    #end
}
