package cobbles.layout;

import cobbles.shaping.GlyphShape;
import cobbles.algorithm.LineBreakingAlgorithm;
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
    var lineBreaker:LineBreakingAlgorithm;

    var lineBuffer:Array<ShapedItem>;
    var lineLength:Int = 0;
    var breakOpportunity:ItemBreakInfo;

    public function new(layout:Layout, lineBreaker:LineBreakingAlgorithm) {
        this.layout = layout;
        this.lineBreaker = lineBreaker;
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
        var runLength = processPenRunBreakOpportunity(penRun);
        lineLength += runLength;
        lineBuffer.push(PenRunItem(penRun));
    }

    function processPenRunBreakOpportunity(penRun:PenRun):Int {
        var runLength = 0;
        var sot = lineBuffer.length == 0;

        if (penRun.glyphShapes.length > 0) {
            breakOpportunity.emergencyPenRunItemIndex = lineBuffer.length;
            breakOpportunity.emergencyGlyphIndex = 1;
        }

        for (glyphIndex in 0...penRun.glyphShapes.length) {
            var glyphShape = penRun.glyphShapes[glyphIndex];
            var glyphAdvance = getGlyphAdvance(glyphShape);
            var codePointIndex = glyphShape.textIndex + penRun.textOffset;

            if (lineLength + glyphAdvance < layout.lineBreakLength) {
                if (layout.lineBreakRules[codePointIndex] == Opportunity) {
                    breakOpportunity.glyphIndex = glyphIndex;
                }

                breakOpportunity.emergencyGlyphIndex = glyphIndex;
                breakOpportunity.penRunItemIndex = lineBuffer.length;
            }

            runLength += glyphAdvance;
        }

        return runLength;
    }

    function getGlyphAdvance(glyphShape:GlyphShape):Int {
        if (layout.orientation == HorizontalTopBottom) {
            return glyphShape.advanceX;
        } else {
            return glyphShape.advanceY;
        }
    }

    public function pushInlineObject(inlineObject:InlineObject) {
        breakOpportunity.emergencyPenRunItemIndex = lineBuffer.length;
        lineBuffer.push(InlineObjectItem(inlineObject));
        lineLength += getInlineObjectLength(inlineObject);
    }

    public function popOverflowedItems(rejectItems:Array<ShapedItem>) {
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

    function popOverflowAtPenRunGlyph(penRunItemIndex:Int, glyphIndex:Int, rejectItems:Array<ShapedItem>) {
        popLineBufferUntilIndex(penRunItemIndex, rejectItems);
        var rejectPenRun = splitPenRunInBuffer(glyphIndex);
        rejectItems.push(PenRunItem(rejectPenRun));
    }

    function popLineBufferUntilIndex(untilIndex:Int, rejectItems:Array<ShapedItem>) {
        var itemIndex = lineBuffer.length - 1;

        while (itemIndex > untilIndex) {
            rejectItems.unshift(lineBuffer.pop().sure());
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
