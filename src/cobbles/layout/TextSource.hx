package cobbles.layout;

import haxe.ds.Vector;
import unifill.CodePoint;
import cobbles.algorithm.LineBreakingAlgorithm;
import haxe.ds.Option;
import cobbles.font.FontTable.FontKey;
import cobbles.algorithm.BidiAlgorithm;

using unifill.Unifill;
using cobbles.util.MoreUnicodeTools;

/**
 * A segment of text containing the same properties.
 */
@:structInit
class TextRun {
    public var codePointIndex:Int;
    public var codePointCount:Int;
    public var fontKey:FontKey;
    public var fontSize:Int;
    public var color:Int;
    public var direction:Direction;
    public var language:String;
    public var script:String;

    public function copy():TextRun {
        return {
            codePointIndex: codePointIndex,
            codePointCount: codePointCount,
            fontKey: fontKey,
            fontSize: fontSize,
            color: color,
            direction: direction,
            language: language,
            script: script
        };
    }
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
    public var codePoints(default, null):Array<CodePoint>;

    /**
     * Default text properties.
     */
    public var defaultTextProperties:TextProperties;

    var bidiAlgorithm:Option<BidiAlgorithm>;

    /**
     * @param bidiAlgorithm  Optional bidirectional algorithm.
     *  If provided, it is applied automatically to text. The text direction
     *  should be set to match the algorithm's output direction.
     */
    public function new(?bidiAlgorithm:BidiAlgorithm,
    ?lineBreaker:LineBreakingAlgorithm) {
        this.bidiAlgorithm = bidiAlgorithm != null ? Some(bidiAlgorithm) : None;

        items = [];
        codePoints = [];

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

        addRunFromProperties(text.toCodePoints(), properties);
    }

    function addRunFromProperties(codePoints:Array<CodePoint>,
    properties:TextProperties) {
        var run:TextRun = {
            codePointIndex: this.codePoints.length,
            codePointCount: codePoints.length,
            fontKey: properties.fontKey,
            fontSize: properties.fontSize,
            color: properties.color,
            direction: properties.direction,
            language: properties.language,
            script: properties.script
        };

        items.push(RunItem(run));

        for (codePoint in codePoints) {
            this.codePoints.push(codePoint);
        }
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
        codePoints = [];
    }
}
