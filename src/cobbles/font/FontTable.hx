package cobbles.font;

import haxe.Resource;
import haxe.io.Bytes;

using Safety;

abstract FontKey(Int) {
    public inline function new(value:Int) {
        this = value;
    }

    public inline function toIndex():Int {
        return this;
    }
}

/**
 * Opened font file registry.
 */
class FontTable implements Disposable {
    /**
     * A built-in font that is always available.
     */
    public static var notdefFont(get, never):FontKey;

    static var _notdefFont:Null<Font>;
    static var _notdefFontKey:Null<FontKey>;

    var fonts:Array<Font>;
    var fontKeys:Array<FontKey>;
    var _isDisposed = false;

    public function new() {
        fonts = [];
        fontKeys = [];
    }

    static function get_notdefFont():FontKey {
        if (_notdefFontKey == null) {
            _notdefFontKey = new FontKey(-1);

            _notdefFont = new Font(Resource.getBytes(
                "resource/fonts/adobe-notdef/AND-Regular.otf"));
        }

        return _notdefFontKey;
    }

    public function dispose() {
        for (font in fonts) {
            if (!font.isDisposed()) {
                font.dispose();
            }
        }

        _isDisposed = true;
    }

    public function isDisposed():Bool {
        return _isDisposed;
    }

    /**
     * Adds a previously opened font to the table and returns a font key.
     */
    public function addFont(font:Font):FontKey {
        var key = new FontKey(fonts.length);

        fonts.push(font);
        fontKeys.push(key);

        return key;
    }

    /**
     * Returns a font corresponding to the given key.
     */
    public function getFont(key:FontKey):Font {
        if (key != notdefFont) {
            return fonts[key.toIndex()];
        } else {
            return _notdefFont.sure();
        }
    }

    /**
     * Opens a font from the given filename and adds it to the table.
     */
    public function openFile(path:String):FontKey {
        var font = new Font(path);
        return addFont(font);
    }

    /**
     * Opens a font from bytes of a font file and adds it to the table.
     */
    public function openBytes(fontBytes:Bytes):FontKey {
        var font = new Font(fontBytes);
        return addFont(font);
    }

    /**
     * Returns a font that contains the given code point.
     *
     * Fonts are searched in the order that they were added to this
     * instance.
     *
     * If a font cannot be found, the `notdefFont` font is returned. You can
     * override this behavior by add your own fallback font last. Note that the
     * renderer you choose may use a different behavior such as drawing its
     * own fallback glyph.
     */
    public function findByCodePoint(codePoint:Int):FontKey {
        for (index in 0...fontKeys.length) {
            var fontKey = fontKeys[index];
            var font = fonts[index];

            if (font.getGlyphID(codePoint) != 0) {
                return fontKey;
            }
        }

        return notdefFont;
    }
}
