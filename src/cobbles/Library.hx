package cobbles;

import haxe.io.Bytes;

/**
 * Opaque handle to the library's context.
 *
 * Use `new Library()` to create one.
 *
 * Once you obtain a library context, you can use it to open a layout and
 * render engine with `new Engine(library)`.
 *
 * Cobbletext and its dependencies is not thread safe. A library context
 * can be created for each thread. Otherwise, a simple application will only
 * need to use a single library context.
 */
class Library implements Disposable {
    /**
     * ID for the built-in fallback font when there is no font loaded.
     */
    public var fallbackFont(get, never):FontID;

    @:allow(cobbles)
    var coreLibrary:cobbles.core.Library;

    #if js
    public function new(module:cobbles.native.EmModule) {
        #if (!doc_gen)
        coreLibrary = new cobbles.core.LibraryJS(module);
        #end
    }

    public static function loadModule(moduleName:String = "CobbletextModule")
        :js.lib.Promise<Library> {

        final promise = new js.lib.Promise<Library>((accept, reject) -> {
            final factory = Reflect.field(js.Lib.global, moduleName);
            factory().then(module -> {
                js.Syntax.delete(module, "then");
                accept(new Library(module));
            });
        });

        return promise;
    }
    #elseif (cpp && !doc_gen)
    public function new() {
        coreLibrary = new cobbles.core.LibraryCPP();
    }
    #elseif (hl && !doc_gen)
    public function new() {
        coreLibrary = new cobbles.core.LibraryHL();
    }
    #else
    public function new() {
        throw "not implemented";
        coreLibrary = cast null;
    }
    #end

    public function dispose() {
        coreLibrary.dispose();
    }

    public function isDisposed():Bool {
        return coreLibrary.isDisposed();
    }

    function get_fallbackFont() {
        return coreLibrary.fallbackFont;
    }

    /**
     * Loads a font face from a file.
     *
     * @param path Filename of the font file. If the file has multiple faces,
     *      use the fragment notation by adding `#` and the face index such as
     *      `myfont.ttc#0`.
     */
    public function loadFont(path:String):FontID {
        return coreLibrary.loadFont(path);
    }

    /**
     * Loads a font face from the given bytes of a font file.
     *
     * @param data Binary contents of a font file. Tbe value is copied.
     * @param face_index Face index if the file has multiple faces. Use 0 if this
     *      parameter is irrelevant.
     */
    public function loadFontBytes(data:Bytes, faceIndex:Int = 0):FontID {
        return coreLibrary.loadFontBytes(data, faceIndex);
    }

    /**
     * Returns information about a loaded font.
     */
    public function getFontInfo(id:FontID):FontInfo {
        return coreLibrary.getFontInfo(id);
    }

    /**
     * Returns information about a glyph from a loaded font.
     */
    public function getGlyphInfo(id:GlyphID):GlyphInfo {
        return coreLibrary.getGlyphInfo(id);
    }

    /**
     * Sets an alternative font to be used if glyphs are not in the font.
     *
     * By default, the engine does not try another font if a font does not
     * have the required glyphs. By specifying an alternative font, the engine
     * will try to use another font. This is also known as font fallback.
     *
     * This function can be used to chain multiple fonts so the engine can try
     * them in order. You can also add the built-in fallback font at the of
     * the chain to guarantee something will be drawn.
     *
     * @param id The font in interest.
     * @param fallbackID The alternative font to select when the font in
     *      interest does not have the required glyphs.
     */
    public function setFontAlternative(id:FontID, fallbackID:FontID) {
        coreLibrary.setFontAlternative(id, fallbackID);
    }

    /**
     * Returns the alternative font for the given font.
     *
     * @return A font ID if there is an alternative set, otherwise 0.
     */
    public function getFontAlternative(id:FontID):FontID {
        return coreLibrary.getFontAlternative(id);
    }

    /**
     * Clear and reset any glyph information and state.
     *
     * The library context caches glyphs until the library context is deleted.
     * This function can be called to reduce memory usage especially if your
     * text sources are from user generated content.
     *
     * All registered glyphs and images will be removed and the
     * unique glyph ID assignment counter will be reset. This means that
     * glyph IDs will be reassigned and no longer unique unless you clear
     * glyph ID references in your application.
     */
    public function clearGlyphs() {
        coreLibrary.clearGlyphs();
    }
}
