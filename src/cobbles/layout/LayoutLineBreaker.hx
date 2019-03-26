package cobbles.layout;

import cobbles.algorithm.LineBreakingAlgorithm;

class LayoutLineBreaker {
    var inputShapedItems:Array<ShapedItem>;
    var outputShapedItems:Array<ShapedItem>;
    var verticalOrientation:Bool = false;
    var lineBreakLength:Int;
    var currentLineLength:Int = 0;
    var defaultLineSpacing:Int;
    var lineBreaker:LineBreakingAlgorithm;

    public function new(layout:Layout, inputShapedItems:Array<ShapedItem>,
    lineBreaker:LineBreakingAlgorithm, defaultLineSpacing:Int) {
        this.inputShapedItems = inputShapedItems;
        this.lineBreaker = lineBreaker;
        this.defaultLineSpacing = defaultLineSpacing;
        lineBreakLength = layout.lineBreakLength;
        outputShapedItems = [];

        switch layout.direction {
            case LeftToRight | RightToLeft:
                verticalOrientation = false;
            case TopToBottom | BottomToTop:
                verticalOrientation = true;
        }
    }

    public function lineBreakItems():Array<ShapedItem> {
        while (true) {
            var shapedItem = inputShapedItems.shift();

            if (shapedItem == null) {
                break;
            }

            switch shapedItem {
                case PenRunItem(penRun):
                    processPenRun(penRun);
                case InlineObjectItem(inlineObject):
                    processInlineObject(inlineObject);
                case LineBreakItem(spacing):
                    pushOutputLineBreak(spacing);
            }
        }

        return outputShapedItems;
    }

    function processInlineObject(inlineObject:InlineObject) {
        var itemLength = getInlineObjectLength(inlineObject);

        if (willOverflowLine(itemLength)) {
            pushOutputLineBreak();
        }

        pushOutputItem(InlineObjectItem(inlineObject), itemLength);

        if (willOverflowLine(0)) {
            pushOutputLineBreak();
        }
    }

    function getInlineObjectLength(inlineObject:InlineObject):Int {
        if (!verticalOrientation) {
            return inlineObject.getWidth();
        } else {
            return inlineObject.getHeight();
        }
    }

    function willOverflowLine(extraLength:Int):Bool {
        return lineBreakLength > 0 &&
            currentLineLength + extraLength > lineBreakLength;
    }

    function pushOutputLineBreak(?spacing:Int) {
        if (spacing == null) {
            spacing = defaultLineSpacing;
        }

        outputShapedItems.push(LineBreakItem(spacing));
        currentLineLength = 0;
    }

    function pushOutputItem(item:ShapedItem, itemLength:Int) {
        outputShapedItems.push(item);
        currentLineLength += itemLength;
    }

    function undoOutputPenRunItem():PenRun {
        var item = outputShapedItems.pop();
        var itemLength;

        switch item {
            case PenRunItem(penRun):
                itemLength = getPenRunLength(penRun);
                currentLineLength -= itemLength;
                return penRun;
            default:
                throw "wrong type";
        }
    }

    function processPenRun(penRun:PenRun) {
        var overflowIndex = tryPushFullPenRun(penRun);

        if (overflowIndex >= 0 && isLastOutputInlineObject()) {
            pushOutputLineBreak();
            overflowIndex = tryPushFullPenRun(penRun);
        }

        if (overflowIndex < 0) {
            return;
        }

        var breakIndex = findBreakOpportunity(penRun, 0, overflowIndex);

        if (breakIndex >= 0) {
            breakAndAddPenRun(penRun, breakIndex);
            return;

        } else if (isLastOutputPenRun()) {
            var previousPenRun = undoOutputPenRunItem();
            var previousBreakOpportunity = findBreakOpportunity(
                previousPenRun, 0, previousPenRun.glyphShapes.length - 1);

            if (previousBreakOpportunity >= 0) {
                inputShapedItems.unshift(PenRunItem(penRun));
                breakAndAddPenRun(previousPenRun, previousBreakOpportunity);
                return;
            }

            // FIXME: there could be even more break opportunities in
            // previously output pen runs
        }

        pushOutputLineBreak();
        pushOutputItem(PenRunItem(penRun), getPenRunLength(penRun));
    }

    function getPenRunLength(penRun:PenRun):Int {
        if (!verticalOrientation) {
            return penRun.width;
        } else {
            return penRun.height;
        }
    }

    function tryPushFullPenRun(penRun:PenRun):Int {
        var nextOverflowIndex = findNextOverflow(penRun, 0);

        if (nextOverflowIndex < 0) {
            pushOutputItem(PenRunItem(penRun), getPenRunLength(penRun));
        }

        return nextOverflowIndex;
    }

    function findNextOverflow(penRun:PenRun, glyphStartIndex:Int):Int {
        var runLength = 0;
        var glyphShapes = penRun.glyphShapes;

        for (glyphIndex in glyphStartIndex...glyphShapes.length) {
            var glyphShape = glyphShapes[glyphIndex];
            var glyphAdvance;

            if (!verticalOrientation) {
                glyphAdvance = glyphShape.advanceX;
            } else {
                glyphAdvance = glyphShape.advanceY;
            }

            if (willOverflowLine(runLength + glyphAdvance)) {
                return glyphIndex;
            }

            runLength += glyphAdvance;
        }

        return -1;
    }

    function findBreakOpportunity(penRun:PenRun, glyphStartIndex:Int,
    glyphEndIndex:Int):Int {
        var glyphShapes = penRun.glyphShapes;
        var glyphIndex = glyphEndIndex;
        var lineBreaks = lineBreaker.getBreaks(penRun.text);

        while (glyphIndex > glyphStartIndex) {
            if (lineBreaks.canBreak(glyphShapes[glyphIndex].textIndex)) {
                return glyphIndex;
            }

            glyphIndex -= 1;
        }

        return -1;
    }

    function isLastOutputPenRun():Bool {
        var length = outputShapedItems.length;
        return length > 0 &&
            outputShapedItems[length - 1].match(PenRunItem(_));
    }

    function isLastOutputInlineObject():Bool {
        var length = outputShapedItems.length;
        return length > 0 &&
            outputShapedItems[length - 1].match(InlineObjectItem(_));
    }

    function breakAndAddPenRun(penRun:PenRun, breakIndex:Int) {
        var donePenRun = penRun.slice(0, breakIndex);
        var pendingPenRun = penRun.slice(breakIndex, penRun.glyphShapes.length);
        var doneLength = getPenRunLength(donePenRun);
        var pendingLength = getPenRunLength(pendingPenRun);

        pushOutputItem(PenRunItem(donePenRun), doneLength);
        pushOutputLineBreak();
        pushOutputItem(PenRunItem(pendingPenRun), pendingLength);
    }
}
