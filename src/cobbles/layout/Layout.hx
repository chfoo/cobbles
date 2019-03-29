package cobbles.layout;

import haxe.ds.Option;
import cobbles.font.FontTable;
import cobbles.algorithm.LineBreakingAlgorithm;
import cobbles.shaping.Shaper;
import cobbles.layout.TextSource;

using Safety;

/**
 * Arranges glyphs and lines.
 */
class Layout {
    /**
     * Maximum length of a line in 1/64th of a point.
     *
     * This is used for line breaking (also known as word wrapping).
     *
     * If 0 or negative, there is no automatic line breaking.
     */
    public var lineBreakLength:Int = 0;

    /**
     * Indicates the text alignment or justification.
     *
     * * For horizontal orientation, this indicates flush left, centered, or
     *   flush right.
     * * For vertical orientation, this indicates top alignment, middle
     *   alignment, or bottom alignment.
     */
    public var alignment:Alignment = Alignment.Start;

    /**
     * The order in which runs are placed in lines.
     *
     * * For left-to-right or top-to-bottom, this has no effect.
     * * For right-to-left or bottom-to-top, the order of the items in a line
     *   is reversed for visual ordering.
     *
     * Note this is different from the direction of a text run. Direction
     * on a text run controls the visual ordering of individual characters.
     */
    public var direction:Direction = Direction.LeftToRight;

    /**
     * The orientation and flow direction of lines.
     *
     * * If horizontal, a line of text will flow from left to right and
     *   subsequent lines will flow toward the bottom.
     * * If vertical left-right, a line of text will flow from top to bottom
     *   and subsequent lines will flow toward the right.
     * * If vertical right-left, a line of text will flow from top to bottom
     *   and subsequent lines will flow toward the left.
     */
    public var orientation:Orientation = HorizontalTopBottom;

    /**
     * The default line spacing as a multiplier of the font height.
     */
    public var relativeLineSpacing:Float = 1.2;

    /**
     * Font resolution in dots per inch.
     */
    public var resolution:Int = 72;

    var fontTable:FontTable;
    var textSource:TextSource;
    var shaper:Shaper;
    var lineBreaker:Option<LineBreakingAlgorithm>;

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
     * @param lineBreaker If `lineBreakLength` is not 0, `lineBreaker` will
     *  be used to perform line breaking.
     */
    public function new(fontTable:FontTable, textSource:TextSource,
    shaper:Shaper, ?lineBreaker:LineBreakingAlgorithm) {
        this.fontTable = fontTable;
        this.textSource = textSource;
        this.shaper = shaper;
        this.lineBreaker = lineBreaker != null ? Some(lineBreaker) : None;

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

    function relativeToAbsoluteLineSpacing(relativeSpacing:Float):Int {
        return Math.round(textSource.defaultTextProperties.fontSize * relativeSpacing);
    }

    /**
     * Processes the items from the text source into lines.
     *
     * The processed lines are appended to the array in the `lines` member.
     */
    public function layout() {
        var shapedItems = shapeTextRuns();

        switch lineBreaker {
            case Some(lineBreaker_):
                var layoutLineBreaker = new LayoutLineBreaker(
                    this, shapedItems,
                    lineBreaker_,
                    relativeToAbsoluteLineSpacing(relativeLineSpacing));
                shapedItems = layoutLineBreaker.lineBreakItems();
            case None:
        }

        convertShapedItemsToLines(shapedItems);
        alignLines();
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

    function shapeTextRuns():Array<ShapedItem> {
        var shapedItems:Array<ShapedItem> = [];

        for (textSourceItem in textSource.items) {
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

        shaper.setText(textRun.text);
        shaper.setDirection(textRun.direction);
        shaper.setFont(font);
        shaper.setScript(textRun.script, textRun.language);

        var glyphShapes = shaper.shape();

        var penRun:PenRun = {
            text: textRun.text,
            fontKey: textRun.fontKey,
            fontSize: textRun.fontSize,
            script: textRun.script,
            color: textRun.color,
            glyphShapes: glyphShapes
        };

        return penRun;
    }

    function addLayoutLineInlineObject(inlineObject:InlineObject) {
        var objectSize;

        if (orientation == HorizontalTopBottom) {
            objectSize = inlineObject.getWidth();
        } else {
            objectSize = inlineObject.getHeight();
        }

        currentLine.items.push(LayoutLineItem.InlineObjectItem(inlineObject));
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
            currentLine.spacing = relativeToAbsoluteLineSpacing(relativeLineSpacing);
        } else {
            currentLine.spacing = spacing;
        }
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
        boundingWidth = 0;
        boundingHeight = 0;
        var lineSpacingSum = 0;

        for (line in lines) {
            if (orientation == HorizontalTopBottom) {
                switch alignment {
                    case Start:
                        line.x = 0;
                    case Center:
                        line.x = Math.round((lineBreakLength - line.length) / 2);
                    case End:
                        line.x = lineBreakLength - line.length;
                }

                lineSpacingSum += line.spacing;
                line.y = lineSpacingSum;

                if (line.length > boundingWidth) {
                    boundingWidth = line.length;
                }
                boundingHeight = lineSpacingSum;
            } else {
                switch alignment {
                    case Start:
                        line.y = 0;
                    case Center:
                        line.y = Math.round((lineBreakLength - line.length) / 2);
                    case End:
                        line.y = lineBreakLength - line.length;
                }

                lineSpacingSum += line.spacing;
                line.x = lineSpacingSum;
                boundingWidth = lineSpacingSum;
                if (line.length > boundingHeight) {
                    boundingHeight = line.length;
                }
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


}
