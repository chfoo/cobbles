package cobbles.algorithm;

import cobbles.native.CobblesExtern;
import cobbles.native.NativeData;

using cobbles.native.BytesTools;

@:structInit
class StringScriptResult {
    public var script:String;
    public var direction:Direction;
}

class ScriptGuesser {
    public static function guessScript(text:String):StringScriptResult {
        var pointer = NativeData.getCobblesPointer();
        var result = CobblesExtern.guess_string_script(
            pointer, text.toNativeString());

        var stringBuf = new StringBuf();

        stringBuf.addChar((result >> 24) & 0x7f);
        stringBuf.addChar((result >> 16) & 0x7f);
        stringBuf.addChar((result >> 8) & 0x7f);
        stringBuf.addChar(result & 0x7f);

        return {
            script: stringBuf.toString(),
            direction: (result >> 31) & 1 == 1 ? RightToLeft : LeftToRight
        }
    }
}
