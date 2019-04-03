package cobbles.layout;

import cobbles.shaping.GlyphShape;
import cobbles.layout.Layout.ShapedItem;

using Safety;

private class ItemBreakInfo {
    public var penRunItemIndex:Int = -1;
    public var glyphIndex:Int = -1;

    public var emergencyPenRunItemIndex:Int = -1;
    public var emergencyGlyphIndex:Int = -1;

    public var inlineObjectItemIndex:Int = -1;

    public function new() {
    }

    public function reset() {
        penRunItemIndex = -1;
        glyphIndex = -1;
        emergencyPenRunItemIndex = -1;
        emergencyGlyphIndex = -1;
        inlineObjectItemIndex = -1;
    }
}

class LayoutLineBreaker {
    var layout:Layout;

    var lineBuffer:Array<ShapedItem>;
    var lineLength:Int = 0;
    var breakOpportunity:ItemBreakInfo;

    public function new(layout:Layout) {
        this.layout = layout;

        lineBuffer = [];
        breakOpportunity = new ItemBreakInfo();
    }

    public function willPenRunOverflowLine(penRun:PenRun):Bool {
        return willOverflowLine(getPenRunLength(penRun));
    }

    public function willInlineObjectOverflowLine(inlineObject:InlineObject):Bool {
        return willOverflowLine(getInlineObjectLength(inlineObject));
    }

    public function isLineOverflown():Bool {
        return willOverflowLine(0);
    }

    function willOverflowLine(extraLength:Int):Bool {
        return layout.lineBreakLength > 0 &&
            lineLength + extraLength > layout.lineBreakLength;
    }

    function getPenRunLength(penRun:PenRun):Int {
        if (layout.orientation == HorizontalTopBottom) {
            return penRun.width;
        } else {
            return penRun.height;
        }
    }

    function getInlineObjectLength(inlineObject:InlineObject):Int {
        if (layout.orientation == HorizontalTopBottom) {
            return inlineObject.getWidth();
        } else {
            return inlineObject.getHeight();
        }
    }

    public function flush(destination:Array<ShapedItem>) {
        for (item in lineBuffer) {
            destination.push(item);
        }

        lineBuffer = [];
        lineLength = 0;
        breakOpportunity.reset();
    }

    public function pushPenRun(penRun:PenRun) {
        lineBuffer.push(PenRunItem(penRun));
        lineLength += getPenRunLength(penRun);
    }

    function getGlyphAdvance(glyphShape:GlyphShape):Int {
        if (layout.orientation == HorizontalTopBottom) {
            return glyphShape.advanceX;
        } else {
            return glyphShape.advanceY;
        }
    }

    public function pushInlineObject(inlineObject:InlineObject) {
        lineBuffer.push(InlineObjectItem(inlineObject));
        lineLength += getInlineObjectLength(inlineObject);
    }

    public function popOverflowedItems(rejectItems:Array<ShapedItem>) {
        scanForBreakOpportunities();

        if (breakOpportunity.penRunItemIndex >= 0 || breakOpportunity.inlineObjectItemIndex >= 0) {
            if (breakOpportunity.penRunItemIndex > breakOpportunity.inlineObjectItemIndex) {
                popOverflowAtPenRunGlyph(
                    breakOpportunity.penRunItemIndex,
                    breakOpportunity.glyphIndex,
                    rejectItems);
            } else {
                popLineBufferUntilIndex(
                    breakOpportunity.inlineObjectItemIndex,
                    rejectItems);
            }

        } else if (breakOpportunity.emergencyPenRunItemIndex >= 0) {
            popOverflowAtPenRunGlyph(
                breakOpportunity.emergencyPenRunItemIndex,
                breakOpportunity.emergencyGlyphIndex, rejectItems);
        } else {
            // Impossible to not overflow
        }
    }

    function scanForBreakOpportunities() {
        breakOpportunity.reset();

        var scannedLineLength = 0;
        var lineBreakRules = layout.textSource.lineBreakRules;

        function scanPenRun(itemIndex:Int, penRun:PenRun) {
            for (glyphIndex in 0...penRun.glyphShapes.length) {
                var glyphShape = penRun.glyphShapes[glyphIndex];
                var glyphAdvance = getGlyphAdvance(glyphShape);
                var codePointIndex = glyphShape.textIndex + penRun.textOffset;
                var isInBounds = scannedLineLength + glyphAdvance < layout.lineBreakLength;

                if (isInBounds) {
                    if (lineBreakRules[codePointIndex] == Opportunity) {
                        breakOpportunity.penRunItemIndex = itemIndex;
                        breakOpportunity.glyphIndex = glyphIndex;
                    }

                    breakOpportunity.emergencyPenRunItemIndex = itemIndex;
                    breakOpportunity.emergencyGlyphIndex = glyphIndex;
                } else if (breakOpportunity.emergencyPenRunItemIndex < 0) {
                    breakOpportunity.emergencyPenRunItemIndex = itemIndex;
                    breakOpportunity.emergencyGlyphIndex = glyphIndex;
                }

                scannedLineLength += glyphAdvance;
            }
        }

        for (itemIndex in 0...lineBuffer.length) {
            var item = lineBuffer[itemIndex];

            switch item {
                case PenRunItem(penRun):
                    scanPenRun(itemIndex, penRun);
                case InlineObjectItem(inlineObject):
                    breakOpportunity.inlineObjectItemIndex = itemIndex;
                default:
                    // pass
            }
        }

        // Don't allow a break at the start of the line
        if (breakOpportunity.penRunItemIndex >= 0 && breakOpportunity.glyphIndex == 0) {
            breakOpportunity.penRunItemIndex = -1;
            breakOpportunity.glyphIndex = -1;
        }
        if (breakOpportunity.emergencyPenRunItemIndex >= 0 && breakOpportunity.emergencyGlyphIndex == 0) {
            breakOpportunity.emergencyPenRunItemIndex = -1;
            breakOpportunity.emergencyGlyphIndex = -1;
        }
    }

    function popOverflowAtPenRunGlyph(penRunItemIndex:Int, glyphIndex:Int, rejectItems:Array<ShapedItem>) {
        popLineBufferUntilIndex(penRunItemIndex, rejectItems);
        var rejectPenRun = splitPenRunInBuffer(glyphIndex);
        rejectItems.unshift(PenRunItem(rejectPenRun));
    }

    function popLineBufferUntilIndex(untilIndex:Int, rejectItems:Array<ShapedItem>) {
        var itemIndex = lineBuffer.length - 1;

        while (itemIndex > untilIndex) {
            rejectItems.unshift(lineBuffer.pop().sure());
            itemIndex -= 1;
        }
    }

    function splitPenRunInBuffer(index:Int):PenRun {
        switch lineBuffer.pop().sure() {
            case PenRunItem(penRun):
                lineLength -= getPenRunLength(penRun);

                var keep = penRun.slice(0, index);
                var reject = penRun.slice(index, penRun.glyphShapes.length);

                lineBuffer.push(PenRunItem(keep));
                lineLength += getPenRunLength(keep);

                return reject;

            default:
                throw "not pen run";
        }

    }
}
