package cobbles;

import cobbles.layout.TextProperties;
import cobbles.algorithm.SimpleLineBreaker;
import cobbles.shaping.Shaper;
import cobbles.layout.Layout;
import cobbles.layout.TextSource;
import cobbles.font.FontTable;

using unifill.Unifill;

/**
 * Unified interface for building text layout by runs of text.
 */
class LayoutFacade {
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

    var _pendingText:Null<LayoutFacadeTextFI>;

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
     * Add a line break.
     *
     * @param spacing Multiplier of the default font size.
     */
    public function addLineBreak(spacing:Float = 1.2) {
        textSource.addLineBreak(spacing);
    }

    /**
     * Add a segment of text containing the same properties.
     *
     * @param text Text.
     * @return A fluent interface for applying text properties
     *  that different from the default.
     */
    public function addText(text:String):LayoutFacadeTextFI {
        if (_pendingText != null) {
            textSource.addText(_pendingText.text, _pendingText.textProperties);
        }

        var textProperties = textSource.defaultTextProperties.copy();

        _pendingText = new LayoutFacadeTextFI(text, textProperties, fontTable);
        return _pendingText;
    }

    /**
     * Perform line breaking, text shaping, and text layout.
     *
     * The layout will be ready for use in a renderer.
     */
    public function layoutText() {
        if (_pendingText != null) {
            textSource.addText(_pendingText.text, _pendingText.textProperties);
            _pendingText = null;
        }

        layout.layout();
    }
}


/**
 * `LayoutFacade.addText` fluent interface.
 */
class LayoutFacadeTextFI {
    @:allow(cobbles) var text:String;
    @:allow(cobbles) var textProperties:TextProperties;
    var fontTable:FontTable;

    public function new(text:String, textProperties:TextProperties,
    fontTable:FontTable) {
        this.text = text;
        this.textProperties = textProperties;
        this.fontTable = fontTable;
    }

    /**
     * Set font.
     */
    public function font(font:FontKey):LayoutFacadeTextFI {
        textProperties.fontKey = font;
        return this;
    }

    /**
     * Find an appropriate font that can display the text and set that font.
     */
    public function detectFont():LayoutFacadeTextFI {
        if (text != "") {
            textProperties.fontKey = fontTable.findByCodePoint(text.uCharCodeAt(0));
        }
        return this;
    }

    /**
     * Set font size.
     * @param size Size in points.
     */
    public function fontSize(size:Float):LayoutFacadeTextFI {
        textProperties.fontPointSize = size;
        return this;
    }

    /**
     * Set text color.
     * @param color Color in ARGB format.
     */
    public function color(color:Int):LayoutFacadeTextFI {
        textProperties.color = color;
        return this;
    }

    /**
     * Set character visual ordering.
     *
     * See `TextProperties`.
     */
    public function direction(direction:Direction):LayoutFacadeTextFI {
        textProperties.direction = direction;
        return this;
    }

    /**
     * Set language.
     *
     * See `TextProperties`.
     *
     * @param language A BCP 47 tag.
     */
    public function language(language:String):LayoutFacadeTextFI {
        textProperties.language = language;
        return this;
    }

    /**
     * Set script.
     *
     * See `TextProperties`.
     *
     * @param script A ISO 15924 tag
     */
    public function script(script:String):LayoutFacadeTextFI {
        textProperties.script = script;
        return this;
    }
}
