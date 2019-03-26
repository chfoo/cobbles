package cobbles.layout;

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
     * Text direction.
     */
    public var direction:Direction = Direction.LeftToRight;

    /**
     * Font height in points.
     */
    public var fontPointSize(get, set):Float;

    /**
     * Script of the text as a ISO 15924 tag.
     *
     * It should be a 4 character string, such as "Latn". See
     * https://unicode.org/iso15924/codelists.html
     */
    public var script:String = "Latn";

    public function new(fontKey:FontKey) {
        this.fontKey = fontKey;
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
        var newCopy = new TextProperties(fontKey);

        newCopy.color = color;
        newCopy.direction = direction;
        newCopy.fontSize = fontSize;
        newCopy.script = script;

        return newCopy;
    }
}
