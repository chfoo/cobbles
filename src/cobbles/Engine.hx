package cobbles;

import cobbles.markup.TextContext;
import cobbles.markup.MarkupParser;

using Safety;

/**
 * Represents layout and render engine.

 * An engine is used repeatedly to process text.
 *
 * You can have multiple engines such as one engine for GUI elements that
 * do not change frequently and multiple engines for user chat room messages.
 */
class Engine implements Disposable {
    /**
     * Line length in pixels.
     *
     * If the value is 0, no word wrapping is performed. Otherwise, lines will
     * be word wrapped at the given pixel width.
     */
    public var lineLength(get, set):Int;

    /**
     * Locale as a BCP 47 language tag.
     *
     * This value is used for assisting lower-level functions to tailor the
     * presentation of the text to your application's user. It is typically
     * the GUI's locale or a document's language.
     *
     * The default is an empty string which indicates automatic detection of
     * the user's locale if possible.
     *
     * A tag is 2 characters or longer.
     */
    public var locale(get, set):String;

    /**
     * Controls the alignment of text in each line.
     *
     * Default is not specified.
     */
    public var textAlignment(get, set):TextAlignment;

    /**
     * The current language as a BCP 47 language tag.
     *
     * This low-level value typically controls the glyph variant selection to
     * use from a font file.
     *
     * Default value is an empty string which indicates automatic detection.
     *
     * A tag is 2 characters or longer.
     */
    public var language(get, set):String;

    /**
     * The current script as a ISO 15924 string.
     *
     * This low-level value typically controls the rules for shaping glyphs.
     *
     * A ISO 15924 string is a 4 character string such as "Latn".
     *
     * Default value is an empty string which indicates automatic detection.
     */
    public var script(get, set):String;

    /**
     * The current script direction.
     *
     * Default value "not specified" indicates automatic detection.
     */
    public var scriptDirection(get, set):ScriptDirection;

    /**
     * The current font face.
     *
     * Default is 0 (not corresponding to a valid font face).
     */
    public var font(get, set):FontID;

    /**
     * The current font size in points.
     *
     * Default is 12.
     *
     * If the font file contains bitmaps and not vectors, the value
     * represented is in pixels.
     */
    public var fontSize(get, set):Float;

    /**
     * Information about the lay out operation.
     */
    public var outputInfo(get, never):OutputInfo;

    /**
     * An associated markup parser for this engine.
     */
    public var markupParser:MarkupParser = new MarkupParser();

    final coreEngine:cobbles.core.Engine;

    var inlineObjectSequenceID = 1;
    final inlineObjectMap:Map<Int,InlineObject> = [];

    var customPropertiesSequenceID = 1;
    final customPropertiesMap:Map<Int,Map<String,Any>> = [];
    var currentCustomProperties:Map<String,Any> = [];
    var customPropertiesDirty = false;

    #if (js && !doc_gen)
    public function new(library:Library) {
        final coreLibrary = cast(library.coreLibrary, cobbles.core.LibraryJS);
        coreEngine = new cobbles.core.EngineJS(coreLibrary);
        init();
    }
    #elseif (cpp && !doc_gen)
    public function new(library:Library) {
        final coreLibrary = cast(library.coreLibrary, cobbles.core.LibraryCPP);
        coreEngine = new cobbles.core.EngineCPP(coreLibrary);
        init();
    }
    #elseif (hl && !doc_gen)
    public function new(library:Library) {
        final coreLibrary = cast(library.coreLibrary, cobbles.core.LibraryHL);
        coreEngine = new cobbles.core.EngineHL(coreLibrary);
        init();
    }
    #else
    public function new(library:Library) {
        throw "not implemented";
        coreEngine = cast null;
    }
    #end

    function init() {
        customPropertiesMap.set(customPropertiesSequenceID,
            currentCustomProperties);
        coreEngine.customProperty = customPropertiesSequenceID;
    }

    public function dispose() {
        coreEngine.dispose();
    }

    public function isDisposed():Bool {
        return coreEngine.isDisposed();
    }

    function get_lineLength():Int {
        return coreEngine.lineLength;
    }

    function set_lineLength(value:Int):Int {
        return coreEngine.lineLength = value;
    }

    function get_locale():String {
        return coreEngine.locale;
    }

    function set_locale(value:String):String {
        return coreEngine.locale = value;
    }

    function get_textAlignment():TextAlignment {
        return coreEngine.textAlignment;
    }

    function set_textAlignment(value:TextAlignment):TextAlignment {
        return coreEngine.textAlignment = value;
    }

    function get_language():String {
        return coreEngine.language;
    }

    function set_language(value:String):String {
        return coreEngine.language = value;
    }

    function get_script():String {
        return coreEngine.script;
    }

    function set_script(value:String):String {
        return coreEngine.script = value;
    }

    function get_scriptDirection():ScriptDirection {
        return coreEngine.scriptDirection;
    }

    function set_scriptDirection(value:ScriptDirection):ScriptDirection {
        return coreEngine.scriptDirection = value;
    }

    function get_font():FontID {
        return coreEngine.font;
    }

    function set_font(value:FontID):FontID {
        return coreEngine.font = value;
    }

    function get_fontSize():Float {
        return coreEngine.fontSize;
    }

    function set_fontSize(value:Float):Float {
        return coreEngine.fontSize = value;
    }

    function get_outputInfo():OutputInfo {
        return coreEngine.outputInfo;
    }

    /**
     * Returns the array of tiles.
     */
    public function tiles():Array<TileInfo> {
        return coreEngine.tiles();
    }

    /**
     * Returns the array of advances.
     */
    public function advances():Array<AdvanceInfo> {
        final coreAdvances = coreEngine.advances();
        final advances = new Array<AdvanceInfo>();

        for (coreAdvance in coreAdvances) {
            advances.push({
                "type": coreAdvance.type,
                "textIndex": coreAdvance.textIndex,
                "advanceX": coreAdvance.advanceX,
                "advanceY": coreAdvance.advanceY,
                "glyphID": coreAdvance.glyphID,
                "glyphOffsetX": coreAdvance.glyphOffsetX,
                "glyphOffsetY": coreAdvance.glyphOffsetY,
                "inlineObject": inlineObjectMap.get(coreAdvance.inlineObject),
                "customProperties":
                    customPropertiesMap.get(coreAdvance.customProperty),
            });
        }

        return advances;
    }

    /**
     * Append text to the internal buffer
     */
    public function addText(text:String) {
        applyCustomProperties();
        coreEngine.addText(text);
    }

    /**
     * Append content from the given markup using the current `markupParser`.
     */
    public function addMarkup(text:String) {
        markupParser.parse(new TextContext(this), text);
    }

    /**
     * Append a line break.
     */
    public function addLineBreak() {
        applyCustomProperties();
        coreEngine.addText("\n");
    }

    /**
     * Append a placeholder for an object to the text buffer.
     */
    public function addInlineObject(inlineObject:InlineObject) {
        applyCustomProperties();
        inlineObjectMap.set(inlineObjectSequenceID, inlineObject);
        coreEngine.addInlineObject(inlineObjectSequenceID,
            inlineObject.getWidth(), inlineObject.getHeight());
        inlineObjectSequenceID += 1;
    }

    function applyCustomProperties() {
        if (customPropertiesDirty) {
            customPropertiesMap.set(customPropertiesSequenceID,
                currentCustomProperties.copy());
            coreEngine.customProperty = customPropertiesSequenceID;
            customPropertiesSequenceID += 1;
        }
    }

    /**
     * Set a user-provided custom property.
     *
     * "color" is reserved as a well-known property that represents color in
     * a ARGB word-order integer.
     *
     * @param key Any string value.
     * @param value Any value.
     */
    public function setCustomProperty(key:String, value:Any) {
        currentCustomProperties.set(key, value);
        customPropertiesDirty = true;
    }

    /**
     * Get a user-provided custom property.
     */
    public function getCustomProperty(key:String):Null<Any> {
        return currentCustomProperties.get(key);
    }

    /**
     * Remove a user-provided custom property.
     *
     * @return Returns `true` if the custom property was deleted or `false`
     *      if the property did not exist.
     */
    public function removeCustomProperty(key:String):Bool {
        final result = currentCustomProperties.remove(key);

        if (result) {
            customPropertiesDirty = true;
        }

        return result;
    }

    /**
     * Empty the text buffer.
     *
     * This empties the text buffer so the engine can be used to process
     * anther set of text. The properties are not reset and tiles are not cleared.
     */
    public function clear() {
        coreEngine.clear();
        inlineObjectSequenceID = 1;
        customPropertiesSequenceID = 1;
        inlineObjectMap.clear();
        customPropertiesMap.clear();
    }

    /**
     * Clear associated tiles and glyphs.
     *
     * The library context caches glyphs until no engine has a reference to them.
     * This function can be called to reduce memory usage or clear a full
     * texture atlas. This is especially important if your text sources are
     * from user generated content.
     *
     * This function doesn't affect properties or buffered text, and
     * does not affect other engines. If you have associated data structures,
     * such as a texture atlas, remember to clear those too.
     */
    public function clearTiles() {
        coreEngine.clearTiles();
    }

    /**
     * Process and shape the text.
     */
    public function layOut() {
        coreEngine.layOut();
    }

    /**
     * Returns whether the associated glyphs to this engine is not stale.
     */
    public function tilesValid() {
        return coreEngine.tilesValid();
    }

    /**
     * Convert the glyphs required by this engine to coverages maps for drawing
     * the text.
     */
    public function rasterize() {
        coreEngine.rasterize();
    }

    /**
     * Texture pack the associated glyphs.
     *
     * @return `true` if the glyphs won't fit within the texture size, `false`
     *      if everything is OK.
     */
    public function packTiles(width:Int, height:Int):Bool {
        return coreEngine.packTiles(width, height);
    }
}
