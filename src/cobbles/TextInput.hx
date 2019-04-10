package cobbles;

import cobbles.layout.InlineObject;
import cobbles.layout.TextProperties;
import cobbles.algorithm.SimpleLineBreaker;
import cobbles.shaping.Shaper;
import cobbles.layout.Layout;
import cobbles.layout.TextSource;
import cobbles.font.FontTable;
import cobbles.util.UnicodeUtil;

using unifill.Unifill;

/**
 * Unified interface for building text layout by runs of text.
 */
class TextInput {
    /**
     * Font table singleton.
     */
    public static var fontTable(get, never):FontTable;
    static var _fontTableSingleton:Null<FontTable>;

    /**
     * Input text source instance.
     */
    public var textSource(default, null):TextSource;

    /**
     * Text shaper instance.
     */
    public var shaper(default, null):Shaper;

    /**
     * Text layout instance.
     */
    public var layout(default, null):Layout;

    /**
     * Default font.
     */
    public var font(get, set):FontKey;

    /**
     * Default font size in points.
     */
    public var fontSize(get, set):Float;

    /**
     * Default language as a BCP 47 tag.
     *
     * See `TextProperties`.
     */
    public var language(get, set):String;

    /**
     * Default script of the text as a ISO 15924 tag.
     *
     * See `TextProperties`.
     */
    public var script(get, set):String;

    /**
     * Default visual ordering of the characters in the text.
     *
     * See `TextProperties`.
     */
    public var textDirection(get, set):Direction;

    /**
     * Default text color in ARGB format.
     */
    public var color(get, set):Int;

    /**
     * The order in which text runs are placed in lines.
     *
     * See `Layout`.
     */
    public var lineDirection(get, set):Direction;

    /**
     * The orientation and flow direction of lines.
     *
     * See `Layout`.
     */
    public var orientation(get, set):Orientation;

    /**
     * Indicates the text alignment or justification.
     *
     * See `Layout`.
     */
    public var alignment(get, set):Alignment;

    /**
     * Maximum length of a line in pixels.
     *
     * If 0 or negative, there is no automatic line breaking.
     */
    public var lineBreakLength(get, set):Int;

    /**
     * The default line spacing as a multiplier of the font height.
     */
    public var lineSpacing(get, set):Float;

    // Not supported in Harfbuzz
    // /**
    //  * Font resolution in dots per inch.
    //  */
    // public var resolution(get, set):Int;

    var _pendingText:Null<TextInputTextFI>;

    public function new() {
        var lineBreaker = new SimpleLineBreaker();

        textSource = new TextSource(lineBreaker);
        shaper = new Shaper();
        layout = new Layout(fontTable, textSource, shaper);
    }

    static function get_fontTable():FontTable {
        if (_fontTableSingleton == null) {
            _fontTableSingleton = new FontTable();
        }

        return _fontTableSingleton;
    }

    function get_font():FontKey {
        return textSource.defaultTextProperties.fontKey;
    }

    function set_font(value:FontKey):FontKey {
        return textSource.defaultTextProperties.fontKey = value;
    }

    function get_fontSize():Float {
        return textSource.defaultTextProperties.fontPointSize;
    }

    function set_fontSize(value:Float):Float {
        return textSource.defaultTextProperties.fontPointSize = value;
    }

    function get_language():String {
        return textSource.defaultTextProperties.language;
    }

    function set_language(value:String):String {
        return textSource.defaultTextProperties.language = value;
    }

    function get_script():String {
        return textSource.defaultTextProperties.script;
    }

    function set_script(value:String):String {
        return textSource.defaultTextProperties.script = value;
    }

    function get_textDirection():Direction {
        return textSource.defaultTextProperties.direction;
    }

    function set_textDirection(value:Direction):Direction {
        return textSource.defaultTextProperties.direction = value;
    }

    function get_color():Int {
        return textSource.defaultTextProperties.color;
    }

    function set_color(value:Int):Int {
        return textSource.defaultTextProperties.color = value;
    }

    function get_lineDirection():Direction {
        return layout.direction;
    }

    function set_lineDirection(value:Direction):Direction {
        return layout.direction = value;
    }

    function get_orientation():Orientation {
        return layout.orientation;
    }

    function set_orientation(value:Orientation):Orientation {
        return layout.orientation = value;
    }

    function get_alignment():Alignment {
        return layout.alignment;
    }

    function set_alignment(value:Alignment):Alignment {
        return layout.alignment = value;
    }

    function get_lineBreakLength():Int {
        return layout.point64ToPixel(layout.lineBreakLength);
    }

    function set_lineBreakLength(value:Int):Int {
        layout.lineBreakLength = layout.pixelToPoint64(value);
        return value;
    }

    function get_lineSpacing():Float {
        return layout.relativeLineSpacing;
    }

    function set_lineSpacing(value:Float):Float {
        return layout.relativeLineSpacing = value;
    }

    function get_resolution():Int {
        return layout.resolution;
    }

    // function set_resolution(value:Int):Int {
    //     return layout.resolution = value;
    // }

    /**
     * Clear the text so that new text may be added.
     */
    public function clearText() {
        textSource.clear();
        layout.clearLines();
    }

    /**
     * Appends a line break.
     *
     * @param spacing Multiplier of the default font size.
     */
    public function addLineBreak(spacing:Float = 1.2) {
        flushPendingText();
        textSource.addLineBreak(spacing);
    }

    /**
     * Appends an inline object.
     */
    public function addInlineObject(inlineObject:InlineObject) {
        flushPendingText();
        textSource.addInlineObject(inlineObject);
    }

    /**
     * Appends a segment of text containing the same properties.
     *
     * @param text Text.
     * @return A fluent interface for applying text properties
     *  that different from the default.
     */
    public function addText(text:String):TextInputTextFI {
        flushPendingText();

        var textProperties = textSource.defaultTextProperties.copy();

        _pendingText = new TextInputTextFI(text, textProperties, fontTable);
        return _pendingText;
    }

    function flushPendingText() {
        if (_pendingText != null) {
            textSource.addText(_pendingText.text, _pendingText.properties);
            _pendingText = null;
        }
    }

    /**
     * Perform line breaking, text shaping, and text layout.
     *
     * The layout will be ready for use in a renderer.
     */
    public function layoutText() {
        if (_pendingText != null) {
            textSource.addText(_pendingText.text, _pendingText.properties);
            _pendingText = null;
        }

        layout.layout();
    }
}


/**
 * `TextInput.addText` fluent interface.
 */
class TextInputTextFI {
    @:allow(cobbles) var text:String;
    public var properties(default, null):TextProperties;
    var fontTable:FontTable;

    public function new(text:String, textProperties:TextProperties,
    fontTable:FontTable) {
        this.text = text;
        this.properties = textProperties;
        this.fontTable = fontTable;
    }

    /**
     * Set font.
     */
    public function font(font:FontKey):TextInputTextFI {
        properties.fontKey = font;
        return this;
    }

    /**
     * Find an appropriate font that can display the text and set that font.
     *
     * Note: this only uses the first code point in the text to find the first
     * font that can display it. This method is only provided as a convenience.
     */
    public function detectFont():TextInputTextFI {
        if (text != "") {
            properties.fontKey = fontTable.findByCodePoint(text.uCharCodeAt(0));
        }
        return this;
    }

    /**
     * Detect and automatically set the script and direction.
     *
     * Note: this only uses the first code point in the text to guess
     * the script and direction. This method is only provided as a convenience.
     */
    public function detectScript():TextInputTextFI {
        var result = UnicodeUtil.guessScript(text);
        properties.script = result.script;
        properties.direction = result.direction;
        return this;
    }

    /**
     * Set font size.
     * @param size Size in points.
     */
    public function fontSize(size:Float):TextInputTextFI {
        properties.fontPointSize = size;
        return this;
    }

    /**
     * Set text color.
     * @param color Color in ARGB format.
     */
    public function color(color:Int):TextInputTextFI {
        properties.color = color;
        return this;
    }

    /**
     * Set character visual ordering.
     *
     * See `TextProperties`.
     */
    public function direction(direction:Direction):TextInputTextFI {
        properties.direction = direction;
        return this;
    }

    /**
     * Set language.
     *
     * See `TextProperties`.
     *
     * @param language A BCP 47 tag.
     */
    public function language(language:String):TextInputTextFI {
        properties.language = language;
        return this;
    }

    /**
     * Set script.
     *
     * See `TextProperties`.
     *
     * @param script A ISO 15924 tag
     */
    public function script(script:String):TextInputTextFI {
        properties.script = script;
        return this;
    }

    /**
     * Sets a custom property.
     *
     * See `TextProperties`.
     */
    public function data(key:String, value:String):TextInputTextFI {
        properties.data.set(key, value);
        return this;
    }
}
