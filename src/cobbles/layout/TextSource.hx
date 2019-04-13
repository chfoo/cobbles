package cobbles.layout;

import haxe.Constraints.IMap;
import unifill.CodePoint;
import cobbles.algorithm.LineBreakingAlgorithm;
import haxe.ds.Option;
import cobbles.font.FontTable.FontKey;
import cobbles.algorithm.BidiAlgorithm;

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
    public var data:IMap<String,String>;

    public function copy():TextRun {
        return {
            codePointIndex: codePointIndex,
            codePointCount: codePointCount,
            fontKey: fontKey,
            fontSize: fontSize,
            color: color,
            direction: direction,
            language: language,
            script: script,
            data: data
        };
    }
}


enum TextSourceItem {
    RunItem(textRun:TextRun);
    LineBreakItem(relativeSpacing:Float);
    InlineObjectItem(inlineObject:InlineObject);
}

/**
 * Collects and stores input text and properties.
 */
class TextSource {
    /**
     * Default text properties.
     */
    public var defaultTextProperties:TextProperties;

    /**
     * Input text items and objects.
     */
    public var items(default, null):Array<TextSourceItem>;

    /**
     * Unicode code points of the input text.
     */
    public var codePoints(default, null):Array<CodePoint>;

    public var lineBreakRules(default, null):Array<LineBreakRule>;
    public var lineBreaker(default, null):Option<LineBreakingAlgorithm>;

    /**
     * @param lineBreakingAlgorithm Optional line breaking algorithm.
     *  If provided, it is automatically used to break lines when the text
     *  contains line breaking characters. Otherwise, use `addLineBreak()`
     *  manually for line breaks.
     */
    public function new(?lineBreakingAlgorithm:LineBreakingAlgorithm) {
        this.lineBreaker = lineBreakingAlgorithm != null ? Some(lineBreakingAlgorithm) : None;

        items = [];
        codePoints = [];
        lineBreakRules = [];

        defaultTextProperties = new TextProperties();
    }

    /**
     * Appends an object.
     */
    public function addInlineObject(inlineObject:InlineObject) {
        items.push(InlineObjectItem(inlineObject));
        codePoints.push(0xFFFC);
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

        var runCodePoints = text.toCodePoints();

        switch lineBreaker {
            case Some(lineBreaker_):
                addWithMandatoryBreaks(lineBreaker_, runCodePoints, properties);
            case None:
                addRunFromProperties(runCodePoints, properties);
        }
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
            script: properties.script,
            data: properties.data
        };

        items.push(RunItem(run));

        for (codePoint in codePoints) {
            this.codePoints.push(codePoint);
        }
    }

    function addWithMandatoryBreaks(lineBreaker:LineBreakingAlgorithm,
    codePoints:Array<CodePoint>, properties:TextProperties) {
        var runBreakRules = lineBreaker.getBreaks(codePoints, false);
        var lastBreakIndex = 0;

        for (index in 0...runBreakRules.length) {
            if (runBreakRules[index] == Mandatory) {
                var newRunCodePoints = codePoints.slice(lastBreakIndex, index);
                addRunFromProperties(newRunCodePoints, properties);
                addLineBreak();

                // + 1 to not include the line break character
                lastBreakIndex = index + 1;
            } else {
                lineBreakRules.push(runBreakRules[index]);
            }
        }

        if (lastBreakIndex == 0) {
            addRunFromProperties(codePoints, properties);
        } else {
            var newRunCodePoints = codePoints.slice(lastBreakIndex, runBreakRules.length);
            addRunFromProperties(newRunCodePoints, properties);
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
        lineBreakRules = [];
    }
}
