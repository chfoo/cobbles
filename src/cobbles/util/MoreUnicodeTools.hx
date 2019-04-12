package cobbles.util;

import haxe.io.Bytes;
import unifill.CodePoint;

using unifill.Unifill;

class MoreUnicodeTools {
    public static function toCodePoints(text:String):Array<CodePoint> {
        var buffer = [];

        for (codePoint in text.uIterator()) {
            if (codePoint == 0) {
                continue;
            }

            buffer.push(codePoint);
        }

        return buffer;
    }

    public static function toUTF32Bytes(codePoints:Array<CodePoint>):Bytes {
        var buffer = Bytes.alloc(codePoints.length * 4 + 4);

        for (index in 0...codePoints.length) {
            buffer.setInt32(index * 4, codePoints[index]);
        }

        buffer.setInt32(codePoints.length * 4, 0); // null terminator

        return buffer;
    }
}
