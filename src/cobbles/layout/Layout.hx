package cobbles.layout;

import cobbles.font.FontTable;
import cobbles.shaping.Shaper;
import cobbles.layout.TextSource;


enum ShapedItem {
    PenRunItem(penRun:PenRun);
    InlineObjectItem(inlineObject:InlineObject);
    LineBreakItem(spacing:Int);
}

/**
 * Arranges glyphs and lines.
 */
class Layout {
    /**
     * Maximum length of a line in 1/64th of a point.
     *
     * This is used for line breaking (also known as word wrapping).
     *
     * If 0 or negative or line breaking rules is not provided in the text
     * source, there is no automatic line breaking.
     */
    public var lineBreakLength:Int = 0;

    /**
     * Indicates the text alignment or justification.
     *
     * - For horizontal orientation, this indicates flush left, centered, or
     *   flush right.
     * - For vertical orientation, this indicates top alignment, middle
     *   alignment, or bottom alignment.
     */
    public var alignment:Alignment = Alignment.Start;

    /**
     * The orientation and flow direction of lines.
     *
     * - If horizontal, a line of text will flow from left to right and
     *   subsequent lines will flow toward the bottom.
     * - If vertical left-right, a line of text will flow from top to bottom
     *   and subsequent lines will flow toward the right.
     * - If vertical right-left, a line of text will flow from top to bottom
     *   and subsequent lines will flow toward the left.
     */
    public var orientation:Orientation = HorizontalTopBottom;

    /**
     * The default line spacing as a multiplier of the font height.
     */
    public var relativeLineSpacing:Float = 1.2;

    // Harfbuzz doesn't use DPI in the calculations, so disable writing to it.
    /**
     * Font resolution in dots per inch.
     */
    public var resolution(default, null):Int = 72;

    var fontTable:FontTable;
    public var textSource(default, null):TextSource;
    var shaper:Shaper;

    /**
     * The text processed into lines.
     */
    public var lines(default, null):Array<LayoutLine>;

    /**
     * The maximum width of the layout containing content in 1/64th of a point.
     */
    public var boundingWidth(default, null):Int = 0;

    /**
     * The maximum height of the layout containing content in 1/64th of a point.
     */
    public var boundingHeight(default, null):Int = 0;

    var currentLine:LayoutLine;

    /**
     * @param fontTable Font table
     * @param textSource Text source
     * @param shaper Shaper
     */
    public function new(fontTable:FontTable, textSource:TextSource,
    shaper:Shaper) {
        this.fontTable = fontTable;
        this.textSource = textSource;
        this.shaper = shaper;

        lines = [];
        currentLine = new LayoutLine();


        clearLines();
    }

    /**
     * Convert a value in points to pixels.
     */
    public function pointToPixel(points:Float):Int {
        return Math.round(points / 72 * resolution);
    }

    /**
     * Convert a value in 1/64th of a point to pixels.
     */
    public function point64ToPixel(points64:Int):Int {
        return Math.round(points64 / 64 / 72 * resolution);
    }

    /**
     * Convert a value in pixels to points.
     */
    public function pixelToPoint(pixels:Int):Int {
        return Math.round(pixels / resolution * 72);
    }

    /**
     * Convert a value in pixels to 1/6th of a point.
     */
    public function pixelToPoint64(pixels:Int):Int {
        return Math.round(pixels / resolution * 72 * 64);
    }

    public function relativeToAbsoluteLineSpacing(relativeSpacing:Float):Int {
        return Math.round(textSource.defaultTextProperties.fontSize * relativeSpacing);
    }

    /**
     * Processes the items from the text source into lines.
     *
     * The processed lines are appended to the array in the `lines` member.
     */
    public function layout() {
        var shapedItems = shapeTextRuns(textSource.items);

        if (lineBreakLength > 0 && textSource.lineBreakRules.length > 0) {
            shapedItems = processLineBreaking(shapedItems);
        }

        convertShapedItemsToLines(shapedItems);
        calculateBoundingSize();
        alignLines();

        switch textSource.defaultTextProperties.direction {
            case RightToLeft | BottomToTop:
                reverseLineRunOrder();
            default:
                // pass
        }
    }

    /**
     * Clears the processed lines.
     */
    public function clearLines() {
        #if haxe4
        lines.resize(0);
        #else
        lines.splice(0, lines.length);
        #end

        currentLine = new LayoutLine();
        currentLine.spacing = relativeToAbsoluteLineSpacing(relativeLineSpacing);
        lines.push(currentLine);
    }

    function shapeTextRuns(textSourceItems:Array<TextSourceItem>):Array<ShapedItem> {
        var shapedItems:Array<ShapedItem> = [];

        for (textSourceItem in textSourceItems) {
            switch textSourceItem {
                case RunItem(textRun):
                    shapedItems.push(PenRunItem(shapeTextRun(textRun)));
                case LineBreakItem(relativeSpacing):
                    var spacing = relativeToAbsoluteLineSpacing(relativeSpacing);
                    shapedItems.push(LineBreakItem(spacing));
                case InlineObjectItem(inlineObject):
                    shapedItems.push(InlineObjectItem(inlineObject));
            }
        }

        return shapedItems;
    }

    function shapeTextRun(textRun:TextRun):PenRun {
        var font = fontTable.getFont(textRun.fontKey);
        font.setSize(0, textRun.fontSize, 0, resolution);

        var codePoints = textSource.codePoints.slice(
            textRun.codePointIndex,
            textRun.codePointIndex + textRun.codePointCount);
        shaper.setCodePoints(codePoints);
        shaper.setDirection(textRun.direction);
        shaper.setFont(font);
        shaper.setScript(textRun.script, textRun.language);

        var glyphShapes = shaper.shape();

        var penRun:PenRun = {
            fontKey: textRun.fontKey,
            fontSize: textRun.fontSize,
            script: textRun.script,
            color: textRun.color,
            glyphShapes: glyphShapes,
            textOffset: textRun.codePointIndex,
            rtl: textRun.direction.match(RightToLeft | BottomToTop),
            data: textRun.data
        };

        return penRun;
    }

    function processLineBreaking(input:Array<ShapedItem>) {
        var layoutLineBreaker = new LayoutLineBreaker(this);
        var output = [];

        function flushAndAddNewLine() {
            layoutLineBreaker.flush(output);
            output.push(LineBreakItem(getDefaultSpacing()));
        }

        while (true) {
            var item = input.shift();

            if (item == null) {
                break;
            }

            switch item {
                case PenRunItem(penRun):
                    layoutLineBreaker.pushPenRun(penRun);

                    if (layoutLineBreaker.isLineOverflown()) {
                        layoutLineBreaker.popOverflowedItems(input);
                        flushAndAddNewLine();
                    }

                case InlineObjectItem(inlineObject):
                    if (layoutLineBreaker.willInlineObjectOverflowLine(inlineObject)) {
                        flushAndAddNewLine();
                    }

                    layoutLineBreaker.pushInlineObject(inlineObject);

                    if (layoutLineBreaker.isLineOverflown()) {
                        flushAndAddNewLine();
                    }
                case LineBreakItem(spacing):
                    layoutLineBreaker.flush(output);
                    output.push(item);
            }
        }

        layoutLineBreaker.flush(output);

        return output;
    }

    function addLayoutLineInlineObject(inlineObject:InlineObject) {
        var objectSize;

        if (orientation == HorizontalTopBottom) {
            objectSize = inlineObject.getWidth();
        } else {
            objectSize = inlineObject.getHeight();
        }

        currentLine.items.push(LayoutLineItem.InlineObjectItem(inlineObject));
        increaseCurrentLineLength(objectSize);
    }

    function addRunToCurrentLine(penRun:PenRun) {
        currentLine.items.push(LayoutLineItem.PenRunItem(penRun));

        if (orientation == HorizontalTopBottom) {
            currentLine.length += penRun.width;
        } else {
            currentLine.length += penRun.height;
        }
    }

    function increaseCurrentLineLength(length:Int) {
        currentLine.length += length;
    }

    function addLayoutLineBreak(?spacing:Int) {
        currentLine = new LayoutLine();
        lines.push(currentLine);

        if (spacing == null) {
            currentLine.spacing = getDefaultSpacing();
        } else {
            currentLine.spacing = spacing;
        }
    }

    @:allow(cobbles.layout.LayoutLineBreaker)
    function getDefaultSpacing():Int {
        return relativeToAbsoluteLineSpacing(relativeLineSpacing);
    }

    function convertShapedItemsToLines(shapedItems:Array<ShapedItem>) {
        for (shapedItem in shapedItems) {
            switch shapedItem {
                case PenRunItem(penRun):
                    addRunToCurrentLine(penRun);
                case InlineObjectItem(inlineObject):
                    addLayoutLineInlineObject(inlineObject);
                case LineBreakItem(spacing):
                    addLayoutLineBreak(spacing);
            }
        }
    }

    function alignLines() {
        switch orientation {
            case HorizontalTopBottom:
                alignHorizontalLines();
            case VerticalLeftRight | VerticalRightLeft:
                alignVerticalLines();
        }
    }

    function alignHorizontalLines() {
         var lineSpacingSum = 0;

        for (line in lines) {
            switch alignment {
                case Start:
                    line.x = 0;
                case Center:
                    line.x = Math.round((boundingWidth - line.length) / 2);
                case End:
                    line.x = boundingWidth - line.length;
            }

            lineSpacingSum += line.spacing;
            line.y = lineSpacingSum;
        }
    }

    function alignVerticalLines() {
        var lineSpacingSum = 0;

        for (line in lines) {
            switch alignment {
                case Start:
                    line.y = 0;
                case Center:
                    line.y = Math.round((boundingHeight - line.length) / 2);
                case End:
                    line.y = boundingHeight - line.length;
            }

            lineSpacingSum += line.spacing;

            if (orientation == VerticalLeftRight) {
                line.x = lineSpacingSum;
            } else {
                line.x = boundingWidth - lineSpacingSum;
            }
        }
    }

    function calculateBoundingSize() {
        boundingWidth = 0;
        boundingHeight = 0;

        for (line in lines) {
            if (orientation == HorizontalTopBottom) {
                if (line.length > boundingWidth) {
                    boundingWidth = line.length;
                }

                boundingHeight += line.spacing;
            } else {
                if (line.length > boundingHeight) {
                    boundingHeight = line.length;
                }

                boundingWidth += line.spacing;
            }
        }

        if (orientation == HorizontalTopBottom) {
            boundingHeight += Math.round(
                textSource.defaultTextProperties.fontSize *
                relativeLineSpacing * 0.5);
        } else {
            boundingWidth += Math.round(
                textSource.defaultTextProperties.fontSize *
                relativeLineSpacing * 0.5);
        }
    }

    function reverseLineRunOrder() {
        for (line in lines) {
            line.items.reverse();
        }
    }
}
