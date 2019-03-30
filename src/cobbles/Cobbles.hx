package cobbles;

import cobbles.layout.TextProperties;
import cobbles.layout.LayoutLine;
import haxe.io.Bytes;
import cobbles.algorithm.SimpleLineBreaker;
import cobbles.shaping.Shaper;
import cobbles.layout.Layout;
import cobbles.layout.TextSource;
import cobbles.font.FontTable;

/**
 * Simple interface for text layout,
 */
class Cobbles {
    /**
     * Font table instance.
     */
    public var fontTable(default, null):FontTable;

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

    /**
     * Font resolution in dots per inch.
     */
    public var resolution(get, set):Int;

    public function new() {
        var lineBreaker = new SimpleLineBreaker();

        fontTable = new FontTable();
        textSource = new TextSource(lineBreaker);
        shaper = new Shaper();
        layout = new Layout(fontTable, textSource, shaper, lineBreaker);
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

    function set_resolution(value:Int):Int {
        return layout.resolution = value;
    }

    public function addFontFile(filename:String):FontKey {
        return fontTable.openFile(filename);
    }

    public function addFontBytes(fontBytes:Bytes):FontKey {
        return fontTable.openBytes(fontBytes);
    }

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
     * @return CobblesText A fluent interface for applying text properties
     *  that different from the default.
     */
    public function addText(text:String):CobblesText {
        var textProperties = textSource.defaultTextProperties.copy();
        textSource.addText(text, textProperties);

        return new CobblesText(textProperties);
    }

    /**
     * Perform line breaking, text shaping, and text layout.
     *
     * The layout will be ready for use in a renderer.
     */
    public function layoutText() {
        layout.layout();
    }
}


/**
 * `Cobbles.addText` fluent interface.
 */
class CobblesText {
    var textProperties:TextProperties;

    public function new(textProperties:TextProperties) {
        this.textProperties = textProperties;
    }

    /**
     * Set font.
     */
    public function font(font:FontKey):CobblesText {
        textProperties.fontKey = font;
        return this;
    }

    /**
     * Set font size.
     * @param size Size in points.
     */
    public function fontSize(size:Float):CobblesText {
        textProperties.fontPointSize = size;
        return this;
    }

    /**
     * Set text color.
     * @param color Color in ARGB format.
     */
    public function color(color:Int):CobblesText {
        textProperties.color = color;
        return this;
    }

    /**
     * Set character visual ordering.
     *
     * See `TextProperties`.
     */
    public function direction(direction:Direction):CobblesText {
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
    public function language(language:String):CobblesText {
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
    public function script(script:String):CobblesText {
        textProperties.script = script;
        return this;
    }
}
