package cobbles.layout;

import cobbles.font.FontTable;
import cobbles.font.FontTable.FontKey;

/**
 * Properties that can be applied to a segment of text.
 */
class TextProperties {
    /**
     * Font face
     */
    public var fontKey:FontKey;

    /**
     * Font height in 1/64th of a point.
     */
    public var fontSize:Int = 16 * 64;

    /**
     * Text color in ARGB format.
     */
    public var color:Int = 0xff000000;

    /**
     * Visual ordering of the characters in the text.
     *
     * * For left-to-right or top-to-bottom, this has no effect.
     * * For right-to-left or bottom-to-top, the characters in the text
     *   will be reversed for visual ordering. If a bidirectional algorithm
     *   has been applied, then do not use this direction as the bidi algorithm
     *   would have reversed the characters already.
     */
    public var direction:Direction = Direction.LeftToRight;

    /**
     * Font height in points.
     */
    public var fontPointSize(get, set):Float;

    /**
     * Language as a BCP 47 tag.
     *
     * It is usually two characters. See
     * https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry
     * for a full list.
     *
     * This field is used for OpenType fonts for enhanced context where
     * the script tag is not enough information to determine how to shape text.
     */
    public var language:String = "en";

    /**
     * Script of the text as a ISO 15924 tag.
     *
     * It should be a 4 character string, such as "Latn". See
     * https://unicode.org/iso15924/codelists.html for a full list.
     */
    public var script:String = "Latn";

    public function new() {
        this.fontKey = FontTable.notdefFont;
    }

    function get_fontPointSize():Float {
        return fontSize / 64;
    }

    function set_fontPointSize(value:Float):Float {
        fontSize = Std.int(value * 64);
        return value;
    }

    /**
     * Returns a copy.
     */
    public function copy():TextProperties {
        var newCopy = new TextProperties();

        newCopy.color = color;
        newCopy.direction = direction;
        newCopy.fontSize = fontSize;
        newCopy.fontKey = fontKey;
        newCopy.script = script;

        return newCopy;
    }
}
