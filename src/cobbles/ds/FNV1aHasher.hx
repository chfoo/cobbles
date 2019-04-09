package cobbles.ds;

class FNV1aHasher {
    // This class used to be Int64, but it impacted performance especially
    // when used as cache keys.
    // https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
    static var OFFSET_BASIS = 0x811c9dc5;
    static var PRIME = 16777619;

    var hash:Int = 0;

    public function new() {
        hash = OFFSET_BASIS;
    }

    public function reset() {
        hash = OFFSET_BASIS;
    }

    public function addByte(byte:Int) {
        hash = hash ^ byte;
        hash = (hash * PRIME) & 0xffffffff;
    }

    public function addInt(int:Int) {
        addByte((int >> 24) & 0xff);
        addByte((int >> 16) & 0xff);
        addByte((int >> 8) & 0xff);
        addByte(int & 0xff);
    }

    public function get():Int {
        return hash;
    }
}
