package cobbles.shaping;

import cobbles.shaping.ShapeCache;
import unifill.CodePoint;
import cobbles.native.NativeData;
import haxe.ds.Vector;
import haxe.io.Bytes;
import cobbles.font.Font;
import cobbles.native.CobblesExtern;

using cobbles.native.BytesTools;
using cobbles.util.MoreUnicodeTools;
using Safety;

/**
 * Calculates the required glyphs and their positions for text.
 *
 * TODO: The library will assert and fail if the order of calls is not correct.
 * Always set the font, text, language and script in that order before
 * calling shape().
 */
class Shaper implements Disposable {
    var shaperPointer:CobblesShaperPointer;
    var _isDisposed = false;

    var cache:ShapeCache;
    var cacheKey:ShapeCacheKey;

    public function new() {
        var shaperPointer_ = CobblesExtern.shaper_init(NativeData.getCobblesPointer());

        if (shaperPointer_ == null) {
            throw new Exception("Failed to init shaper struct");
        }

        shaperPointer = shaperPointer_;
        cache = new ShapeCache();
        cacheKey = new ShapeCacheKey();
    }

    public function dispose() {
        CobblesExtern.shaper_destroy(shaperPointer);
        _isDisposed = true;
    }

    public function isDisposed():Bool {
        return _isDisposed;
    }

    /**
     * Sets the font face used for glyph calculation.
     */
    public function setFont(font:Font) {
        CobblesExtern.shaper_set_font(shaperPointer, font.fontPointer);
        cacheKey.setFont(font);
    }

    /**
     * Sets the text to be processed.
     */
    public function setText(text:String) {
        CobblesExtern.shaper_set_text(shaperPointer, text.toNativeString(), cast 0);
        cacheKey.setText(text);
    }

    /**
     * Sets the text as array of code points to be processed.
     */
    public function setCodePoints(codePoints:Array<CodePoint>) {
        #if hl
        // Can't allocate 0 bytes in HashLink
        if (codePoints.length == 0) {
            setText("");
            return;
        }
        #end

        var buffer = codePoints.toUTF32Bytes();
        var bufferPointer = buffer.toNativeBytes();

        CobblesExtern.shaper_set_text_binary(shaperPointer, bufferPointer, NativeEncoding.Utf32);
        buffer.releaseNativeBytes(bufferPointer, false);

        cacheKey.setCodePoints(codePoints);
    }

    /**
     * Set the text's script and language
     * @param script A ISO 15924 tag.
     * @param language A BCP 47 tag.
     */
    public function setScript(?script:String, ?language:String) {
        if (script != null) {
            CobblesExtern.shaper_set_script(
                shaperPointer, script.toNativeString());
            cacheKey.setScript(script);
        } else {
            cacheKey.setScript("");
        }

        if (language != null) {
            CobblesExtern.shaper_set_language(
                shaperPointer, language.toNativeString());
            cacheKey.setLanguage(language);
        } else {
            cacheKey.setLanguage("");
        }
    }

    /**
     * Sets the text's script and direction by analyzing the first code point
     * in the text.
     *
     * This method is intended only for development and testing. To get
     * anything useful in return, see the `UnicodeUtil` class.
     */
    public function guessScript() {
        CobblesExtern.shaper_guess_text_properties(shaperPointer);
    }

    /**
     * Set the direction of the text.
     */
    public function setDirection(direction:Direction) {
        var directionStr;

        switch direction {
            case LeftToRight:
                directionStr = "ltr";
            case RightToLeft:
                directionStr = "rtl";
            case TopToBottom:
                directionStr = "ttb";
            case BottomToTop:
                directionStr = "btt";
        }

        CobblesExtern.shaper_set_direction(
            shaperPointer, directionStr.toNativeString());
        cacheKey.setDirection(direction);
    }

    /**
     * Shapes the text and returns an array of glyph information.
     *
     * Font and text must be set before calling this method.
     */
    public function shape():Vector<GlyphShape> {
        switch cache.getShapes(cacheKey) {
            case Some(shapes):
                return shapes;
            case None: // pass
        }

        CobblesExtern.shaper_shape(shaperPointer);

        var glyphCount = CobblesExtern.shaper_get_glyph_count(shaperPointer);

        var buffer = Bytes.alloc(24);
        #if hl @:nullSafety(Off) #end // bug
        var glyphs = new Vector<GlyphShape>(glyphCount);

        for (i in 0...glyphCount) {
            glyphs[i] = getGlyphInfo(shaperPointer, i, buffer);
        }

        cache.setShapes(cacheKey, glyphs);

        return glyphs;
    }

    function getGlyphInfo(shaper:CobblesShaperPointer, index:Int, buffer:Bytes):GlyphShape {
        var bufferPointer = buffer.toNativeBytes(false);
        CobblesExtern.shaper_get_glyph_info(shaper, index, bufferPointer);
        buffer.releaseNativeBytes(bufferPointer);

        return {
            glyphID: buffer.getInt32(0),
            textIndex: buffer.getInt32(4),
            offsetX: buffer.getInt32(8),
            offsetY: buffer.getInt32(12),
            advanceX: buffer.getInt32(16),
            advanceY: buffer.getInt32(20)
        };
    }
}
