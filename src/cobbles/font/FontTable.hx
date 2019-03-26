package cobbles.font;

import haxe.io.Bytes;

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
    var fonts:Array<Font>;
    var _isDisposed = false;

    public function new() {
        fonts = [];
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

        return key;
    }

    /**
     * Returns a font corresponding to the given key.
     */
    public function getFont(key:FontKey):Font {
        return fonts[key.toIndex()];
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
}
