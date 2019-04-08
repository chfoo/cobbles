package cobbles.layout;

import cobbles.shaping.GlyphShape;
import cobbles.layout.Layout.ShapedItem;

using Safety;

private class ItemBreakInfo {
    public var index:Int = -1;
    public var emergencyIndex:Int = -1;

    public function new() {
    }

    public function reset() {
        index = -1;
        emergencyIndex = -1;
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

        var pendingAcceptItems = [];
        var pendingRejectItems = [];
        var globalIndex = 0;
        var breakIndex;

        if (breakOpportunity.index >= 0) {
            breakIndex = breakOpportunity.index;
        } else if (breakOpportunity.emergencyIndex >= 0) {
            breakIndex = breakOpportunity.emergencyIndex;
        } else {
            // No breaks possible
            return;
        }

        function scanPenRun(penRun:PenRun) {
            var glyphBreakIndex = -1;

            for (glyphIndex_ in 0...penRun.glyphShapes.length) {
                var glyphIndex;

                if (penRun.rtl) {
                    glyphIndex = penRun.glyphShapes.length - 1 - glyphIndex_;
                } else {
                    glyphIndex = glyphIndex_;
                }

                if (globalIndex == breakIndex) {
                    glyphBreakIndex = glyphIndex;
                }

                globalIndex += 1;
            }

            return glyphBreakIndex;
        }

        for (item in lineBuffer) {
            switch item {
                case PenRunItem(penRun):
                    var glyphBreakIndex = scanPenRun(penRun);

                    if (glyphBreakIndex >= 0) {
                        if (!penRun.rtl) {
                            pendingAcceptItems.push(PenRunItem(penRun.slice(0, glyphBreakIndex)));
                            pendingRejectItems.push(PenRunItem(penRun.slice(glyphBreakIndex, penRun.glyphShapes.length)));
                        } else {
                            pendingRejectItems.push(PenRunItem(penRun.slice(0, glyphBreakIndex + 1)));
                            pendingAcceptItems.push(PenRunItem(penRun.slice(glyphBreakIndex + 1, penRun.glyphShapes.length)));
                        }
                    } else if (globalIndex > breakIndex) {
                        pendingRejectItems.push(item);
                    } else {
                        pendingAcceptItems.push(item);
                    }

                case InlineObjectItem(inlineObject):
                    if (globalIndex > breakIndex) {
                        pendingRejectItems.push(item);
                    } else {
                        pendingAcceptItems.push(item);
                    }
                default:
                    // pass
            }
        }

        pendingRejectItems.reverse();

        for (item in pendingRejectItems) {
            rejectItems.unshift(item);
        }

        lineBuffer = pendingAcceptItems;
    }

    function scanForBreakOpportunities() {
        breakOpportunity.reset();

        var scannedLineLength = 0;
        var lineBreakRules = layout.textSource.lineBreakRules;
        var globalIndex = 0;

        function scanPenRun(penRun:PenRun) {
            for (glyphIndex_ in 0...penRun.glyphShapes.length) {
                var glyphIndex;

                if (penRun.rtl) {
                    glyphIndex = penRun.glyphShapes.length - 1 - glyphIndex_;
                } else {
                    glyphIndex = glyphIndex_;
                }

                var glyphShape = penRun.glyphShapes[glyphIndex];
                var glyphAdvance = getGlyphAdvance(glyphShape);
                var codePointIndex = glyphShape.textIndex + penRun.textOffset;
                var isInBounds = scannedLineLength < layout.lineBreakLength;

                if (isInBounds) {
                    if (lineBreakRules[codePointIndex] == Opportunity) {
                        breakOpportunity.index = globalIndex;
                    }

                    breakOpportunity.emergencyIndex = globalIndex;
                } else if (breakOpportunity.emergencyIndex < 0) {
                    breakOpportunity.emergencyIndex = globalIndex;
                }

                scannedLineLength += glyphAdvance;
                globalIndex += 1;
            }
        }

        for (item in lineBuffer) {
            switch item {
                case PenRunItem(penRun):
                    scanPenRun(penRun);
                case InlineObjectItem(inlineObject):
                    breakOpportunity.index = globalIndex;
                default:
                    // pass
            }

            if (scannedLineLength > lineLength &&
            breakOpportunity.index >= 0 &&
            breakOpportunity.emergencyIndex >= 0) {
                break;
            }
        }

        // Don't allow a break at the start of the line
        if (breakOpportunity.index == 0) {
            breakOpportunity.index = -1;
        }
        if (breakOpportunity.emergencyIndex == 0) {
            breakOpportunity.emergencyIndex = -1;
        }
    }
}
