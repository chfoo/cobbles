package cobbles.layout;

import cobbles.algorithm.LineBreakingAlgorithm;
import haxe.ds.Option;
import cobbles.font.FontTable.FontKey;
import cobbles.algorithm.BidiAlgorithm;

using unifill.Unifill;

/**
 * A segment of text containing the same properties.
 */
@:structInit
class TextRun {
    public var text:String;
    public var fontKey:FontKey;
    public var fontSize:Int;
    public var color:Int;
    public var direction:Direction;
    public var language:String;
    public var script:String;
}


enum TextSourceItem {
    RunItem(textRun:TextRun);
    LineBreakItem(relativeSpacing:Float);
    InlineObjectItem(inlineObject:InlineObject);
}

/**
 * Formatting of input text and properties.
 */
class TextSource {
    public var items(default, null):Array<TextSourceItem>;

    /**
     * Default text properties.
     */
    public var defaultTextProperties:TextProperties;

    var bidiAlgorithm:Option<BidiAlgorithm>;
    var lineBreaker:Option<LineBreakingAlgorithm>;

    /**
     * @param bidiAlgorithm  Optional bidirectional algorithm.
     *  If provided, it is applied automatically to text. The text direction
     *  should be set to match the algorithm's output direction.
     * @param lineBreaker Optional line breaking algorithm.
     *  If provided, any mandatory line breaking characters will automatically
     *  cause a line break. Otherwise, you must call `addLineBreak()`
     *  manually if you want explicit line breaks.
     */
    public function new(?bidiAlgorithm:BidiAlgorithm,
    ?lineBreaker:LineBreakingAlgorithm) {

        this.bidiAlgorithm = bidiAlgorithm != null ? Some(bidiAlgorithm) : None;
        this.lineBreaker = lineBreaker != null ? Some(lineBreaker) : None;

        items = new Array();

        defaultTextProperties = new TextProperties();
    }

    /**
     * Appends an object.
     */
    public function addInlineObject(inlineObject:InlineObject) {
        items.push(InlineObjectItem(inlineObject));
    }

    /**
     * Appends a segment of text having the same properties.
     *
     * @param text A segment of text.
     * @param properties Optional text properties. If not given, the
     *  defaults from `defaultTextProperties` are used.
     */
    public function addText(text:String, ?properties:TextProperties) {
        if (properties == null) {
            properties = defaultTextProperties;
        }

        switch bidiAlgorithm {
            case Some(algorithm):
                text = algorithm.reorderSimple(text);
            case None:
                // pass
        }

        switch lineBreaker {
            case Some(lineBreaker_):
                breakLinesAndAddRun(lineBreaker_, text, properties);
            case None:
                addRunFromProperties(text, properties);
        }

    }

    function addRunFromProperties(text:String, properties:TextProperties) {
        var run:TextRun = {
            text: text,
            fontKey: properties.fontKey,
            fontSize: properties.fontSize,
            color: properties.color,
            direction: properties.direction,
            language: properties.language,
            script: properties.script
        };

        items.push(RunItem(run));
    }

    function breakLinesAndAddRun(lineBreaker:LineBreakingAlgorithm,
    text:String, properties:TextProperties) {
        var beginIndex = 0;
        var lineBreaks = lineBreaker.getBreaks(text);

        for (breakIndex in 0...lineBreaks.count()) {
            if (lineBreaks.isMandatory(breakIndex)) {
                var endIndex = breakIndex;

                addRunFromProperties(
                    text.uSubstring(beginIndex, endIndex), properties);

                beginIndex = endIndex;
            }
        }

        @:nullSafety(Off) // bug with inline
        addRunFromProperties(text.uSubstr(beginIndex), properties);
    }

    /**
     * Adds an explicit line break.
     *
     * @param relativeSpacing A multiplier of the default font height that
     *  represents the height of the line.
     */
    public function addLineBreak(relativeSpacing:Float = 1.2) {
        items.push(LineBreakItem(relativeSpacing));
    }

    /**
     * Clears the contents of `items`.
     */
    public function clear() {
        items = [];
    }
}
