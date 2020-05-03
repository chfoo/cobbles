package cobbles.markup;

import haxe.ds.Option;

using StringTools;


/**
 * Utilities for parsing strings
 */
class ParseUtil {
    public static function parseColor(text:String):Option<Int> {
         if (text.startsWith("#") && text.length == 7) {
            var parseResult = Std.parseInt('0x${text.substr(1)}');

            if (parseResult != null) {
                return Some(parseResult | 0xFF000000);
            }

        } else if (text.startsWith("#") && text.length == 9) {
            var parseResult = Std.parseInt('0x${text.substr(1)}');

            if (parseResult != null) {
                return Some(parseResult);
            }
        }

        return None;
    }

    public static function parseDirection(text:String):Option<ScriptDirection> {
        switch text {
            case "ltr":
                return Some(ScriptDirection.LeftToRight);
            case "rtl":
                return Some(ScriptDirection.RightToLeft);
            default:
                return None;
        }
    }

    public static function parseFontPoints(text:String):Option<Float> {
        var parseResult = Std.parseFloat(text.substr(0, -2));

        if (text.endsWith("pt")) {
            var parseResult = Std.parseFloat(text.substr(0, -2));

            if (!Math.isNaN(parseResult)) {
                return Some(parseResult);
            }
        }

        return None;
    }
}
