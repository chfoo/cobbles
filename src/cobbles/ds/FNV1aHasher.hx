package cobbles.ds;

import haxe.io.Bytes;
import haxe.Int64;

class FNV1aHasher {
    // https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
    static var OFFSET_BASIS = Int64.make(0xcbf29ce4, 0x84222325);
    static var PRIME = Int64.make(0x100, 0x000001b3);

    var hash:Int64;

    public function new() {
        hash = OFFSET_BASIS;
    }

    public function reset() {
        hash = OFFSET_BASIS;
    }

    public function addByte(byte:Int) {
        hash = hash ^ byte;
        hash = hash * PRIME;
    }

    public function addBytes(bytes:Bytes) {
        for (index in 0...bytes.length) {
            addByte(bytes.get(index));
        }
    }

    public function addInt(int:Int) {
        addByte((int >> 24) & 0xff);
        addByte((int >> 16) & 0xff);
        addByte((int >> 8) & 0xff);
        addByte(int & 0xff);
    }

    public function addInt64(int:Int64) {
        addInt(int.high);
        addInt(int.low);
    }

    public function get():Int64 {
        return hash;
    }
}
