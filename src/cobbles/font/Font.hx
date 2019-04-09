package cobbles.font;

import haxe.Int64;
import cobbles.native.CobblesExtern;
import cobbles.native.NativeData;
import haxe.io.Bytes;
import cobbles.ds.Hasher;

using Safety;
using cobbles.native.BytesTools;

/**
 * A single font face.
 */
class Font implements Disposable {
    @:allow(cobbles.shaping.Shaper)
    var fontPointer:CobblesFontPointer;

    var _isDisposed = false;
    var _bytes:Null<Bytes>;
    var _bytesPointer:Null<NativeBytes>;

    public var hashCode64(default, null):Int64;
    public var width(default, null):Int = 0;
    public var height(default, null):Int = 0;
    public var horizontalResolution(default, null):Int = 0;
    public var verticalResolution(default, null):Int = 0;

    /**
     * Opens a font.
     *
     * @param path Filename to a font file.
     * @param bytes If a filename is not given, read the given bytes of a font
     * file.
     * @param faceIndex Selects a font face for unusual font file formats.
     */
    public function new(?path:String, ?bytes:Bytes, faceIndex:Int = 0) {
        var fontPointer_;
        var hasher = new Hasher();

        if (path != null) {
            fontPointer_ = CobblesExtern.open_font_file(
                NativeData.getCobblesPointer(), path.toNativeString(), faceIndex);
            hasher.addString(path);
        } else if (bytes != null) {
            // Freetype requires bytes to be kept alive, so we keep
            // a reference to it
            #if !(js)
            // except on js since bytes are copied into the Emscripten heap
            _bytes = bytes;
            #end
            _bytesPointer = bytes.toNativeBytes();

            fontPointer_ = CobblesExtern.open_font_bytes(
                NativeData.getCobblesPointer(), _bytesPointer,
                bytes.length, faceIndex);
            hasher.addBytes(bytes);
        } else {
            throw "path or bytes must be given";
        }

        if (fontPointer_ == null) {
            throw new Exception("Failed to initialize font struct");
        }

        fontPointer = fontPointer_.sure();
        var errorCode = CobblesExtern.font_get_error(fontPointer.sure());

        if (errorCode != 0) {
            throw new Exception('Failed load font, FT error $errorCode');
        }

        hashCode64 = hasher.get();

        setPointSize(16);
    }

    public function dispose() {
        if (_isDisposed) {
            return;
        }

        _isDisposed = true;

        CobblesExtern.font_close(fontPointer);

        if (_bytes != null && _bytesPointer != null) {
            _bytes.releaseNativeBytes(_bytesPointer, false);
            _bytes = null;
            _bytesPointer = null;
        } else if(_bytesPointer != null) {
            var dummy = Bytes.alloc(0);
            dummy.releaseNativeBytes(_bytesPointer, false);
            _bytesPointer = null;
        }
    }

    public function isDisposed():Bool {
        return _isDisposed;
    }

    /**
     * Returns a glyph ID from the given code point.
     *
     * If there is no glyph for given code point (.notdef), 0 is returned.
     *
     * @param codePoint A Unicode code point.
     */
    public function getGlyphID(codePoint:Int):Int {
        return CobblesExtern.font_get_glyph_id(fontPointer.sure(), codePoint);
    }

    /**
     * Set the point size and resolution.
     * @param points Height of font in points.
     * @param dpi Resolution of font in dots per inch.
     */
    public function setPointSize(points:Float, dpi:Float = 72.0) {
        setSize(0, Std.int(points * 64), 0, Std.int(dpi));
    }

    /**
     * Sets the font size and resolution (advanced)
     *
     * @param width Width of font in 1/64th of a point. If 0, value of
     *  `height` is used.
     * @param height Height of font in 1/64th of a point. If 0, value of
     *  `width` is used.
     * @param horizontalResolution Horizontal resolution in dots per inch. If
     *  0, value of `verticalResolution` is used.
     * @param verticalResolution Vertical resolution in dots per inch. If
     *  0, value of `horizontalResolution` is used.
     */
    public function setSize(width:Int, height:Int,
    horizontalResolution:Int, verticalResolution:Int) {
        var pointer = fontPointer.sure();
        CobblesExtern.font_set_size(pointer,
            width, height, horizontalResolution, verticalResolution);

        var errorCode = CobblesExtern.font_get_error(pointer);

        if (errorCode != 0) {
            throw new Exception('Failed setting size, FT error $errorCode');
        }

        this.width = width;
        this.height = height;
        this.verticalResolution = verticalResolution;
        this.horizontalResolution = horizontalResolution;
    }

    /**
     * Returns glyph bitmap for the given glyph ID.
     */
    public function getGlyphBitmap(glyphID:Int):GlyphBitmap {
        var pointer = fontPointer.sure();
        CobblesExtern.font_load_glyph(pointer, glyphID);

        var errorCode = CobblesExtern.font_get_error(pointer);

        if (errorCode != 0) {
            throw new Exception('Failed loading glyph $glyphID, FT error $errorCode');
        }

        var buffer = Bytes.alloc(16);
        var bytesPointer = buffer.toNativeBytes(false);

        CobblesExtern.font_get_glyph_info(pointer, bytesPointer);
        buffer.releaseNativeBytes(bytesPointer);

        var bitmapWidth = buffer.getInt32(0);
        var bitmapHeight = buffer.getInt32(4);
        var bitmap = Bytes.alloc(bitmapWidth * bitmapHeight);

        // Check length because HashLink allocation failure on 0 bytes.
        if (bitmap.length > 0) {
            bytesPointer = bitmap.toNativeBytes(false);

            CobblesExtern.font_get_glyph_bitmap(pointer, bytesPointer);
            bitmap.releaseNativeBytes(bytesPointer);
        }

        var glyphBitmap:GlyphBitmap = {
            width: bitmapWidth,
            height: bitmapHeight,
            left: buffer.getInt32(8),
            top: buffer.getInt32(12),
            data: bitmap,
        };

        return glyphBitmap;
    }
}
