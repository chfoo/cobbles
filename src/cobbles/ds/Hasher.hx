package cobbles.ds;

import haxe.io.Bytes;
import haxe.Int64;

using StringTools;

class Hasher {
    var hasherImplHigh:FNV1aHasher;
    var hasherImplLow:FNV1aHasher;

    var flipFlop:Bool = false;

    public function new() {
        hasherImplHigh = new FNV1aHasher();
        hasherImplLow = new FNV1aHasher();
    }

    public function reset() {
        hasherImplHigh.reset();
        hasherImplLow.reset();
    }

    public function addByte(byte:Int) {
        if (flipFlop) {
            hasherImplHigh.addByte(byte);
        } else {
            hasherImplLow.addByte(byte);
        }

        flipFlop = !flipFlop;
    }

    public function addBytes(bytes:Bytes) {
        for (index in 0...bytes.length) {
            addByte(bytes.get(index));
        }
    }

    public function addInt(int:Int) {
        if (flipFlop) {
            hasherImplHigh.addInt(int);
        } else {
            hasherImplLow.addInt(int);
        }

        flipFlop = !flipFlop;
    }

    public function addInt64(int:Int64) {
        addInt(int.high);
        addInt(int.low);
    }

    public function get():Int64 {
        return Int64.make(hasherImplHigh.get(), hasherImplLow.get());
    }

    public function addString(text:String) {
        #if (cobbles_hasher_add_string_impl == "bytes")
        addBytes(Bytes.ofString(text));
        #else
        for (index in 0...text.length) {
            var code = text.fastCodeAt(index);

            if (StringTools.isEof(code)) {
                break;
            }

            addInt(code);
        }
        #end
    }
}
